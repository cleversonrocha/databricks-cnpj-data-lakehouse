WITH cnaes AS (
    SELECT        
        codigo,
        CASE 
            WHEN LENGTH(codigo) = 7 THEN
                SUBSTR(codigo, 1, 2) || '.' ||
                SUBSTR(codigo, 3, 2) || '-' ||
                SUBSTR(codigo, 5, 1) || '-' ||
                SUBSTR(codigo, 6, 2)
            ELSE codigo 
        END AS codigo_formatado,
        descricao
    FROM {{ ref('stg_cnaes') }}    

    UNION ALL

    SELECT '-1' AS codigo, '--1' AS codigo_formatado, 'NÃO INFORMADO' AS descricao

    UNION ALL

    SELECT '-2' AS codigo, '--2' AS codigo_formatado,'NÃO IDENTIFICADO' AS descricao
)

SELECT    
    codigo,
    codigo_formatado,
    descricao,    
    current_timestamp() AS data_processamento
FROM cnaes