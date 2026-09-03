SELECT
    e.sk_id AS sk_estabelecimento,        
    COALESCE(CAST(date_format(e.data_inicio_atividade, 'yyyyMMdd') AS INT), -1) AS sk_tempo_inicio_atividade,    
    COALESCE(CAST(date_format(e.data_situacao_especial, 'yyyyMMdd') AS INT), -1) AS sk_tempo_situacoes_especiais,
    COALESCE(CAST(date_format(e.data_situacao_cadastral, 'yyyyMMdd') AS INT), -1) AS sk_tempo_situacoes_cadastrais,   
    s.sk_id AS sk_situacoes,
    l.sk_id AS sk_localidades,    
    nj.sk_id AS sk_naturezas_juridicas,
    CAST(CASE WHEN e.identificador_matriz_filial = 1 THEN 1 ELSE 0 END AS TINYINT) AS is_matriz,
    CAST(CASE WHEN e.identificador_matriz_filial = 2 THEN 1 ELSE 0 END AS TINYINT) AS is_filial,    
    CAST(CASE WHEN dc.codigo_porte_empresa = 1 THEN 1 ELSE 0 END AS TINYINT) AS is_me,
    CAST(CASE WHEN dc.codigo_porte_empresa = 3 THEN 1 ELSE 0 END AS TINYINT) AS is_epp,
    CAST(CASE WHEN dc.codigo_porte_empresa = 5 THEN 1 ELSE 0 END AS TINYINT) AS is_demais,
    CAST(CASE WHEN dc.opcao_simples = 'S' THEN 1 ELSE 0 END AS TINYINT) AS is_simples,
    CAST(CASE WHEN dc.opcao_mei = 'S' THEN 1 ELSE 0 END AS TINYINT) AS is_mei,
    CAST(CASE WHEN e.situacao_cadastral = 1 THEN 1 ELSE 0 END AS TINYINT) AS is_nula,
    CAST(CASE WHEN e.situacao_cadastral = 2 THEN 1 ELSE 0 END AS TINYINT) AS is_ativa,
    CAST(CASE WHEN e.situacao_cadastral = 3 THEN 1 ELSE 0 END AS TINYINT) AS is_suspensa,
    CAST(CASE WHEN e.situacao_cadastral = 4 THEN 1 ELSE 0 END AS TINYINT) AS is_inapta,
    CAST(CASE WHEN e.situacao_cadastral = 8 THEN 1 ELSE 0 END AS TINYINT) AS is_baixada,
    current_timestamp() AS data_processamento
FROM {{ ref('int_estabelecimentos') }} e
JOIN {{ ref('dim_cadastro') }} dc ON dc.sk_id = e.sk_id
JOIN {{ ref('dim_naturezas_juridicas') }} nj ON nj.codigo = dc.codigo_natureza_juridica
JOIN {{ ref('dim_situacoes') }} s ON s.codigo_identificador_matriz_filial = e.identificador_matriz_filial
    AND s.codigo_situacao_cadastral = e.situacao_cadastral
    AND s.codigo_motivo_situacao_cadastral = e.motivo_situacao_cadastral
    AND s.codigo_situacao_especial = e.situacao_especial
JOIN {{ ref('dim_localidades') }} l ON l.codigo_municipio = e.municipio
    AND l.codigo_cidade_exterior = e.cidade_exterior
    AND l.codigo_uf = e.uf
    AND l.codigo_pais = e.pais