WITH delayed_customers AS (
    SELECT
        o.o_custkey,
        AVG(l.l_receiptdate - l.l_commitdate) AS avg_delay
    FROM
        lineitem l
        JOIN orders o ON l.l_orderkey = o.o_orderkey
    WHERE
        l.l_receiptdate > l.l_commitdate
    GROUP BY
        o.o_custkey
    ORDER BY
        avg_delay DESC
    LIMIT [RAND_INT:20:100]
)
SELECT
    c.c_name,
    o.o_orderkey,
    o.o_orderstatus,
    dc.avg_delay
FROM
    delayed_customers dc
    JOIN customer c ON dc.o_custkey = c.c_custkey
    JOIN orders o ON dc.o_custkey = o.o_custkey
ORDER BY
    dc.avg_delay DESC,
    o.o_orderkey
LIMIT [LIMIT_N];
