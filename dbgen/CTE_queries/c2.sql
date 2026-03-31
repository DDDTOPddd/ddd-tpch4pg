WITH hot_parts AS (
    SELECT
        l_partkey,
        SUM(l_quantity) AS sum_qty
    FROM
        lineitem
    WHERE
        l_shipdate >= DATE '[DATE_2]'
        AND l_shipdate < DATE '[DATE_2]' + INTERVAL '1' YEAR
    GROUP BY
        l_partkey
    ORDER BY
        sum_qty DESC
    LIMIT [TOP_K_SMALL]
)
SELECT
    l.l_orderkey,
    l.l_partkey,
    l.l_shipdate,
    l.l_extendedprice,
    h.sum_qty
FROM
    lineitem l
    JOIN hot_parts h ON l.l_partkey = h.l_partkey
ORDER BY
    l.l_extendedprice DESC
LIMIT [LIMIT_N];
