SELECT    
    _c0 AS cnpj_basico,        
    _c1 AS razao_social,
    CAST(_c2 AS SMALLINT) AS natureza_juridica,
    CAST(_c3 AS TINYINT) AS qualificacao_responsavel,    
    TRY_CAST(REPLACE(_c4, ',', '.') AS DECIMAL(15, 2)) AS capital_social,
    CAST(_c5 AS TINYINT) AS porte_empresa,
    _c6 AS ente_federativo_responsavel,        
    current_timestamp() AS data_processamento
FROM {{ source('silver', 'raw_empresas') }}