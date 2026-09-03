SELECT    
    cnpj_basico,        
    opcao_simples,        
    data_opcao_simples,
    data_exclusao_simples,
    opcao_mei,
    data_opcao_mei,
    data_exclusao_mei,
    current_timestamp() AS data_processamento
FROM {{ ref('stg_simples') }}