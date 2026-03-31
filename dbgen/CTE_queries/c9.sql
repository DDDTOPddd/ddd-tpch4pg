WITH high_tax_orders AS (
    SELECT
        l_orderkey,
        SUM(l_tax * l_extendedprice) AS total_tax
    FROM
        lineitem
    WHERE
        l_shipdate >= DATE '[DATE_1]'
        AND l_shipdate < DATE '[DATE_1]' + INTERVAL '1' YEAR
    GROUP BY
        l_orderkey
    ORDER BY
        total_tax DESC
    LIMIT [RAND_INT:10:50]
)
SELECT
    o.o_custkey,
    c.c_name,
    c.c_mktsegment,
    hto.total_tax
FROM
    high_tax_orders hto
    JOIN orders o ON hto.l_orderkey = o.o_orderkey
    JOIN customer c ON o.o_custkey = c.c_custkey
ORDER BY
    hto.total_tax DESC
LIMIT [LIMIT_N];
