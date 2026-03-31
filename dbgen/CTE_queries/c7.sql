WITH national_big_orders AS (
    SELECT
        o.o_orderkey,
        o.o_totalprice
    FROM
        orders o
        JOIN customer c ON o.o_custkey = c.c_custkey
        JOIN nation n ON c.c_nationkey = n.n_nationkey
    WHERE
        n.n_name = '[NATION]'
        AND o.o_orderdate >= DATE '[ORDER_DATE_START]'
        AND o.o_orderdate <= DATE '[ORDER_DATE_END]'
    ORDER BY
        o.o_totalprice DESC
    LIMIT [RAND_INT:20:100]
)
SELECT
    l.l_partkey,
    l.l_suppkey,
    l.l_quantity,
    nbo.o_totalprice
FROM
    national_big_orders nbo
    JOIN lineitem l ON nbo.o_orderkey = l.l_orderkey
ORDER BY
    l.l_quantity DESC
LIMIT [LIMIT_N];
