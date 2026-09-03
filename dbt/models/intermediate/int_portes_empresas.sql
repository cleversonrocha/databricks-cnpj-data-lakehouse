WITH portes_empresas_distintas AS (
    SELECT
        DISTINCT
        porte_empresa AS codigo,
        CASE 
            WHEN porte_empresa = 1 THEN 'ME'
            WHEN porte_empresa = 3 THEN 'EPP'
            WHEN porte_empresa = 5 THEN 'DEMAIS'            
        END AS sigla,
        CASE             
            WHEN porte_empresa = 1 THEN 'MICRO EMPRESA'
            WHEN porte_empresa = 3 THEN 'EMPRESA DE PEQUENO PORTE'
            WHEN porte_empresa = 5 THEN 'DEMAIS'            
        END AS descricao
    FROM {{ ref('stg_empresas') }}
    WHERE porte_empresa IS NOT NULL

    UNION ALL

    SELECT -1 AS codigo, 'NÃO INF.' AS sigla, 'NÃO INFORMADO' AS descricao

    UNION ALL

    SELECT -2 AS codigo, 'NÃO IDENT.' AS sigla, 'NÃO IDENTIFICADO' AS descricao
)

SELECT        
    CAST(codigo AS TINYINT) AS codigo,
    sigla,
    descricao,
    current_timestamp() AS data_processamento
FROM portes_empresas_distintas