WITH top_customers AS (
    SELECT
        o.o_custkey,
        SUM(o.o_totalprice) AS total_spent
    FROM
        orders o
    WHERE
        o.o_orderdate >= DATE '[ORDER_DATE_START]'
        AND o.o_orderdate < DATE '[ORDER_DATE_END]'
    GROUP BY
        o.o_custkey
    ORDER BY
        total_spent DESC
    LIMIT [RAND_INT:10:200]
)
SELECT
    c.c_custkey,
    c.c_name,
    c.c_mktsegment,
    t.total_spent
FROM
    customer c
    JOIN top_customers t ON c.c_custkey = t.o_custkey
WHERE
    c.c_mktsegment = '[MKT_SEGMENT]'
ORDER BY
    t.total_spent DESC
LIMIT [LIMIT_N];
