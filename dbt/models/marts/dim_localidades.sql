WITH localidades AS (
    SELECT
        DISTINCT
        CAST(DENSE_RANK() OVER(ORDER BY municipio,cidade_exterior,uf,pais) AS INTEGER) AS sk_id,
        municipio,
        cidade_exterior,
        uf,
        pais        
    FROM {{ ref('int_estabelecimentos') }}
)

SELECT
    l.sk_id,
    m.codigo AS codigo_municipio,
    m.descricao AS municipio,    
    ce.codigo AS codigo_cidade_exterior,
    ce.descricao AS cidade_exterior,    
    u.codigo AS codigo_uf,
    u.sigla AS uf,    
    u.regiao AS regiao,    
    p.codigo AS codigo_pais,
    p.descricao AS pais,
    current_timestamp() AS data_processamento
FROM localidades l
JOIN {{ ref('int_municipios') }} m ON m.codigo = l.municipio
JOIN {{ ref('int_cidades_exterior') }} ce ON ce.codigo = l.cidade_exterior
JOIN {{ ref('int_ufs') }} u ON u.codigo = l.uf
JOIN {{ ref('int_paises') }} p ON p.codigo = l.pais