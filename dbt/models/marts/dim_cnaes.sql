SELECT 
    CAST(ROW_NUMBER() OVER(ORDER BY codigo) AS SMALLINT) AS sk_id,
    codigo,
    codigo_formatado,
    descricao,
    current_timestamp() AS data_processamento 
FROM {{ ref('int_cnaes') }}