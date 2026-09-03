WITH paises AS (
    SELECT 
        codigo,
        descricao        
    FROM {{ ref('stg_paises') }}

    UNION ALL

    SELECT
        -1 AS codigo,
        'NÃO INFORMADO' AS descricao

    UNION ALL

    SELECT
        -2 AS codigo,
        'NÃO IDENTIFICADO' AS descricao
)

SELECT    
    CAST(codigo AS SMALLINT) AS codigo,
    descricao,
    current_timestamp() AS data_processamento
FROM paises