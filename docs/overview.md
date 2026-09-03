{% docs __overview__ %}

# CNPJ Data Lakehouse v2- 100% Databricks Free Edition

Pipeline de dados completo (ingestão → bronze → silver → gold) construído inteiramente sobre a Databricks Free Edition com Unity Catalog e dbt Core, usando os dados públicos do Cadastro Nacional da Pessoa Jurídica (CNPJ) disponibilizados pela Receita Federal do Brasil (167M+ registros).

Esta é a segunda versão de um projeto de portfólio pessoal originalmente construído com stack local (Airflow + DuckDB + dbt Core + MinIO + Databricks + Power BI). Nesta versão, todo o pipeline, ingestão, transformação e orquestração, rodam nativamente na plataforma Databricks, sem dependências locais.

---

## 🏗️ Arquitetura

| Componente | Papel |
|---|---|
| **Databricks (Unity Catalog)** | Warehouse serverless |
| **dbt Core** | Transformação, testes de dados e modelagem dimensional |

---

## 📐 Modelo Dimensional

Modelo Kimball clássico com uma tabela fato e nove dimensões compartilhadas, além de duas pontes para resolver relacionamentos muitos para muitos e duas agregações pré-calculadas para otimizar performance.

| Tipo | Tabela | Descrição | Quantidade de Registros |
|---|---|---| ---: |
| Fato | `fact_estabelecimentos` | Estabelecimentos (matriz/filiais) | 72.789.638 |
| Dimensão | `dim_cadastro` | Dados cadastrais | 72.789.638 |
| Ponte | `bridge_estabelecimentos_cnaes` | Resolve relacionamento muitos para muitos com dim_cnaes | 196.759.105 |
| Dimensão | `dim_cnaes` | Atividades econômicas dos estabelecimentos | 1.361 |
| Dimensão | `dim_localidades` | Localização geográfica dos estabelecimentos | 12.611 |
| Dimensão | `dim_naturezas_juridicas` | Natureza Jurídica das empresas | 93 |
| Dimensão | `dim_situacoes` | Identificação Matriz/Filial, Situação Cadastral e Especial dos estabelecimentos | 251 |
| Ponte | `bridge_estabelecimentos_socios` | Resolve relacionamentos muitos para muitos com dim_socios | 37.952.710 |
| Dimensão | `dim_socios` | Histórico societário das empresas | 28.146.721 |
| Dimensão | `dim_tempo_inicio_atividades` | Calendário com datas de início das atividades dos estabelecimentos | 49.235 |
| Dimensão | `dim_tempo_situacoes_cadastrais` | Calendário com datas das situações cadastrais dos estabelecimentos | 46.320 |
| Dimensão | `dim_tempo_situacoes_especiais` | Calendário com datas das situações especiais dos estabelecimentos | 21.892 |
| Agregação | `agg_fact_estabelecimentos` | Pré-agregação com tipos dos estabelecimentos, situações cadastrais, portes por início da atividade, situação, localização e natureza jurídica dos estabelecimentos  | 32.630.634 |
| Agregação | `agg_fact_estabelecimentos_cnaes` | Pré-agregação com as atividades econômicas dos estabelecimentos, por data de início da atividade, situações, localização e tipo do CNAE | 166.468.071 |

---

## ⚙️ Camadas do Pipeline

1. **Bronze** — ingestão raw dos arquivos da Receita Federal (layout fixo, sem transformação)
2. **Silver** — limpeza, tipagem, padronização (ex: formatação de telefone via `REGEXP_REPLACE`)
3. **Gold** — star schema final, particionado por competência (`ano_mes`)

---

## 🧩 Macro principal

| Macro | Função |
|---|---|
| `generate_schema_name()` | A macro `generate_schema_name` também foi sobrescrita para usar apenas o `custom_schema_name` (sem concatenar com `target.schema`), evitando schemas duplicados como `silver_silver`. |

---

## 🔗 Links úteis

- [Repositório no GitHub](https://github.com/cleversonrocha/databricks-cnpj-data-lakehouse)

{% enddocs %}