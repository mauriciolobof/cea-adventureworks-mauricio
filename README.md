# Adventure Works — Analytics Engineering

Projeto final da certificação **Analytics Engineer** (Indicium AI), construído sobre o dataset relacional da Adventure Works (fabricante fictícia de bicicletas). O objetivo é sair de um banco Postgres transacional para um data warehouse dimensional, testado e documentado, alimentando um dashboard de BI que responde às perguntas do time comercial.

> Autor: Mauricio Lobo · mauriciolobof@gmail.com

## Contexto do desafio

A Adventure Works quer profissionalizar sua análise de vendas. Três stakeholders orientam as decisões deste projeto:

- **Carlos (CEO)** — quer prova de que os números do warehouse batem com a contabilidade. Por isso o pipeline inclui um teste de dado dedicado, validando que o total bruto de vendas de 2011 é exatamente **$12.646.112,16**.
- **Silvana (Comercial)** — cética em relação a dashboards; as perguntas de negócio (a)-(f) respondidas neste projeto vêm diretamente das dores dela (melhores clientes, melhores cidades, ticket médio, motivo de venda).
- **Gabriel (DBA)** — agenda curta; o schema de origem (`adventure_works`) foi tratado como fonte imutável, sem alterações na origem.

## Arquitetura

```
Postgres (schema adventure_works)
        │  ingestão (fora do escopo deste repo — dados já disponibilizados no Databricks)
        ▼
Databricks · Unity Catalog
  catalog: fea_academy
  schema:  adventure_works          (tabelas fonte, somente leitura)
  schema:  dbt_mauricio             (modelos construídos pelo dbt)
        ▼
dbt Cloud (transformação, testes, documentação)
        ▼
Looker Studio (dashboard interativo)
```

## Modelo dimensional (star schema)

Grão da fato: **uma linha por item de pedido** (`sales_order_detail`).

O diagrama conceitual completo (fato + 7 dimensões + tabelas fonte de cada uma) está em [`diagram/Diagrama_Conceitual_Adventure_Works.pdf`](diagram/Diagrama_Conceitual_Adventure_Works.pdf).

| Dimensão | Tabelas fonte | Atributos-chave |
|---|---|---|
| `dim_date` | gerada a partir de `sales_order_header.order_date` | dia, mês, trimestre, ano, dia da semana |
| `dim_customer` | `sales_customer` + `person` | nome do cliente, tipo |
| `dim_product` | `production_product` + subcategory + category | nome, subcategoria, categoria |
| `dim_salesperson` | `sales_salesperson` + `employee` + `person` | nome do vendedor |
| `dim_geography` | `person_address` + `state_province` + `country_region` | cidade, estado, país |
| `dim_credit_card` | `sales_credit_card` | tipo de cartão |
| `dim_sales_reason` | `sales_reason` (via ponte `sales_order_header_sales_reason`) | motivo da venda |
| `fct_sales` | `sales_order_header` + `sales_order_detail` | quantidade, preço, desconto, status, FKs |

### Decisão de modelagem: motivo de venda é M:N

Um pedido pode ter mais de um motivo de venda — investigação nos dados reais mostrou que **~19,5% dos pedidos (4.482 de 23.012)** têm mais de um motivo associado. Ligar `dim_sales_reason` diretamente à `fct_sales` causaria fanout (duplicação de quantidade/valor). Por isso essa relação foi isolada em `fct_sales_reason_bridge`, uma tabela ponte ("factless fact") com uma linha por combinação pedido × motivo. Ela é usada só para responder à pergunta de negócio sobre motivo de venda — nunca para somar valor/quantidade agregados de `fct_sales`.

### Achado de qualidade de dados: código de país da Namíbia

O código ISO de país da Namíbia é literalmente `"NA"`, que ferramentas de ingestão comumente confundem com nulo. Isso gerou uma falha no teste de `not_null` do source. Tratamento: o teste foi rebaixado para `severity: warn` (documentando o comportamento conhecido da fonte) e a coluna foi corrigida no modelo de staging com `coalesce(country_region_code, case when name = 'Namibia' then 'NA' end)`.

## Estrutura do projeto dbt

```
models/
  staging/
    adventure_works/
      _adventure_works__sources.yml      # sources + testes de qualidade da matéria-prima
      stg_adventure_works__*.sql         # 15 modelos, 1 por tabela fonte
  marts/
    sales/
      _sales__models.yml                 # documentação + testes de todas as dims/fato
      dim_date.sql
      dim_customer.sql
      dim_product.sql
      dim_geography.sql
      dim_salesperson.sql
      dim_credit_card.sql
      dim_sales_reason.sql
      fct_sales.sql
      fct_sales_reason_bridge.sql
      rpt_sales.sql                      # tabela larga (BI-ready) consumida pelo Looker Studio
tests/
  assert_gross_sales_2011.sql            # teste de dado — validação pedida pelo Carlos
diagram/
  Diagrama_Conceitual_Adventure_Works.pdf
```

## Testes implementados

- **Testes de source** (`dbt test --select source:*`): `unique`/`not_null` nas colunas de identificação das 15 tabelas fonte.
- **Testes de primary key**: `unique` + `not_null` na chave de cada dimensão e no grão da fato.
- **Testes de relacionamento**: `relationships` de cada FK da `fct_sales` para a dimensão correspondente.
- **Teste de dado (`assert_gross_sales_2011.sql`)**: valida que o total bruto de vendas de 2011 (`sum(unit_price * order_qty)`) é igual a **$12.646.112,16**, dentro de 1 centavo de tolerância — a validação explicitamente pedida pelo CEO.

Rodar tudo:

```bash
dbt run
dbt test
```

## Documentação

Todas as tabelas e colunas dos modelos em `marts/` têm `description` no YAML. Para navegar a documentação gerada:

```bash
dbt docs generate
dbt docs serve
```

## Dashboard (Looker Studio)

Dashboard interativo construído sobre `dbt_mauricio.rpt_sales`, respondendo:

- (a) pedidos, quantidade e valor por produto, tipo de cartão, motivo de venda, data, cliente, status, cidade, estado e país;
- (b) ticket médio por mês, ano, cidade, estado e país;
- (c) top 10 clientes por valor negociado;
- (d) top 5 cidades por valor negociado;
- (e) série temporal de pedidos/quantidade/valor por mês;
- (f) produto com mais unidades vendidas sob o motivo "Promotion".

🔗 Link do dashboard: **https://datastudio.google.com/reporting/14629f1b-604b-4b13-9aa7-623c549b34ad**

## Vídeo de apresentação

🔗 Link do vídeo: **[https://youtu.be/O56uCBIcVfE](https://youtu.be/O56uCBIcVfE)**

## Stack

- **Databricks** (Unity Catalog + SQL Warehouse serverless) como data warehouse.
- **dbt Cloud** para transformação, testes e documentação.
- **Looker Studio** como camada de BI.
