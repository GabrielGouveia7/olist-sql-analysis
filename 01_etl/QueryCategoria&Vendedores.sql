-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- ============================================================
-- ANÁLISE DE CATEGORIA E VENDEDORES
-- ============================================================


-- ============================================================
-- 11. Faturamento por categoria
-- Traz inglês quando existe, português quando não tem tradução
-- ============================================================
SELECT 
    ISNULL(pcn.product_category_name_english, pd.product_category_name) AS categoria,
    COUNT(oi.order_id) AS total_vendas,
    SUM(p.payment_value) AS faturamento_total
FROM dbo.products AS pd
LEFT JOIN dbo.product_category_name_translation AS pcn ON pd.product_category_name = pcn.product_category_name
INNER JOIN dbo.order_items AS oi ON pd.product_id = oi.product_id
INNER JOIN dbo.order_payments AS p ON oi.order_id   = p.order_id
GROUP BY ISNULL(pcn.product_category_name_english, pd.product_category_name)
ORDER BY faturamento_total DESC;

-- ============================================================
-- Top 10 vendedores por faturamento total
-- ============================================================
WITH top_vendedores AS (
	SELECT 
		s.seller_id, 
		SUM(p.payment_value) AS Faturamento, 
		COUNT(oi.order_id) AS Quantidade
	FROM dbo.sellers AS s
	INNER JOIN dbo.order_items AS oi ON s.seller_id = oi.seller_id
	INNER JOIN dbo.order_payments AS p ON oi.order_id = p.order_id
	GROUP BY s.seller_id
	)
SELECT TOP 10 
	seller_id, 
	Faturamento,
	Quantidade
FROM top_vendedores
ORDER BY Faturamento DESC

-- ============================================================
-- Classificação dos vendedores baseado no faturamento total
-- ============================================================
WITH faturamento_vendedores AS (
	SELECT 
		s.seller_id, 
		SUM(p.payment_value) AS Faturamento_total
	FROM dbo.sellers AS s
	INNER JOIN dbo.order_items AS oi ON s.seller_id = oi.seller_id
	INNER JOIN dbo.order_payments AS p ON oi.order_id = p.order_id
	GROUP BY s.seller_id
)
SELECT 
    seller_id,
    Faturamento_total,
    CASE 
        WHEN Faturamento_total < 30000  THEN 'Baixo'
        WHEN Faturamento_total < 100000 THEN 'Médio'
        ELSE 'Alto'
    END AS Categoria_Vendedor
FROM faturamento_vendedores
ORDER BY Faturamento_total DESC;

-- ================================
-- Ticket médio por categoria
-- ================================
SELECT 
    ISNULL(t.product_category_name_english, p.product_category_name) AS categoria,
    COUNT(oi.order_id) AS total_pedidos,
    ROUND(AVG(op.payment_value), 2) AS ticket_medio
FROM dbo.products AS p
LEFT JOIN dbo.product_category_name_translation AS t 
       ON p.product_category_name = t.product_category_name
INNER JOIN dbo.order_items AS oi ON p.product_id  = oi.product_id
INNER JOIN dbo.order_payments AS op ON oi.order_id   = op.order_id
GROUP BY ISNULL(t.product_category_name_english, p.product_category_name)
ORDER BY ticket_medio DESC;

-- ================================
-- Desempenho dos vendedores
-- ================================
WITH desempenho_sellers AS (
    SELECT 
        s.seller_id,
        COUNT(o.order_id) AS total_pedidos,
        SUM(CASE WHEN o.order_delivered_customer_date 
                    > o.order_estimated_delivery_date 
                 THEN 1 ELSE 0 END) AS pedidos_atrasados,
        CAST(ROUND(SUM(CASE WHEN o.order_delivered_customer_date 
                              > o.order_estimated_delivery_date 
                            THEN 1 ELSE 0 END) * 100.0 
             / COUNT(o.order_id), 1) AS DECIMAL(5,1)) AS pct_atraso,
        ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS nota_media
    FROM dbo.sellers AS s
    INNER JOIN dbo.order_items AS oi ON s.seller_id = oi.seller_id
    INNER JOIN dbo.orders  AS o ON oi.order_id  = o.order_id
    INNER JOIN dbo.order_reviews AS r ON o.order_id = r.order_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY s.seller_id
)
SELECT
    seller_id,
    total_pedidos,
    pedidos_atrasados,
    pct_atraso,
    nota_media
FROM desempenho_sellers
WHERE total_pedidos >= 30  -- foco em vendedores com volume relevante
ORDER BY pct_atraso DESC, nota_media ASC;

