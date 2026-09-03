WITH entes_federativos AS (
    SELECT DISTINCT ente_federativo_responsavel  
    FROM {{ ref('stg_empresas') }}
    WHERE ente_federativo_responsavel IS NOT NULL
),

entes_federativos_codificada AS (
    SELECT        
        ROW_NUMBER() OVER (ORDER BY ente_federativo_responsavel) AS codigo,
        ente_federativo_responsavel AS descricao
    FROM entes_federativos

    UNION ALL

    SELECT -1 AS codigo,'NÃO INFORMADO' AS descricao

    UNION ALL

    SELECT -2 AS codigo,'NÃO IDENTIFICADO' AS descricao
)

SELECT    
    CAST(codigo AS SMALLINT) AS codigo,    
    descricao,    
    current_timestamp() AS data_processamento
FROM entes_federativos_codificada