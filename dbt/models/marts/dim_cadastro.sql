SELECT
    e.sk_id,    
    SUBSTR(e.cnpj_basico, 1, 2) || '.' || SUBSTR(e.cnpj_basico, 3, 3) || '.' || SUBSTR(e.cnpj_basico, 6, 3) || '/' || e.cnpj_ordem || '-' || e.cnpj_dv AS cnpj_completo,    
    te.descricao AS identificador_matriz_filial,
    data_inicio_atividade AS data_abertura,                
    em.razao_social,
    e.nome_fantasia,
    pe.codigo AS codigo_porte_empresa,
    pe.descricao AS porte_empresa,
    em.capital_social,
    nj.codigo AS codigo_natureza_juridica,   
    nj.codigo_formatado || ' - ' || nj.descricao AS natureza_juridica,    
    e.tipo_logradouro || ' ' || e.logradouro AS logradouro,    
    e.numero,    
    e.complemento,    
    CASE 
        WHEN e.cep IS NULL THEN e.cep
        ELSE SUBSTR(e.cep, 1, 5) || '-' || SUBSTR(e.cep, 6, 3)
    END AS cep,
    e.bairro,
    mu.descricao AS municipio,
    u.sigla AS uf,
    u.regiao,
    p.descricao AS pais,   
    ce.descricao AS cidade_exterior,
    e.email,
    CASE 
        WHEN ddd_1 IS NULL OR telefone_1 IS NULL THEN NULL
        ELSE '(' || e.ddd_1 || ') ' || 
            CASE 
                WHEN LENGTH(REGEXP_REPLACE(e.telefone_1, '\D', '')) = 9            
                    THEN REGEXP_REPLACE(REGEXP_REPLACE(e.telefone_1, '\D', ''), '^(\d{5})(\d{4})$', '\1-\2')
                WHEN LENGTH(REGEXP_REPLACE(e.telefone_1, '\D', '')) = 8             
                    THEN REGEXP_REPLACE(REGEXP_REPLACE(e.telefone_1, '\D', ''), '^(\d{4})(\d{4})$', '\1-\2')
                ELSE e.telefone_1
            END
    END AS telefone_1,
    CASE 
        WHEN ddd_2 IS NULL OR telefone_2 IS NULL THEN NULL
        ELSE '(' || e.ddd_2 || ') ' || 
            CASE 
                WHEN LENGTH(REGEXP_REPLACE(e.telefone_2, '\D', '')) = 9            
                    THEN REGEXP_REPLACE(REGEXP_REPLACE(e.telefone_2, '\D', ''), '^(\d{5})(\d{4})$', '\1-\2')
                WHEN LENGTH(REGEXP_REPLACE(e.telefone_2, '\D', '')) = 8             
                    THEN REGEXP_REPLACE(REGEXP_REPLACE(e.telefone_2, '\D', ''), '^(\d{4})(\d{4})$', '\1-\2')
                ELSE e.telefone_2
            END
    END AS telefone_2,
    CASE 
        WHEN ddd_fax IS NULL OR fax IS NULL THEN NULL
        ELSE '(' || e.ddd_fax || ') ' || 
            CASE 
                WHEN LENGTH(REGEXP_REPLACE(e.fax, '\D', '')) = 9             
                    THEN REGEXP_REPLACE(REGEXP_REPLACE(e.fax, '\D', ''), '^(\d{5})(\d{4})$', '\1-\2')
                WHEN LENGTH(REGEXP_REPLACE(e.fax, '\D', '')) = 8             
                    THEN REGEXP_REPLACE(REGEXP_REPLACE(e.fax, '\D', ''), '^(\d{4})(\d{4})$', '\1-\2')
                ELSE e.fax
            END
    END AS fax,  
    ef.descricao AS ente_federativo_responsavel,
    sc.descricao AS situacao_cadastral,
    scm.descricao AS motivo_situacao_cadastral,
    e.data_situacao_cadastral,
    se.descricao AS situacao_especial,
    e.data_situacao_especial,
    s.opcao_simples,
    s.opcao_mei,
    current_timestamp() AS data_processamento
FROM {{ ref('int_estabelecimentos') }} e
JOIN {{ ref('int_tipos_estabelecimentos') }} te ON te.codigo = e.identificador_matriz_filial
JOIN {{ ref('int_situacoes_cadastrais') }} sc ON sc.codigo = e.situacao_cadastral
JOIN {{ ref('int_situacoes_cadastrais_motivos') }} scm ON scm.codigo = e.motivo_situacao_cadastral
JOIN {{ ref('int_cidades_exterior') }} ce ON ce.codigo = e.cidade_exterior
JOIN {{ ref('int_paises') }} p ON p.codigo = e.pais
JOIN {{ ref('int_ufs') }} u ON u.codigo = e.uf
JOIN {{ ref('int_municipios') }} mu ON mu.codigo = e.municipio
JOIN {{ ref('int_situacoes_especiais') }} se ON se.codigo = e.situacao_especial
JOIN {{ ref('int_empresas') }} em ON em.cnpj_basico = e.cnpj_basico
JOIN {{ ref('int_naturezas') }} nj ON nj.codigo = em.natureza_juridica
JOIN {{ ref('int_portes_empresas') }} pe ON pe.codigo = em.porte_empresa
JOIN {{ ref('int_entes_federativos') }} ef ON ef.codigo = em.ente_federativo_responsavel
LEFT JOIN {{ ref('int_simples') }} s ON s.cnpj_basico = e.cnpj_basico