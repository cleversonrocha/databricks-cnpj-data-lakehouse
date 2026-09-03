# CNPJ Data Lakehouse v2 - 100% Databricks Free Edition

Pipeline de dados completo (ingestão → bronze → silver → gold) construído inteiramente sobre a Databricks Free Edition com Unity Catalog e dbt Core, usando os dados públicos do Cadastro Nacional da Pessoa Jurídica (CNPJ) disponibilizados pela Receita Federal do Brasil (167M+ registros).

Esta é a segunda versão de um projeto de portfólio pessoal originalmente construído com stack local (Airflow + DuckDB + dbt Core + MinIO + Databricks + Power BI). Nesta versão, todo o pipeline, ingestão, transformação e orquestração, rodam nativamente na plataforma Databricks, sem dependências locais.

## Motivação

Este projeto integra minha transição de carreira para as áreas de Engenharia de Dados, após 15+ anos de experiência com bancos de dados relacionais. 
Além de servir como portfólio, o projeto esta sendo usado como estudo prático para reforçar conceitos cobrados na certificação **Databricks Data Engineer Associate**.

> A versão anterior (100% local, rodando via Docker) segue disponível no repositório [`cnpj-data-lakehouse`](https://github.com/cleversonrocha/cnpj-data-lakehouse) para referência de arquitetura híbrida.

## Arquitetura

![login](imagens/arquitetura_medalhao_databricks.svg)

## Stack

| Camada | Ferramenta |
|---|---|
| Armazenamento / Ingestão | Databricks Unity Catalog Volumes |
| Processamento | PySpark (notebooks Databricks) |
| Transformação / Modelagem | dbt Core [(Link da documentação)](https://cleversonrocha.github.io/databricks-cnpj-data-lakehouse/) |
| Catálogo de dados | Unity Catalog |
| Formato de tabela | Delta Lake (liquid clustering) |
| Orquestração | Databricks Workflows |

## Fonte de dados

Dados públicos do Cadastro Nacional de Pessoas Jurídicas da Receita Federal, extraídos do [Portal Dados Abertos do Governo Federal](https://dados.gov.br/dados/conjuntos-dados/cadastro-nacional-da-pessoa-juridica---cnpj), atualizados mensalmente.

## Camada Bronze → Silver

Os arquivos `.zip` (incluindo zips aninhados) são descompactados com a biblioteca `zipfile` com uma função recursiva em Python, organizados em volumes particionados por competência (`bronze/{YYYY_MM}`). Os CSVs são então lidos com schema explícito (separador `;`, encoding `ISO-8859-1`, sem header) e gravados como tabelas Delta na camada `silver`, uma por entidade, cada uma com uma coluna `dt_processamento` para rastreabilidade da carga.

## Camada Gold — Modelo Dimensional (dbt Core)

Star Schema construída com dbt Core via Databricks:

- **Fatos:** `fact_estabelecimentos` (72M+ linhas)
- **Dimensões:** `dim_cadastro`, `dim_cnaes`, `dim_localidades`, `dim_naturezas_juridicas`, `dim_situacoes`, `dim_socios`, `dim_tempo_inicio_atividades`, `dim_tempo_situacoes_cadastrais`, `dim_tempo_situacoes_especiais`
- **Bridges:** `bridge_estabelecimentos_cnaes`, `bridge_estabelecimentos_socios`
- **Agregações pré-computadas:** `agg_fact_estabelecimentos`, `agg_fact_estabelecimentos_cnaes`

Os models seguem o padrão de dimensão *"unknown member"*: joins com as dimensões usam `LEFT JOIN` (não `INNER JOIN`), com `CASE` mapeando valores nulos/não encontrados para códigos -1 (NÃO INFORMADO) e -2 (NÃO IDENTIFICADO), preservando a granularidade do fato mesmo com dados de origem incompletos.

### Modificações de portabilidade DuckDB → Spark SQL

A versão anterior do projeto usava dbt Core + DuckDB localmente. Na migração para dbt Core + Databricks, os seguintes ajustes foram necessários nos models:

| DuckDB (v1) | Databricks / Spark SQL (v2) |
|---|---|
| `UNNEST(list_distinct(string_split(...)))` | `LATERAL VIEW explode(array_distinct(transform(split(...), x -> trim(x))))` |
| `STRFTIME(...)` | `DATE_FORMAT(...)` (ordem dos argumentos invertida) |
| `EXTRACT(DOW FROM ...)` | `dayofweek(...)` |
| `generate_series(...)` | `sequence(...)` + `explode(...)` |
| `REGEXP_REPLACE(..., 'g')` | `REGEXP_REPLACE(...)` (Spark já é global por padrão — 4º argumento removido) |
| `NOW()` | `current_timestamp()` |

Além disso, em `schema.yml` com contratos (`contract: enforced`), foi necessário trocar `data_type: varchar` → `string` e `timestamptz` → `timestamp` (tipos sem tamanho/timezone geram DDL inválida no Databricks), e adicionar `CAST` explícito em branches de `CASE` que misturavam tipos (ex.: `int_estabelecimentos.sql`, coluna `pais`), já que o Spark infere o tipo mais amplo entre os branches e isso quebra a validação de contrato.

A macro `generate_schema_name` também foi sobrescrita para usar apenas o `custom_schema_name` (sem concatenar com `target.schema`), evitando schemas duplicados como `silver_silver`.

## Orquestração (Databricks Workflows)

Job `databricks-cnpj-data-lakehouse-job` com três tasks encadeadas, todas em compute **Serverless**:

![job](imagens/job.png)

- `ingestao_bronze`: Baixa o zip da Receita Federal, valida e descompacta.
- `ingestao_silver`: Lê os CSVs da bronze e grava as tabelas Delta na silver.
- `dbt_silver_and_gold`: Executa os comandos "dbt deps" para instalar os pacotes e dependências e "dbt build" para rodar modelos e testes, cria tabelas Delta na silver com os dados brutos da Bronze, limpa e trata os dados gerando novas tabelas e finaliza criando um modelo Star Schema na camada Gold.

## Passo a passo para executar o projeto

1. **Criar/acessar uma conta Databricks Free Edition**.

     Acesse: https://login.databricks.com/
     ![Login ou Criar conta](imagens/1.png)

2. No menu lateral do Databricks, clique em "SQL Editor" e depois do lado direito em "SQL Query":

     ![SQL Query](imagens/2.png)

3. Na aba "New Query...", digite "CREATE CATALOG IF NOT EXISTS databricks_cnpj_data_lakehouse;" e clique no botão "Run all (1000)":
     
     ![Criar catálogo](imagens/3.png)

4. No menu lateral do Databricks, clique em Workspace:
     
     ![Menu Workspace](imagens/4.png)
     
5. Vá até a pasta "Repos":

     ![Pasta Repo](imagens/5.png)

6. Clique com o botão direito em cima da pasta "Repos" e clique em "Create -> Folder":

     ![Create Folder](imagens/6.png)

7. Coloque o nome "databbricks-cnpj-data-lakehouse" e clique em "Create":

     ![Create](imagens/7.png)

8. Depois clique em cima da pasta criada "databbricks-cnpj-data-lakehouse", e clique "Create -> Repo":

     ![Menu Create Repo](imagens/8.png)

9. No campo Git repository URL, cole o link do repositório "https://github.com/cleversonrocha/databricks-cnpj-data-lakehouse" e clique em "Create Repo":

     ![Botão Create Repo](imagens/9.png)

10. No menu lateral do Databricks, clique em "Jobs & Pipelines":

     ![Menu Jobs & Pipelines](imagens/10.png)

11. Do lado direito da tela, clique no botão "Create -> Job":

     ![Botão Create Job](imagens/11.png)

12. Troque o nome do Job no topo da tela "New Job..." para "databricks-cnpj-data-lakehouse-job":

     ![Nome Job](imagens/12.png)

13. Clique em "+ Add another task type" depois em "Notebook":

     ![Add another task type 1](imagens/13.png)

14. Defina os campos:

     - Task name: ingestao_bronze
     ![Create task](imagens/14.png)

     - Path: Clique no campo e navegue entre as pastas "/Repos/databricks-cnpj-data-lakehouse/databricks-cnpj-data-lakehouse/notebooks/01 - Ingestão dos dados para camada Bronze" e clique no botão "Confirm".          
     ![Create task 12.1](imagens/14.1.png)
     ![Create task 12.2](imagens/14.2.png)

     - Clique no botão "Create task".
     ![Create task 12.3](imagens/14.3.png)

15. Clique novamente em "+ Add task" depois em "Notebook":

     ![Add another task type 2](imagens/15.png)
          
16. Defina os campos:

     - Task name: ingestao_silver
     ![Add another task type 2](imagens/16.png)

     - Path: Clique no campo e navegue entre as pastas "/Repos/databricks-cnpj-data-lakehouse/databricks-cnpj-data-lakehouse/notebooks/02 - Ingestão dos dados para camada Silver" e clique no botão "Confirm".
     ![Create task 12.1](imagens/16.1.png)
     ![Create task 12.2](imagens/16.2.png)

     - Clique no botão "Create task".
     ![Create task 12.2](imagens/16.3.png)

17. Clique novamente em "+ Add task" depois em "dbt":

     ![Add another task type 3](imagens/17.png)

18. Defina os campos:

     - Task name: dbt_silver_and_gold
     ![Add another task type 2](imagens/18.png)

     - Project directory: Clique no campo e navegue entre as pastas "/Repos/databricks-cnpj-data-lakehouse/databricks-cnpj-data-lakehouse/dbt" e clique no botão "Confirm".
     ![Create task 16.1](imagens/18.1.png)
     ![Create task 16.2](imagens/18.2.png)

     - dbt commands:
          - 1: dbt deps
          - 2: Altere "dbt seed" para "dbt build"          
          - Clique no botão "X" ao lado do comando "dbt run".
     ![Create task 16.3](imagens/18.3.png)

     - SQL Wrehouse: Serverless Starter Warehouse (2XS)
          - Warehouse catalog: databricks_cnpj_data_lakehouse
     ![Create task 16.4](imagens/18.4.png)

     - Clique no botão "Create task".
     ![Create task 16.5](imagens/18.5.png)

19. No canto superior direito clique em "Run now" para executar o Job:

     ![Create task 16.5](imagens/19.png)

20. Acompanhe o processamento clicando em "Jobs & Pipelines" no menu lateral:

     ![Create task 16.5](imagens/20.png)

21. Após o Job terminar verifique os volumes e tabelas criados, clicando no menu lateral "Catalog":

     ![Create task 16.5](imagens/21.png)

## Solução de problemas

**Download do zip falha / arquivo não encontrado na URL da Receita Federal:**
O link de download segue o padrão `.../{ano-mes}/?accept=zip`, e o arquivo do mês só fica disponível alguns dias após o início do mês. Se `baixar_arquivo` falhar após as tentativas de retry, **confirme manualmente se o arquivo da competência já foi publicado** no portal público da Receita Federal antes de assumir que é um problema no script:
👉 https://arquivos.receitafederal.gov.br/index.php/s/YggdBLfdninEJX9

Se o mês ainda não estiver disponível ali, é esperado que o download falhe — não é um bug do pipeline.

```
O pipeline esta configurado para baixar a base de dados de "09/2026", caso queira alterar o mês, altere as variáveis "ano_mes_download" e "ano_mes_pasta", no arquivo "notebooks\01 - Ingestão dos dados para camada Bronze.ipynb" e execute o Job novamente.
```

## Diferenças em relação à v1 (stack local)

| Aspecto | v1 (local) | v2 (100% Databricks) |
|---|---|---|
| Ingestão | Airflow + MinIO | Unity Catalog Volumes |
| Transformação local | DuckDB + dbt Core | PySpark + dbt Core |
| Disponibilidade | Sob demanda (Docker local) | Databricks Free Edition |

## Licença

Dados públicos disponibilizados pela Receita Federal do Brasil. Uso educacional / portfólio.