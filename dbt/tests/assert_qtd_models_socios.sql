-- tests/assert_qtd_models_socios.sql
WITH qtd_staging AS (
    SELECT        
        COUNT(cnpj_basico) as qtd
    FROM {{ ref('stg_socios') }}    
),
qtd_intermediate AS (
    SELECT        
        COUNT(cnpj_basico) as qtd
    FROM {{ ref('int_socios') }}    
)

SELECT    
    qtd_staging.qtd,
    qtd_intermediate.qtd
FROM qtd_staging
CROSS JOIN qtd_intermediate
WHERE qtd_staging.qtd != qtd_intermediate.qtd