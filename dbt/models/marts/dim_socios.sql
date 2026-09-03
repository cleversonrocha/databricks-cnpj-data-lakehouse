SELECT
    s.sk_id,
    s.cnpj_basico,
    s.identificador,
    tp.descricao as tipo_pessoa,
    s.nome_razao_social,
    s.cpf_cnpj,
    s.qualificacao,
    q.descricao AS descricao_qualificacao,
    s.data_entrada_sociedade,
    s.pais,
    p.descricao AS descricao_pais,
    representante_legal,
    s.nome_do_representante,
    s.qualificacao_representante,
    qr.descricao AS descricao_qualificacao_representante,
    s.faixa_etaria_socio,
    fe.descricao AS descricao_faixa_etaria_socio,
    current_timestamp() AS data_processamento 
FROM {{ ref('int_socios') }} s
JOIN {{ ref('int_tipos_pessoas')}} tp ON tp.codigo = s.identificador
JOIN {{ ref('int_qualificacoes')}} q ON q.codigo = s.qualificacao
JOIN {{ ref('int_paises')}} p ON p.codigo = s.pais
JOIN {{ ref('int_qualificacoes')}} qr ON qr.codigo = s.qualificacao_representante
JOIN {{ ref('int_faixas_etarias')}} fe ON fe.codigo = s.faixa_etaria_socio