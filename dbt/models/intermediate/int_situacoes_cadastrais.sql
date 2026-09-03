WITH situacao_cadastral_distintas AS (
    SELECT DISTINCT situacao_cadastral 
    FROM {{ ref('stg_estabelecimentos') }}
    WHERE situacao_cadastral IS NOT NULL
),

situacao_cadastral_codificada AS (
    SELECT                
        situacao_cadastral AS codigo,
        CASE 
            WHEN situacao_cadastral = 1 THEN 'NULA'
            WHEN situacao_cadastral = 2 THEN 'ATIVA'
            WHEN situacao_cadastral = 3 THEN 'SUSPENSA'
            WHEN situacao_cadastral = 4 THEN 'INAPTA'
            WHEN situacao_cadastral = 8 THEN 'BAIXADA'        
        END AS descricao
    FROM 
        situacao_cadastral_distintas

    UNION ALL

    SELECT -1 AS codigo, 'NÃO INFORMADO' AS descricao

    UNION ALL

    SELECT -2 AS codigo, 'NÃO IDENTIFICADO' AS descricao
)

SELECT     
    CAST(codigo AS TINYINT) AS codigo,
    descricao,
    current_timestamp() AS data_processamento
FROM situacao_cadastral_codificada