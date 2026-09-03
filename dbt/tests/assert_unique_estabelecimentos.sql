-- tests/assert_unique_estabelecimentos.sql
-- Falha se houver qualquer combinação (cnpj_basico, cnpj_ordem, cnpj_dv) duplicada
SELECT
    _c0,
    _c1,
    _c2,
    COUNT(*) as qtd
FROM {{ source('silver','raw_estabelecimentos') }}
GROUP BY _c0, _c1, _c2
HAVING qtd > 1