WITH empresas_nao_qualificadas AS (
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
    QUALIFY rn > 1
)

SELECT    
    cnpj_basico,
    razao_social,
    natureza_juridica,
    qualificacao_responsavel,
    capital_social,
    porte_empresa,
    ente_federativo_responsavel,
    rn,
    current_timestamp() AS data_processamento
FROM empresas_nao_qualificadas