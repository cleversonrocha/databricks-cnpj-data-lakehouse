WITH socios AS (
    SELECT        
        cnpj_basico,        
        CASE
            WHEN identificador IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
            WHEN tp.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO
            ELSE tp.codigo
        END AS identificador,
        nome_razao_social,
        cpf_cnpj,
        CASE
            WHEN qualificacao IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
            WHEN q.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO
            ELSE q.codigo
        END AS qualificacao,
        data_entrada_sociedade,
        CASE
            WHEN pais IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
            WHEN p.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO
            ELSE p.codigo
        END AS pais,
        representante_legal,
        nome_do_representante,
        CASE
            WHEN qualificacao_representante IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
            WHEN qr.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO
            ELSE qr.codigo
        END AS qualificacao_representante,
        CASE
            WHEN faixa_etaria_socio IS NULL THEN CAST(-1 AS TINYINT) --NÃO INFORMADO
            WHEN fe.codigo IS NULL THEN CAST(-2 AS TINYINT) --NÃO IDENTIFICADO
            ELSE fe.codigo
        END AS faixa_etaria_socio
    FROM {{ ref('stg_socios') }} s
    LEFT JOIN {{ ref('int_tipos_pessoas')}} tp ON tp.codigo = s.identificador
    LEFT JOIN {{ ref('int_qualificacoes')}} q ON q.codigo = s.qualificacao
    LEFT JOIN {{ ref('int_paises')}} p ON p.codigo = s.pais
    LEFT JOIN {{ ref('int_qualificacoes')}} qr ON qr.codigo = s.qualificacao_representante
    LEFT JOIN {{ ref('int_faixas_etarias')}} fe ON fe.codigo = s.faixa_etaria_socio
)

SELECT
    CAST(ROW_NUMBER() OVER(ORDER BY cnpj_basico) AS INTEGER) AS sk_id,
    cnpj_basico,
    identificador,
    nome_razao_social,
    cpf_cnpj,
    qualificacao,
    data_entrada_sociedade,
    pais,
    representante_legal,
    nome_do_representante,
    qualificacao_representante,
    faixa_etaria_socio,    
    current_timestamp() AS data_processamento
FROM socios