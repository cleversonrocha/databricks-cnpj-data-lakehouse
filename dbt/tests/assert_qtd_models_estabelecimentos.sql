-- tests/assert_qtd_models_estabelecimentos.sql
WITH qtd_staging AS (
    SELECT        
        COUNT(cnpj_basico) as qtd
    FROM {{ ref('stg_estabelecimentos') }}    
),
qtd_intermediate AS (
    SELECT        
        COUNT(cnpj_basico) as qtd
    FROM {{ ref('int_estabelecimentos') }}    
),
qtd_dim_cadastro AS (
    SELECT        
        COUNT(sk_id) as qtd
    FROM {{ ref('dim_cadastro') }}    
),
qtd_marts AS (
    SELECT        
        COUNT(sk_estabelecimento) as qtd
    FROM {{ ref('fact_estabelecimentos') }}    
)

SELECT    
    qtd_staging.qtd,
    qtd_intermediate.qtd,
    qtd_dim_cadastro.qtd,
    qtd_marts.qtd
FROM qtd_staging
CROSS JOIN qtd_intermediate
CROSS JOIN qtd_dim_cadastro
CROSS JOIN qtd_marts
WHERE qtd_staging.qtd != qtd_intermediate.qtd OR qtd_intermediate.qtd != qtd_dim_cadastro.qtd OR qtd_dim_cadastro.qtd != qtd_marts.qtd