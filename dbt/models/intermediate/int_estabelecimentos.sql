SELECT
    CAST(ROW_NUMBER() OVER(ORDER BY cnpj_basico,cnpj_ordem,cnpj_dv) AS INTEGER) AS sk_id,    
    cnpj_basico,
    cnpj_ordem,
    cnpj_dv,        
    CASE
        WHEN identificador_matriz_filial IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
        WHEN te.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO        
        ELSE te.codigo
    END AS identificador_matriz_filial,
    nome_fantasia,
    CASE
        WHEN situacao_cadastral IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
        WHEN sc.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO        
        ELSE sc.codigo
    END AS situacao_cadastral,
    data_situacao_cadastral,        
    CASE
        WHEN motivo_situacao_cadastral IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
        WHEN scm.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO        
        ELSE scm.codigo
    END AS motivo_situacao_cadastral,
    CASE
        WHEN cidade_exterior IS NULL THEN CAST(-1 AS SMALLINT) --NÃO INFORMADO
        WHEN me.codigo IS NULL THEN CAST(-2 AS SMALLINT) --NÃO IDENTIFICADO
        ELSE me.codigo
    END AS cidade_exterior,
    CASE
        --Se identificou o país na tabela países
        WHEN p.codigo IS NOT NULL THEN CAST(pais AS SMALLINT)
        --Se não identificou o país e a cidade não é EXTERIOR (9707)
        WHEN p.codigo IS NULL AND mu.codigo != '9707' THEN CAST(105 AS SMALLINT) --BRASIL
        --Se não identificou o país e esta como EXTERIOR
        WHEN p.codigo IS NULL AND mu.codigo == '9707' THEN CAST(-2 AS SMALLINT) --NÃO IDENTIFICADO
        ELSE CAST(-1 AS SMALLINT) --NÃO INFORMADO
    END AS pais,    
    data_inicio_atividade,
    CASE
        WHEN cnae_fiscal_principal IS NULL THEN '-1' --NÃO INFORMADO
        WHEN c.codigo IS NULL THEN '-2' --NÃO IDENTIFICADO
        ELSE c.codigo
    END AS cnae_fiscal_principal,
    cnae_fiscal_secundaria, 
    tipo_logradouro,
    logradouro,    
    numero,    
    complemento,
    bairro,
    cep,
    CASE
        WHEN uf IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
        WHEN u.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO
        ELSE u.codigo
    END AS uf,
    CASE
        WHEN municipio IS NULL THEN CAST(-1 AS SMALLINT) --NÃO INFORMADO
        WHEN mu.codigo IS NULL THEN CAST(-2 AS SMALLINT) --NÃO IDENTIFICADO
        ELSE mu.codigo
    END AS municipio,
    ddd_1,
    telefone_1,
    ddd_2,
    telefone_2,
    ddd_fax,
    fax,
    email,
    CASE
        WHEN situacao_especial IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
        WHEN se.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO
        ELSE se.codigo
    END AS situacao_especial,
    data_situacao_especial,        
    current_timestamp() AS data_processamento
FROM {{ ref('stg_estabelecimentos') }} e
LEFT JOIN {{ ref('int_tipos_estabelecimentos') }} te ON te.codigo = e.identificador_matriz_filial
LEFT JOIN {{ ref('int_situacoes_cadastrais') }} sc ON sc.codigo = e.situacao_cadastral
LEFT JOIN {{ ref('int_situacoes_cadastrais_motivos') }} scm ON scm.codigo = e.motivo_situacao_cadastral
LEFT JOIN {{ ref('int_cidades_exterior') }} me ON me.descricao = e.cidade_exterior
LEFT JOIN {{ ref('int_paises') }} p ON p.codigo = e.pais
LEFT JOIN {{ ref('int_cnaes') }} c ON c.codigo = e.cnae_fiscal_principal
LEFT JOIN {{ ref('int_ufs') }} u ON u.sigla = e.uf
LEFT JOIN {{ ref('int_municipios') }} mu ON mu.codigo = e.municipio
LEFT JOIN {{ ref('int_situacoes_especiais') }} se ON se.descricao = e.situacao_especial