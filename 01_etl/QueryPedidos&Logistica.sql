-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- ============================================================
-- ANÁLISE DE PEDIDOS E LOGÍSTICA
-- ============================================================


-- ================================
-- Total de pedidos registrados
-- ================================
SELECT COUNT(*) AS Total_pedidos	
FROM dbo.orders

-- ================================
-- Quantidade de pedidos por order_status.
-- ================================
SELECT 
	order_status, 
	COUNT(order_id) AS Quantidade
FROM dbo.orders
GROUP BY order_status
ORDER BY Quantidade DESC

-- ================================
-- Top 10 pedidos de maior valor
-- ================================
SELECT TOP 10 
	o.order_id,
	c.customer_state, 
	p.payment_value
FROM dbo.orders AS o
INNER JOIN dbo.customers AS c ON o.customer_id = c.customer_id
INNER JOIN dbo.order_payments AS p ON o.order_id = p.order_id
WHERE order_status = 'delivered'
ORDER BY p.payment_value DESC


-- ============================================================
-- Top 5 pedidos de maior valor por Estado.
-- ============================================================
WITH classificacao_vendas_estados AS (
	SELECT	
		o.order_id,
		p.payment_value,
		c.customer_state,
		RANK() OVER (PARTITION BY c.customer_state ORDER BY p.payment_value DESC) AS ranking
	FROM dbo.orders AS o
	INNER JOIN dbo.customers AS c ON o.customer_id = c.customer_id
	INNER JOIN dbo.order_payments AS p ON o.order_id = p.order_id
)
SELECT 
	order_id,
	payment_value,
	customer_state
FROM classificacao_vendas_estados
WHERE ranking <= 5

-- ============================================================
-- Nota média: pedidos atrasados vs no prazo
-- ============================================================
SELECT 
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN 'Atrasado'
        ELSE 'No prazo / Adiantado'
    END AS status_entrega,
    COUNT(*) AS quantidade,
    ROUND(AVG(r.review_score), 2) AS nota_media
FROM dbo.orders AS o
INNER JOIN dbo.order_reviews AS r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY 
    CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date 
        THEN 'Atrasado'
        ELSE 'No prazo / Adiantado'
    END;

-- ============================================================
-- Tempo médio de entrega por estado (em dias)
-- ============================================================
SELECT 
    c.customer_state,
    ROUND(AVG(DATEDIFF(DAY, o.order_purchase_timestamp, 
                            o.order_delivered_customer_date)), 1) AS prazo_medio_dias
FROM dbo.orders AS o
INNER JOIN dbo.customers AS c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY prazo_medio_dias ASC;

-- ============================================================
-- Classificação dos pedidos pelo prazo de entrega:
-- ============================================================
WITH Entregas AS (
	SELECT
		 order_id AS Pedidos,
		 CASE
			WHEN order_delivered_customer_date IS NULL THEN 'Não entregue'
			WHEN order_delivered_customer_date < order_estimated_delivery_date THEN 'Adiantado'
			WHEN CAST (order_delivered_customer_date AS DATE) = CAST (order_estimated_delivery_date AS DATE) THEN 'No prazo'
			ELSE 'Atrasado'
		END AS prazo_entregas
		FROM dbo.orders
)
SELECT 
	prazo_entregas,
	COUNT (*) AS quantidade,
	CAST(ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS DECIMAL(5,1)) AS percentual
FROM Entregas
GROUP BY prazo_entregas
ORDER BY quantidade DESC;

-- ============================================================
-- Pedidos cujo o valor está acima da média 
-- do próprio estado do cliente.
-- ============================================================
SELECT 
	o.order_id AS Pedidos, 
	p.payment_value AS Valor, 
	c.customer_state AS Estado
FROM dbo.orders AS o
INNER JOIN dbo.order_payments AS p ON o.order_id = p.order_id
INNER JOIN dbo.customers AS c ON o.customer_id = c.customer_id
WHERE p.payment_value > (
    SELECT AVG(p2.payment_value)
    FROM dbo.order_payments AS p2
    INNER JOIN dbo.orders AS o2 ON p2.order_id = o2.order_id
    INNER JOIN dbo.customers AS c2 ON o2.customer_id = c2.customer_id
    WHERE c2.customer_state = c.customer_state
	)
ORDER BY Valor DESC;