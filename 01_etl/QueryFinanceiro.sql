-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- ============================================================
-- ANÁLISE DO FINANCEIRO
-- ============================================================


-- ===============================
-- Faturamento anual e acumulado
-- ===============================
WITH faturamento_anual AS (
	SELECT
		YEAR(o.order_purchase_timestamp) AS Ano, 
		SUM(p.payment_value) AS fat_anual
	FROM dbo.orders AS o 
	INNER JOIN dbo.order_payments AS p ON o.order_id = p.order_id 
	GROUP BY YEAR(o.order_purchase_timestamp)
)
SELECT
	Ano,
	fat_anual,
	SUM(fat_anual) OVER (ORDER BY Ano) AS fat_acumulado
FROM faturamento_anual

-- ================================
-- Ticket médio
-- ================================
SELECT AVG(payment_value) as Ticket_medio 
FROM dbo.order_payments

-- =================================
-- Tipo de pagamento mais utilizado
-- =================================
SELECT payment_type, COUNT(payment_type) AS Quantidade
FROM dbo.order_payments
GROUP BY payment_type
ORDER BY Quantidade DESC

-- ==================================
-- Valor total e quantidade de pedidos 
-- por tipo de pagamento
-- ==================================
SELECT 
	payment_type, 
	SUM(payment_value) AS Valor_total, 
	COUNT(order_id) AS Quantidade
FROM dbo.order_payments
GROUP BY payment_type
ORDER BY Quantidade DESC

-- ======================================
-- Média de parcelas no cartão de crédito
-- ======================================
SELECT AVG(payment_installments) AS Media
FROM dbo.order_payments
WHERE payment_type = 'credit_card'

-- =============================
-- Faturamento total por Estado
-- =============================
SELECT 
	c.customer_state, 
	SUM(p.payment_value) AS Faturamento_total
FROM dbo.customers AS c
INNER JOIN dbo.orders AS o ON c.customer_id = o.customer_id
INNER JOIN dbo.order_payments AS p ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY Faturamento_total DESC

-- ==============================
-- Faturamento mensal e variação
-- percentual mês a mês
-- ==============================
WITH faturamento_mensal AS (
    SELECT 
        YEAR(o.order_purchase_timestamp)  AS ano,
        MONTH(o.order_purchase_timestamp) AS mes,
        SUM(p.payment_value) AS faturamento
    FROM dbo.orders AS o
    INNER JOIN dbo.order_payments AS p ON o.order_id = p.order_id
    GROUP BY 
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
)
SELECT 
	ano, mes, faturamento,
		CAST(	
			ROUND((faturamento - LAG(faturamento) OVER (ORDER BY ano, mes)) * 100.0 /
			 LAG(faturamento) OVER (ORDER BY ano, mes), 1 
		) AS DECIMAL(10,1)) AS variacao_pct
FROM faturamento_mensal
ORDER BY ano, mes;

