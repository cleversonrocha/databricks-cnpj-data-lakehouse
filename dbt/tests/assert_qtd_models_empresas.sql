-- tests/assert_qtd_models_empresas.sql
WITH qtd_staging AS (
    SELECT        
        COUNT(cnpj_basico) as qtd
    FROM {{ ref('stg_empresas') }}    
),
qtd_intermediate AS (
    SELECT        
        COUNT(cnpj_basico) as qtd
    FROM {{ ref('int_empresas') }}    
),
qtd_nao_qualificadas AS (
    SELECT
        COUNT(cnpj_basico) AS qtd
    FROM {{ ref('int_empresas_nao_qualificadas') }}    
)

SELECT    
    qtd_staging.qtd,
    qtd_intermediate.qtd,    
    qtd_nao_qualificadas.qtd
FROM qtd_staging
CROSS JOIN qtd_intermediate
CROSS JOIN qtd_nao_qualificadas
WHERE (qtd_staging.qtd - qtd_nao_qualificadas.qtd) != qtd_intermediate.qtd