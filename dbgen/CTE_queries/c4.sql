WITH top_suppliers AS (
    SELECT
        l_suppkey,
        SUM(l_extendedprice * (1 - l_discount)) AS total_rev
    FROM
        lineitem
    WHERE
        l_shipdate >= DATE '[DATE_1]'
        AND l_shipdate < DATE '[DATE_1]' + INTERVAL '1' YEAR
    GROUP BY
        l_suppkey
    ORDER BY
        total_rev DESC
    LIMIT [TOP_K_SMALL]
)
SELECT
    p.p_partkey,
    p.p_name,
    ps.ps_availqty,
    t.total_rev
FROM
    top_suppliers t
    JOIN partsupp ps ON t.l_suppkey = ps.ps_suppkey
    JOIN part p ON ps.ps_partkey = p.p_partkey
ORDER BY
    ps.ps_availqty DESC,
    p.p_partkey
LIMIT [LIMIT_N];
