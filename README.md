## 💡 Motivação do projeto

Sempre me interessei por entender o "porquê" por trás dos resultados: por que pessoas escolhem determinado produto entre vários semelhantes, como chegamos a um resultado ao longo do tempo, como uma ação específica influenciou positiva ou negativamente um indicador.

A análise de dados me permite transformar essa curiosidade em respostas concretas e confiantes — sem achismos.

O dataset da Olist foi escolhido por ser um dos mais completos e reconhecidos da comunidade brasileira de dados, cobrindo diversas dimensões de um negócio real: financeiro, logística, produto e experiência do cliente.

Abaixo explico todos os processos e procedimentos realizados utilizando o dataset, desde a extração e tratamento dos dados brutos até a construção das análises e geração de insights.

---

# 📦 Brazilian E-Commerce Analysis | SQL Server

Projeto de análise de dados end-to-end utilizando SQL Server para explorar mais de 100 mil pedidos reais do e-commerce brasileiro.

O objetivo foi investigar e transformar dados brutos em insights de negócio sobre receita, logística, retenção e satisfação do cliente.

Desenvolvido com SQL Server (SSMS) como parte da minha jornada de estudos.

---

## 🗂️ Sobre o Dataset

**Fonte:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — Kaggle
**Período:** 2016 a 2018 | 9 tabelas | ~500k registros totais

| Tabela | Registros |
|--------|-----------|
| orders | 99.441 |
| customers | 99.441 |
| order_items | 112.650 |
| order_payments | 103.886 |
| order_reviews | 99.224 |
| products | 32.951 |
| sellers | 3.095 |
| product_category_name_translation | 71 |
| geolocation | 1.000.163 |

### Problemas encontrados e tratamentos aplicados:

Durante o processo de ETL, foram identificados e tratados os seguintes problemas:

- Valores de `payment_value` importados 100x acima do esperado devido a conflito no separador decimal — corrigido via `UPDATE` direto no banco
- Cabeçalho da tabela `product_category_name_translation` importado como registro — removido via `DELETE`
- Colunas com nomes incorretos (`column1`, `column2`) na mesma tabela — renomeadas via `sp_rename`
- 3 registros com `payment_type = 'not_defined'` — volume irrelevante, mantidos sem tratamento
- Gap de novembro/2016 sem nenhum pedido registrado — anomalia confirmada via query, documentada como limitação do dataset
- Produtos sem tradução de categoria — tratados com `ISNULL` como opção de contingência, retornando o nome original em português

---

## 🎯 Perguntas Respondidas e Relevância para o Negócio

**Variação mensal do faturamento:**
Acompanhar a evolução mês a mês permite identificar sazonalidade, validar o impacto de campanhas e antecipar períodos de maior demanda. Como a Olist atua como integrador entre lojistas e marketplaces, esse acompanhamento é essencial para orientar os vendedores parceiros sobre os melhores momentos para investir em visibilidade e estoque.

**Estados com maior receita:**
Direcionar campanhas regionais como frete grátis acima de determinado valor, descontos progressivos por volume ou cashback exclusivo para a região — tanto para atrair novos compradores quanto para aumentar o ticket médio onde a demanda já existe.

**Categorias que geram mais receita:**
Priorizar essas categorias em campanhas sazonais (Black Friday, Natal, etc), negociar melhores condições com fornecedores do segmento e criar seções de destaque na plataforma. Também ajuda a identificar categorias com alto ticket médio mas baixo volume — oportunidade de crescimento com menor esforço operacional.

**Performance de entrega por estado:**
Entregas mais rápidas geram avaliações melhores, avaliações melhores aumentam a conversão de novos compradores e reduzem o custo de aquisição de clientes.

**Categorias com menor satisfação**
Categorias com alto índice de avaliações negativas aumentam o custo operacional com trocas, devoluções e SAC. Além disso, um cliente insatisfeito raramente retorna.

**Índice de recompra:**
Com apenas 3.1% de clientes retornando, o custo de aquisição de novos clientes se torna insustentável no longo prazo. Identificar esse número é o primeiro passo para criar estratégias de fidelização — programa de pontos, cupons pós-compra e e-mail marketing segmentado.

