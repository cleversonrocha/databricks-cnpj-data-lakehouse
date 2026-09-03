SELECT
    bec.sk_cnae,
    e.sk_tempo_inicio_atividade,    
    e.sk_situacoes,
    e.sk_localidades,    
    bec.tipo_cnae, 
    CAST(COUNT(bec.sk_cnae) AS SMALLINT) AS qtd_cnaes
FROM {{ ref('fact_estabelecimentos') }} e
JOIN {{ ref('bridge_estabelecimentos_cnaes') }} bec ON e.sk_estabelecimento = bec.sk_estabelecimento
GROUP BY
    e.sk_tempo_inicio_atividade,    
    e.sk_situacoes,
    e.sk_localidades,
    bec.sk_cnae,    
    bec.tipo_cnae