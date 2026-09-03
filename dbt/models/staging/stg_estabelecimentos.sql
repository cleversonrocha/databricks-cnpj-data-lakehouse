SELECT    
    _c0 AS cnpj_basico,
    _c1 AS cnpj_ordem,
    _c2 AS cnpj_dv,
    CASE 
        WHEN _c0 = '08314885' AND _c1 = '0051' AND _c2 = '74' THEN CAST(2 AS TINYINT)
        ELSE CAST(_c3 AS TINYINT)
    END AS identificador_matriz_filial,
    _c4 AS nome_fantasia,
    CAST(_c5 AS TINYINT) AS situacao_cadastral,    
    CAST(TRY_TO_TIMESTAMP(_c6, 'yyyyMMdd') AS DATE) AS data_situacao_cadastral,
    CAST(_c7 AS TINYINT) AS motivo_situacao_cadastral,
    _c8 AS cidade_exterior,
    CAST(_c9 AS SMALLINT) AS pais,        
    TRY_CAST(TRY_TO_TIMESTAMP(_c10, 'yyyyMMdd') AS DATE) AS data_inicio_atividade,            
    _c11 AS cnae_fiscal_principal,
    array_join(
        array_distinct(
            transform(split(_c12, ','), x -> TRIM(x))
        ), ','
    ) AS cnae_fiscal_secundaria, 
    _c13 AS tipo_logradouro,
    _c14 AS logradouro,    
    _c15 AS numero,    
    _c16 AS complemento,
    _c17 AS bairro,    
    REGEXP_REPLACE(_c18, '[^0-9]', '') AS cep,
    _c19 AS uf,
    CAST(_c20 AS SMALLINT) AS municipio,
    REGEXP_REPLACE(_c21, '[^0-9]', '') AS ddd_1,
    REGEXP_REPLACE(_c22, '[^0-9]', '') AS telefone_1,
    REGEXP_REPLACE(_c23, '[^0-9]', '') AS ddd_2,
    REGEXP_REPLACE(_c24, '[^0-9]', '') AS telefone_2,
    REGEXP_REPLACE(_c25, '[^0-9]', '') AS ddd_fax,
    REGEXP_REPLACE(_c26, '[^0-9]', '') AS fax,
    _c27 AS email,
    _c28 AS situacao_especial,    
    TRY_CAST(TRY_TO_TIMESTAMP(_c29, 'yyyyMMdd') AS DATE) AS data_situacao_especial,                   
    current_timestamp() AS data_processamento
FROM {{ source('silver', 'raw_estabelecimentos') }}