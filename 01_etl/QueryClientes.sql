-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- ============================================================
-- ANÁLISE DE CLIENTES
-- ============================================================


-- ============================================================
-- Top 10 Estados com maior número de clientes
-- ============================================================
SELECT TOP 10
	customer_state, 
	COUNT(DISTINCT customer_unique_id) as Quantidade
FROM dbo.customers
GROUP BY customer_state 
ORDER BY Quantidade DESC

-- ============================================================
-- Índice de recompra (clientes com mais de 1 pedido)
-- ============================================================
WITH pedidos_por_cliente AS (
    SELECT 
        customer_unique_id,
        COUNT(o.order_id) AS total_pedidos
    FROM dbo.customers AS c
    INNER JOIN dbo.orders AS o ON c.customer_id = o.customer_id
    GROUP BY customer_unique_id
)
SELECT 
    SUM(CASE WHEN total_pedidos = 1  THEN 1 ELSE 0 END) AS compraram_1x,
    SUM(CASE WHEN total_pedidos > 1  THEN 1 ELSE 0 END) AS compraram_mais_1x,
    ROUND(SUM(CASE WHEN total_pedidos > 1 THEN 1 ELSE 0 END) * 100.0 
          / COUNT(*), 1) AS pct_recompra
FROM pedidos_por_cliente;

-- ============================================================
-- Distribuição das avaliações
-- ============================================================
SELECT 
    review_score AS nota,
    COUNT(*) AS quantidade,
    CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) 
         AS DECIMAL(5,1)) AS percentual
FROM dbo.order_reviews
GROUP BY review_score
ORDER BY review_score DESC;

-- ============================================================
-- Nota média e percentual de notas negativas
-- ============================================================
WITH avaliacoes_categoria AS (
    SELECT 
        ISNULL(t.product_category_name_english, 
               p.product_category_name) AS categoria,
        COUNT(r.review_id) AS total_avaliacoes,
        ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS nota_media,
        SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS avaliacoes_negativas,
        CAST(ROUND(SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) * 100.0 
             / COUNT(r.review_id), 1) AS DECIMAL(5,1)) AS pct_negativas
    FROM dbo.products AS p
    LEFT  JOIN dbo.product_category_name_translation AS t  
            ON p.product_category_name       = t.product_category_name
    INNER JOIN dbo.order_items    AS oi ON p.product_id  = oi.product_id
    INNER JOIN dbo.orders         AS o  ON oi.order_id   = o.order_id
    INNER JOIN dbo.order_reviews  AS r  ON o.order_id    = r.order_id
    GROUP BY ISNULL(t.product_category_name_english, p.product_category_name)
)
SELECT
    categoria,
    total_avaliacoes,
    nota_media,
    avaliacoes_negativas,
    pct_negativas
FROM avaliacoes_categoria
WHERE total_avaliacoes >= 100  -- evita categorias com poucos dados
ORDER BY pct_negativas DESC, total_avaliacoes ASC

-- ============================================================
-- Análise RFM
-- ============================================================
WITH rfm_base AS (
    SELECT 
        c.customer_unique_id,
        DATEDIFF(DAY, MAX(o.order_purchase_timestamp), '2018-10-01') AS recencia,
        COUNT(o.order_id) AS frequencia,
        ROUND(SUM(p.payment_value), 2) AS monetario
    FROM dbo.customers AS c
    INNER JOIN dbo.orders AS o ON c.customer_id = o.customer_id
    INNER JOIN dbo.order_payments AS p  ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
rfm_scores AS (
    SELECT 
        customer_unique_id, recencia, frequencia, monetario,
        NTILE(5) OVER (ORDER BY recencia     ASC)  AS r_score, -- menor recência = melhor
        NTILE(5) OVER (ORDER BY frequencia   ASC)  AS f_score,
        NTILE(5) OVER (ORDER BY monetario    ASC)  AS m_score
    FROM rfm_base
)
SELECT 
    customer_unique_id,
    recencia, frequencia, monetario,
    r_score, f_score, m_score,
    (r_score + f_score + m_score)   AS rfm_total,
    CASE 
        WHEN (r_score + f_score + m_score) >= 13 THEN 'Campeão'
        WHEN (r_score + f_score + m_score) >= 10 THEN 'Leal'
        WHEN (r_score + f_score + m_score) >= 7  THEN 'Potencial'
        WHEN (r_score + f_score + m_score) >= 4  THEN 'Em risco'
        ELSE                                          'Perdido'
    END AS segmento
FROM rfm_scores
ORDER BY frequencia DESC;