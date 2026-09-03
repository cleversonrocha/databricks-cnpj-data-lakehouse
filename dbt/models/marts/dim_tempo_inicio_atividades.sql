SELECT 
    sk_id,
    data_referencia,
    ano,
    mes,
    nome_mes,
    current_timestamp() AS data_processamento 
FROM {{ ref('int_tempo_inicio_atividades') }}