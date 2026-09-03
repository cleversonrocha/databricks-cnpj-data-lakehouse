WITH date_spine AS (
    -- No Databricks/Spark SQL, sequence() + explode() substitui o generate_series do DuckDB
    SELECT explode(sequence(
        (SELECT MIN(data_entrada_sociedade) FROM {{ ref('int_socios') }} WHERE data_entrada_sociedade IS NOT NULL),
        (SELECT MAX(data_entrada_sociedade) FROM {{ ref('int_socios') }} WHERE data_entrada_sociedade IS NOT NULL),
        INTERVAL 1 DAY
    )) AS data_referencia
),

dim_tempo_enriquecida AS (
    SELECT
        CAST(DATE_FORMAT(data_referencia, 'yyyyMMdd') AS INT) AS sk_id,
        data_referencia,
        CAST(EXTRACT(YEAR FROM data_referencia) AS SMALLINT) AS ano,
        CAST(EXTRACT(MONTH FROM data_referencia) AS TINYINT) AS mes,
        CAST(EXTRACT(DAY FROM data_referencia) AS TINYINT) AS dia,
        CAST(EXTRACT(QUARTER FROM data_referencia) AS TINYINT) AS trimestre,

        CAST(
            CASE 
                WHEN EXTRACT(MONTH FROM data_referencia) <= 6 THEN 1 
                ELSE 2 
            END AS TINYINT
        ) AS semestre,

        -- 'u' no padrão Java DateTimeFormatter já é ISO: 1=segunda ... 7=domingo
        CAST(dayofweek(data_referencia) AS TINYINT) AS dia_semana_numero,

        CASE EXTRACT(MONTH FROM data_referencia)
            WHEN 1 THEN 'Janeiro' WHEN 2 THEN 'Fevereiro' WHEN 3 THEN 'Março'
            WHEN 4 THEN 'Abril' WHEN 5 THEN 'Maio' WHEN 6 THEN 'Junho'
            WHEN 7 THEN 'Julho' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Setembro'
            WHEN 10 THEN 'Outubro' WHEN 11 THEN 'Novembro' WHEN 12 THEN 'Dezembro'
        END AS nome_mes,

        CASE CAST(dayofweek(data_referencia) AS TINYINT)
            WHEN 1 THEN 'Segunda-feira'
            WHEN 2 THEN 'Terça-feira'
            WHEN 3 THEN 'Quarta-feira'
            WHEN 4 THEN 'Quinta-feira'
            WHEN 5 THEN 'Sexta-feira'
            WHEN 6 THEN 'Sábado'
            WHEN 7 THEN 'Domingo'
        END AS nome_dia_semana

    FROM date_spine
)

SELECT
    sk_id,
    data_referencia,
    ano,
    mes,
    dia,
    trimestre,
    semestre,
    dia_semana_numero,
    nome_mes,
    nome_dia_semana,
    current_timestamp() AS data_processamento
FROM dim_tempo_enriquecida

UNION ALL

SELECT 
    -1 AS sk_id,
    CAST(NULL AS DATE) AS data_referencia,
    CAST(NULL AS SMALLINT) AS ano,
    CAST(NULL AS TINYINT) AS mes,
    CAST(NULL AS TINYINT) AS dia,
    CAST(NULL AS TINYINT) AS trimestre,
    CAST(NULL AS TINYINT) AS semestre,
    CAST(NULL AS TINYINT) AS dia_semana_numero,
    'Não informado' AS nome_mes,
    'Não informado' AS nome_dia_semana,
    current_timestamp() AS data_processamento