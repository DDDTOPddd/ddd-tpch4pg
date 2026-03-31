WITH refund_customers AS (
    SELECT
        o.o_custkey,
        SUM(l.l_extendedprice) AS total_refunds
    FROM
        orders o
        JOIN lineitem l ON o.o_orderkey = l.l_orderkey
    WHERE
        l.l_returnflag = 'R'
    GROUP BY
        o.o_custkey
    ORDER BY
        total_refunds DESC
    LIMIT [RAND_INT:10:50]
)
SELECT
    c.c_name,
    c.c_phone,
    o.o_orderkey,
    o.o_orderstatus,
    rc.total_refunds
FROM
    refund_customers rc
    JOIN customer c ON rc.o_custkey = c.c_custkey
    JOIN orders o ON rc.o_custkey = o.o_custkey
WHERE
    o.o_orderdate >= DATE '[DATE_1]'
ORDER BY
    rc.total_refunds DESC,
    o.o_orderdate DESC
LIMIT [LIMIT_N];
