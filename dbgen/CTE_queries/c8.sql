WITH scarce_parts AS (
    SELECT
        ps_partkey,
        AVG(ps_availqty) AS avg_qty
    FROM
        partsupp
    GROUP BY
        ps_partkey
    ORDER BY
        avg_qty ASC
    LIMIT [TOP_K_SMALL]
)
SELECT
    l.l_orderkey,
    p.p_name,
    o.o_orderdate,
    sp.avg_qty
FROM
    scarce_parts sp
    JOIN part p ON sp.ps_partkey = p.p_partkey
    JOIN lineitem l ON sp.ps_partkey = l.l_partkey
    JOIN orders o ON l.l_orderkey = o.o_orderkey
WHERE
    o.o_orderdate >= DATE '[DATE_2]'
ORDER BY
    o.o_orderdate DESC
LIMIT [LIMIT_N];
