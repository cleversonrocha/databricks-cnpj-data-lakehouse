WITH tipos_pessoas_distintas AS (
    SELECT
        DISTINCT
        identificador AS codigo,
        CASE identificador    	
            WHEN 1 THEN 'PESSOA FÍSICA'
            WHEN 2 THEN 'PESSOA JURÍDICA'
            WHEN 3 THEN 'ESTRANGEIRO'            
        END AS descricao
    FROM {{ ref('stg_socios') }}
    WHERE identificador IS NOT NULL    

    UNION ALL

    SELECT -1 AS codigo, 'NÃO INFORMADO'

    UNION ALL

    SELECT -2 AS codigo, 'NÃO IDENTIFICADO'
)

SELECT    
    CAST(codigo AS TINYINT) AS codigo,
    descricao,
    current_timestamp() AS data_processamento 
FROM tipos_pessoas_distintas