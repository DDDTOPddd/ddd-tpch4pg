WITH worst_suppliers AS (
    SELECT
        l_suppkey,
        SUM(l_extendedprice) AS revenue
    FROM
        lineitem
    WHERE
        l_shipdate >= DATE '[DATE_2]'
        AND l_shipdate < DATE '[DATE_2]' + INTERVAL '1' YEAR
    GROUP BY
        l_suppkey
    ORDER BY
        revenue ASC
    LIMIT [RAND_INT:5:20]
)
SELECT
    s.s_name,
    p.p_name,
    ps.ps_availqty,
    ws.revenue
FROM
    worst_suppliers ws
    JOIN supplier s ON ws.l_suppkey = s.s_suppkey
    JOIN partsupp ps ON ws.l_suppkey = ps.ps_suppkey
    JOIN part p ON ps.ps_partkey = p.p_partkey
ORDER BY
    ps.ps_availqty DESC
LIMIT [LIMIT_N];
