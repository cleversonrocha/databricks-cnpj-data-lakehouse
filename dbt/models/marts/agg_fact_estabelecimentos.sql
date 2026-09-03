SELECT
    e.sk_tempo_inicio_atividade,    
    e.sk_situacoes,
    e.sk_localidades,
    e.sk_naturezas_juridicas,    
    CAST(SUM(is_matriz) AS SMALLINT) AS qtd_matrizes,
    CAST(SUM(is_filial) AS SMALLINT) AS qtd_filiais,
    CAST(SUM(is_nula) AS SMALLINT) AS qtd_nulas,
    CAST(SUM(is_ativa) AS SMALLINT) AS qtd_ativas,
    CAST(SUM(is_suspensa) AS SMALLINT) AS qtd_suspensas,
    CAST(SUM(is_inapta) AS SMALLINT) AS qtd_inaptas,
    CAST(SUM(is_baixada) AS SMALLINT) AS qtd_baixadas,    
    CAST(SUM(is_epp) AS SMALLINT) AS qtd_epp,
    CAST(SUM(is_me) AS SMALLINT) AS qtd_me,
    CAST(SUM(is_demais) AS SMALLINT) AS qtd_demais,
    CAST(SUM(is_mei) AS SMALLINT) AS qtd_mei,
    CAST(COUNT(sk_estabelecimento) AS SMALLINT) AS qtd_estabelecimentos
FROM {{ ref('fact_estabelecimentos') }} e
GROUP BY
    e.sk_tempo_inicio_atividade,    
    e.sk_situacoes,
    e.sk_localidades,
    e.sk_naturezas_juridicas