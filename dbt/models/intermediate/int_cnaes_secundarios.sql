SELECT    
    cs.sk_estabelecimento,
    cs.fk_cnae,
    'SECUNDÁRIO' AS tipo_cnae,
    current_timestamp() AS data_processamento
FROM (
    SELECT         
        sk_id AS sk_estabelecimento,
        explode(array_distinct(split(cnae_fiscal_secundaria, ','))) AS fk_cnae
    FROM {{ ref('int_estabelecimentos') }}    
    WHERE cnae_fiscal_secundaria IS NOT NULL
) AS cs
JOIN {{ ref('int_cnaes') }} c ON c.codigo = cs.fk_cnae
LEFT JOIN {{ ref('int_cnaes_principais') }} cp ON cp.sk_estabelecimento = cs.sk_estabelecimento AND cp.fk_cnae = cs.fk_cnae
WHERE cp.sk_estabelecimento IS NULL