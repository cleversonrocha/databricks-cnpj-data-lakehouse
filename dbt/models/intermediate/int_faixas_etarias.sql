WITH faixas_etarias_distintas AS (
    SELECT
        DISTINCT
        faixa_etaria_socio AS codigo,
        CASE 
            WHEN faixa_etaria_socio = 1 THEN '0 a 12 anos' 
            WHEN faixa_etaria_socio = 2 THEN '13 a 20 anos' 
            WHEN faixa_etaria_socio = 3 THEN '21 a 30 anos' 
            WHEN faixa_etaria_socio = 4 THEN '31 a 40 anos' 
            WHEN faixa_etaria_socio = 5 THEN '41 a 50 anos' 
            WHEN faixa_etaria_socio = 6 THEN '51 a 60 anos' 
            WHEN faixa_etaria_socio = 7 THEN '61 a 70 anos' 
            WHEN faixa_etaria_socio = 8 THEN '71 a 80 anos' 
            WHEN faixa_etaria_socio = 9 THEN 'maiores de 80 anos' 
            WHEN faixa_etaria_socio = 0 THEN 'não se aplica'            
        END AS descricao    
    FROM {{ ref('stg_socios') }}
    WHERE faixa_etaria_socio IS NOT NULL

    UNION ALL

    SELECT -1 AS codigo,'não informado' AS descricao

    UNION ALL

    SELECT -2 AS codigo,'não identificado' AS descricao
)

SELECT    
    CAST(codigo AS TINYINT) AS codigo,
    descricao,    
    current_timestamp() AS data_processamento
FROM faixas_etarias_distintas