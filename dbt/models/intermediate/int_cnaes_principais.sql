SELECT 
    e.sk_id AS sk_estabelecimento,
    c.codigo AS fk_cnae,
    'PRINCIPAL' AS tipo_cnae,
    current_timestamp() AS data_processamento
FROM {{ ref('int_estabelecimentos') }} e
JOIN {{ ref('int_cnaes') }} c ON c.codigo = e.cnae_fiscal_principal