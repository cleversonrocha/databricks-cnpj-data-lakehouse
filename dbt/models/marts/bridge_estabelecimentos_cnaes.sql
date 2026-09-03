WITH cnaes AS (
    SELECT sk_estabelecimento, fk_cnae, tipo_cnae FROM {{ ref('int_cnaes_principais') }}
    UNION ALL
    SELECT sk_estabelecimento, fk_cnae, tipo_cnae FROM {{ ref('int_cnaes_secundarios') }}
)

SELECT 
    sk_estabelecimento,
    dc.sk_id AS sk_cnae,
    tipo_cnae,
    NOW() AS data_processamento
FROM cnaes c
JOIN {{ ref('dim_cnaes') }} dc ON dc.codigo = c.fk_cnae