**Métodos de pagamento:**
Com 74% das transações no cartão de crédito e média de 3 parcelas, entender esse comportamento orienta decisões como oferecer parcelamento sem juros como diferencial competitivo ou criar condições especiais para pagamento à vista ou pix (que na época do dataset, ainda não era implementado).

---

## 🔧 Processo

O projeto seguiu o seguinte fluxo de análise:

1. **Modelagem** — criação manual das tabelas com tipos de dados adequados e relacionamentos entre as 9 tabelas do dataset
2. **ETL** — importação dos CSVs, identificação e correção de inconsistências nos dados (valores corrompidos, cabeçalhos importados como registros, gaps no dataset)
3. **Exploração** — queries respondendo perguntas de negócio reais sobre receita, logística, produto e comportamento do cliente
4. **Análise avançada** — Window Functions, CTEs encadeadas, subqueries correlacionadas e segmentação RFM de clientes

Todo o processo foi rico em aprendizado — cada informação gerada a partir dos dados coletados gerou uma decisão analítica real, o que tornou o projeto muito próximo do nosso dia a dia.

---

## 💡 Principais Insights

| Métrica | Resultado |
|---|---|
| Faturamento total | ~R$ 16M |
| Maior crescimento mensal | +53% em nov/2017 ( possivelmente no mês da Black Friday) |
| Taxa de entrega antes do prazo | 89.1% |
| Nota média — pedidos no prazo | 4.0 ⭐ |
| Nota média — pedidos atrasados | 2.0 ⭐ |
| Taxa de recompra | 3.1% |
| Método de pagamento dominante | Cartão de crédito (74%) |
| Estado com maior faturamento | SP (42% do total) |
| Categoria com maior receita | bed_bath_table |
| Categoria com maior ticket médio | computers (~R$ 1.268) |

**Informações que me surpreenderam:**

O baixo índice de recompra (3.1%) foi o resultado mais impactante — embora o período relativamente curto do dataset (2016 à 2018) possa influenciar esse número, ele ainda sinaliza um problema real de fidelização de clientes.

Outro destaque foi a categoria de computadores: maior ticket médio do dataset (~R$ 1.268) combinado com um dos menores percentuais de avaliações negativas — um produto caro que entrega boa experiência ao cliente.

---

## 🛠️ Tecnologias e Conceitos Aplicados

**Ferramentas**
- SQL Server
- SSMS (SQL Server Management Studio)

**Conceitos SQL aplicados**
- DDL — criação e estruturação de tabelas
- DML — correção e limpeza de dados (`UPDATE`, `DELETE`)
- DQL — consultas e análises (`SELECT`)
- JOINs múltiplos (`INNER JOIN`, `LEFT JOIN`)
- Subqueries simples e correlacionadas
- CTEs (Common Table Expressions)
- `CASE WHEN`
- Window Functions — `ROW_NUMBER`, `RANK`, `LAG`, `NTILE`
- Funções de agregação — `SUM`, `AVG`, `COUNT`, `MIN`, `MAX`
- Funções de data — `DATEDIFF`, `YEAR`, `MONTH`, `CAST`
- `ISNULL`, `ROUND`, `PARTITION BY`

---

## ▶️ Como Executar

1. Faça o download do dataset no Kaggle:
[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

2. Execute os scripts na ordem das pastas:

```
olist-sql-analysis/
│
├── 01_etl/
│   ├── 01_create_tables.sql
│   └── 02_data_validation.sql
│
├── 02_basic/
│   ├── 03_orders_by_status.sql
│   ├── 04_payment_analysis.sql
│   └── 05_customers_by_state.sql
│
├── 03_intermediate/
│   ├── 06_revenue_by_state.sql
│   ├── 07_top_categories.sql
│   ├── 08_delivery_performance.sql
│   └── 09_seller_classification.sql
│
├── 04_advanced/
│   ├── 10_monthly_revenue_lag.sql
│   ├── 11_top3_orders_by_state.sql
│   ├── 12_product_quality.sql
│   ├── 13_seller_performance.sql
│   └── 14_rfm_analysis.sql
│
└── README.md
```

3. Ambiente utilizado: SQL Server + SSMS

---

## 👤 Autor

**Gabriel G. Machado**

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/gabriel-gouveia-machado/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat&logo=github&logoColor=white)](https://github.com/GabrielGouveia7)
