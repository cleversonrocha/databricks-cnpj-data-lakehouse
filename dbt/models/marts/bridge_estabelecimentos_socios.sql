SELECT        
    e.sk_id AS sk_estabelecimento,
    s.sk_id AS sk_socio,        
    current_timestamp() AS data_processamento
FROM {{ ref('int_estabelecimentos') }} e
JOIN {{ ref('int_empresas') }} em ON em.cnpj_basico = e.cnpj_basico
JOIN {{ ref('int_socios') }} s ON s.cnpj_basico = em.cnpj_basico