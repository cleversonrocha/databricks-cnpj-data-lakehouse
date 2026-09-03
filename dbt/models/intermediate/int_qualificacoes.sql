WITH qualificacoes AS (
    SELECT 
        codigo,
        CAST(descricao AS STRING) AS descricao
    FROM {{ ref('stg_qualificacoes') }}

    UNION ALL

    SELECT
        -1 AS codigo,
        CAST('NÃO INFORMADO' AS STRING) AS descricao

    UNION ALL

    SELECT
        -2 AS codigo,
        CAST('NÃO IDENTIFICADO' AS STRING) AS descricao
)

SELECT    
    CAST(codigo AS TINYINT) AS codigo,
    descricao,
    current_timestamp() AS data_processamento
FROM qualificacoes