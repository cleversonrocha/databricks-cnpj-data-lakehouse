WITH tipos_estabelecimentos_distintos AS (
    SELECT DISTINCT identificador_matriz_filial 
    FROM {{ ref('stg_estabelecimentos') }}
    WHERE identificador_matriz_filial IS NOT NULL
),

tipos_estabelecimentos_codificada AS (
    SELECT        
        identificador_matriz_filial AS codigo,
        CASE        
            WHEN identificador_matriz_filial = 1 THEN 'MATRIZ'
            WHEN identificador_matriz_filial = 2 THEN 'FILIAL'            
        END AS descricao
    FROM 
        tipos_estabelecimentos_distintos
    
    UNION ALL

    SELECT -1 AS codigo, 'NÃO INFORMADO' AS descricao

    UNION ALL

    SELECT -2 AS codigo, 'NÃO IDENTIFICADO' AS descricao
)

SELECT
    CAST(codigo AS TINYINT) AS codigo,
    descricao,
    current_timestamp() AS data_processamento
FROM tipos_estabelecimentos_codificada