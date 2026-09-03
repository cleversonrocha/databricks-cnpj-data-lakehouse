SELECT        
    _c0 AS cnpj_basico,        
    CAST(_c1 AS TINYINT) AS identificador,
    _c2 AS nome_razao_social,
    _c3 AS cpf_cnpj,
    CAST(_c4 AS TINYINT) AS qualificacao,    
    CAST(TRY_TO_TIMESTAMP(_c5, 'yyyyMMdd') AS DATE) AS data_entrada_sociedade,    
    CAST(_c6 AS SMALLINT) AS pais,
    _c7 AS representante_legal,
    _c8 AS nome_do_representante,
    CAST(_c9 AS TINYINT) AS qualificacao_representante,
    CAST(_c10 AS TINYINT) AS faixa_etaria_socio,
    current_timestamp() AS data_processamento
FROM {{ source('silver','raw_socios') }}