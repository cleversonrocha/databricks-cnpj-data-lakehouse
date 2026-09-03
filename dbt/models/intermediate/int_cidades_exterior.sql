WITH cidade_exterior_distintas AS (
    SELECT DISTINCT cidade_exterior 
    FROM {{ ref('stg_estabelecimentos') }}
    WHERE cidade_exterior IS NOT NULL
),

cidade_exterior_codificada AS (
    SELECT        
        ROW_NUMBER() OVER (ORDER BY cidade_exterior) AS codigo,
        cidade_exterior AS descricao
    FROM cidade_exterior_distintas

    UNION ALL

    SELECT -1 AS codigo,'NÃO INFORMADO' AS descricao

    UNION ALL

    SELECT -2 AS codigo,'NÃO IDENTIFICADO' AS descricao
)

SELECT    
    CAST(codigo AS SMALLINT) AS codigo,
    descricao,    
    current_timestamp() AS data_processamento
FROM cidade_exterior_codificada