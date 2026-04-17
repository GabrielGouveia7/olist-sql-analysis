-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- 01_etl/02_data_validation.sql
-- Validação, limpeza e correção dos dados importados
-- ============================================================

-- ================================
-- Correção de nomes de colunas
-- product_category_name_translation
-- ================================
EXEC sp_rename 'dbo.product_category_name_translation.column1',
               'product_category_name', 'COLUMN';

EXEC sp_rename 'dbo.product_category_name_translation.column2',
               'product_category_name_english', 'COLUMN';

-- ================================
-- Remoção do cabeçalho importado
-- como registro
-- ================================
DELETE FROM dbo.product_category_name_translation
WHERE product_category_name = 'product_category_name'
  AND product_category_name_english = 'product_category_name_english';

-- ================================
-- Correção dos valores de pagamento
-- importados 100x acima do esperado
-- ================================
UPDATE dbo.order_payments
SET payment_value = payment_value / 100;

-- ================================
-- Validação: contagem de registros
-- por tabela
-- ================================
SELECT 'orders'                          AS tabela, COUNT(*) AS total FROM dbo.orders
UNION ALL
SELECT 'customers',                               COUNT(*) FROM dbo.customers
UNION ALL
SELECT 'order_items',                             COUNT(*) FROM dbo.order_items
UNION ALL
SELECT 'order_payments',                          COUNT(*) FROM dbo.order_payments
UNION ALL
SELECT 'order_reviews',                           COUNT(*) FROM dbo.order_reviews
UNION ALL
SELECT 'products',                                COUNT(*) FROM dbo.products
UNION ALL
SELECT 'sellers',                                 COUNT(*) FROM dbo.sellers
UNION ALL
SELECT 'product_category_name_translation',       COUNT(*) FROM dbo.product_category_name_translation
UNION ALL
SELECT 'geolocation',                             COUNT(*) FROM dbo.geolocation;

-- ================================
-- Validação: anomalia nov/2016
-- (zero pedidos confirmado)
-- ================================
SELECT COUNT(*) AS total
FROM dbo.orders
WHERE YEAR(order_purchase_timestamp)  = 2016
  AND MONTH(order_purchase_timestamp) = 11;

-- ================================
-- Validação: payment_type não definido
-- (3 registros — volume irrelevante)
-- ================================
SELECT payment_type, COUNT(*) AS total
FROM dbo.order_payments
WHERE payment_type = 'not_defined'
GROUP BY payment_type;
