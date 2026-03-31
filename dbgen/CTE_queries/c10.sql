WITH region_hot_parts AS (
    SELECT
        ps.ps_partkey,
        SUM(ps.ps_supplycost) AS total_cost
    FROM
        partsupp ps
        JOIN supplier s ON ps.ps_suppkey = s.s_suppkey
        JOIN nation n ON s.s_nationkey = n.n_nationkey
        JOIN region r ON n.n_regionkey = r.r_regionkey
    WHERE
        r.r_name = '[REGION]'
    GROUP BY
        ps.ps_partkey
    ORDER BY
        total_cost DESC
    LIMIT [TOP_K_SMALL]
)
SELECT
    l.l_orderkey,
    l.l_shipmode,
    l.l_shipinstruct,
    rhp.total_cost
FROM
    region_hot_parts rhp
    JOIN lineitem l ON rhp.ps_partkey = l.l_partkey
WHERE
    l.l_shipmode = '[SHIPMODE]'
ORDER BY
    l.l_orderkey
LIMIT [LIMIT_N];
