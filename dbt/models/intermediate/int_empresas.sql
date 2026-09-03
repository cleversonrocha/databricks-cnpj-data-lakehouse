WITH empresas_qualificadas AS (
    SELECT
        cnpj_basico,
        razao_social,
        natureza_juridica,
        qualificacao_responsavel,
        capital_social,
        porte_empresa,
        ente_federativo_responsavel,
        CAST(    
            ROW_NUMBER() OVER (
                PARTITION BY cnpj_basico
                ORDER BY
                    (CASE WHEN razao_social IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN natureza_juridica IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN qualificacao_responsavel IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN capital_social IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN porte_empresa IS NOT NULL THEN 1 ELSE 0 END
                    + CASE WHEN ente_federativo_responsavel IS NOT NULL THEN 1 ELSE 0 END) DESC,
                    razao_social DESC NULLS LAST -- desempate determinístico se completude empatar
            ) AS INTEGER
        ) AS rn
    FROM {{ ref('stg_empresas') }} em
    QUALIFY rn = 1
)

SELECT    
    cnpj_basico,        
    razao_social,
    CASE
        WHEN natureza_juridica IS NULL THEN CAST(-1 AS SMALLINT) --NÃO INFORMADO
        WHEN nj.codigo IS NULL THEN CAST(-2 AS SMALLINT) --NÃO IDENTIFICADO
        ELSE nj.codigo
    END AS natureza_juridica,
    CASE
        WHEN qualificacao_responsavel IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
        WHEN q.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO
        ELSE q.codigo
    END AS qualificacao_responsavel,    
    capital_social,
    CASE
        WHEN porte_empresa IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
        WHEN pe.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO
        ELSE pe.codigo
    END AS porte_empresa,    
    CASE
        WHEN ente_federativo_responsavel IS NULL THEN CAST(-1 AS SMALLINT) --NÃO INFORMADO
        WHEN ef.codigo IS NULL THEN CAST(-2 AS SMALLINT) --NÃO IDENTIFICADO
        ELSE ef.codigo
    END AS ente_federativo_responsavel,
    current_timestamp() AS data_processamento
FROM empresas_qualificadas em
LEFT JOIN {{ ref('stg_naturezas') }} nj ON nj.codigo = em.natureza_juridica
LEFT JOIN {{ ref('stg_qualificacoes') }} q ON q.codigo = em.qualificacao_responsavel
LEFT JOIN {{ ref('int_portes_empresas') }} pe ON pe.codigo = em.porte_empresa
LEFT JOIN {{ ref('int_entes_federativos') }} ef ON ef.descricao = em.ente_federativo_responsavel