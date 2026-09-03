SELECT    
    _c0 AS cnpj_basico,
    _c1 AS opcao_simples,    
    CAST(TRY_TO_TIMESTAMP(_c2, 'yyyyMMdd') AS DATE) AS data_opcao_simples,        
    CAST(TRY_TO_TIMESTAMP(_c3, 'yyyyMMdd') AS DATE) AS data_exclusao_simples,
    _c4 AS opcao_mei,        
    CAST(TRY_TO_TIMESTAMP(_c5, 'yyyyMMdd') AS DATE) AS data_opcao_mei,     
    CAST(TRY_TO_TIMESTAMP(_c6, 'yyyyMMdd') AS DATE) AS data_exclusao_mei,    
    current_timestamp() AS data_processamento
FROM {{ source('silver','raw_simples') }}