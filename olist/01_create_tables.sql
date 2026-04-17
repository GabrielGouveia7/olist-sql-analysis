-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- 01_create_tables.sql
-- Criação do banco de dados e tabelas
-- ============================================================

CREATE DATABASE olist;
GO

USE olist;
GO

-- ================================
-- Tabela de pedidos
-- ================================
CREATE TABLE orders (
    order_id                          VARCHAR(50) PRIMARY KEY,
    customer_id                       VARCHAR(50),
    order_status                      VARCHAR(20),
    order_purchase_timestamp          DATETIME,
    order_approved_at                 DATETIME,
    order_delivered_carrier_date      DATETIME,
    order_delivered_customer_date     DATETIME,
    order_estimated_delivery_date     DATETIME
);

-- ================================
-- Clientes
-- ================================
CREATE TABLE customers (
    customer_id                       VARCHAR(50) PRIMARY KEY,
    customer_unique_id                VARCHAR(50),
    customer_zip_code_prefix          INT,
    customer_city                     VARCHAR(100),
    customer_state                    CHAR(2)
);

-- ================================
-- Itens do pedido
-- ================================
CREATE TABLE order_items (
    order_id                          VARCHAR(50),
    order_item_id                     INT,
    product_id                        VARCHAR(50),
    seller_id                         VARCHAR(50),
    shipping_limit_date               DATETIME,
    price                             DECIMAL(10,2),
    freight_value                     DECIMAL(10,2)
);

-- ================================
-- Pagamentos
-- ================================
CREATE TABLE order_payments (
    order_id                          VARCHAR(50),
    payment_sequential                INT,
    payment_type                      VARCHAR(20),
    payment_installments              INT,
    payment_value                     DECIMAL(10,2)
);

-- ================================
-- Avaliações
-- ================================
CREATE TABLE order_reviews (
    review_id                         VARCHAR(50),
    order_id                          VARCHAR(50),
    review_score                      INT,
    review_comment_title              VARCHAR(255),
    review_comment_message            TEXT,
    review_creation_date              DATETIME,
    review_answer_timestamp           DATETIME
);

-- ================================
-- Produtos
-- ================================
CREATE TABLE products (
    product_id                        VARCHAR(50) PRIMARY KEY,
    product_category_name             VARCHAR(100),
    product_name_lenght               INT,
    product_description_lenght        INT,
    product_photos_qty                INT,
    product_weight_g                  DECIMAL(10,2),
    product_length_cm                 DECIMAL(10,2),
    product_height_cm                 DECIMAL(10,2),
    product_width_cm                  DECIMAL(10,2)
);

-- ================================
-- Tradução de categorias
-- ================================
CREATE TABLE product_category_name_translation (
    product_category_name             VARCHAR(100) PRIMARY KEY,
    product_category_name_english     VARCHAR(100)
);

-- ================================
-- Vendedores
-- ================================
CREATE TABLE sellers (
    seller_id                         VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix            VARCHAR(150),
    seller_city                       VARCHAR(100),
    seller_state                      CHAR(2)
);

-- ================================
-- Geolocalização
-- ================================
CREATE TABLE geolocation (
    geolocation_zip_code_prefix       INT,
    geolocation_lat                   DECIMAL(10,6),
    geolocation_lng                   DECIMAL(10,6),
    geolocation_city                  VARCHAR(100),
    geolocation_state                 CHAR(2)
);
