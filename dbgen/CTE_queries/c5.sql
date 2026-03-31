WITH popular_parts AS (
    SELECT
        l_partkey,
        COUNT(*) AS order_count
    FROM
        lineitem
    WHERE
        l_commitdate >= DATE '[DATE_2]'
        AND l_commitdate < DATE '[DATE_2]' + INTERVAL '6' MONTH
    GROUP BY
        l_partkey
    ORDER BY
        order_count DESC
    LIMIT [TOP_K_SMALL]
)
SELECT
    l.l_orderkey,
    l.l_suppkey,
    l.l_shipdate,
    l.l_returnflag,
    pp.order_count
FROM
    popular_parts pp
    JOIN lineitem l ON pp.l_partkey = l.l_partkey
ORDER BY
    l.l_shipdate DESC
LIMIT [LIMIT_N];
