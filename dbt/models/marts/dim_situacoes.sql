SELECT
    DISTINCT
    CAST(DENSE_RANK() OVER(ORDER BY e.identificador_matriz_filial,e.situacao_cadastral,e.motivo_situacao_cadastral,e.situacao_especial) AS INTEGER) AS sk_id,
    te.codigo AS codigo_identificador_matriz_filial,
    te.descricao AS identificador_matriz_filial,
    sc.codigo AS codigo_situacao_cadastral,    
    sc.descricao AS situacao_cadastral,    
    scm.codigo AS codigo_motivo_situacao_cadastral,
    scm.descricao AS motivo_situacao_cadastral,    
    se.codigo AS codigo_situacao_especial,
    se.descricao AS situacao_especial,        
    current_timestamp() AS data_processamento
FROM {{ ref('int_estabelecimentos') }} e
JOIN {{ ref('int_tipos_estabelecimentos') }} te ON te.codigo = e.identificador_matriz_filial
JOIN {{ ref('int_situacoes_cadastrais') }} sc ON sc.codigo = e.situacao_cadastral
JOIN {{ ref('int_situacoes_cadastrais_motivos') }} scm ON scm.codigo = e.motivo_situacao_cadastral
JOIN {{ ref('int_situacoes_especiais') }} se ON se.codigo = e.situacao_especial