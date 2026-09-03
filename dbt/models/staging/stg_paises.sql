SELECT
    CAST(_c0 AS SMALLINT) AS codigo,        
    _c1 AS descricao,
    current_timestamp() AS data_processamento
FROM {{ source('silver','raw_paises') }}