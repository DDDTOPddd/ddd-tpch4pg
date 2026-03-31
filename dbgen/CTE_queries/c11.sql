WITH peak_shipping_day AS (
    SELECT
        l_shipdate,
        SUM(l_quantity) AS total_shipped
    FROM
        lineitem
    GROUP BY
        l_shipdate
    ORDER BY
        total_shipped DESC
    LIMIT 1
)
SELECT
    l.l_orderkey,
    l.l_partkey,
    l.l_suppkey,
    l.l_quantity
FROM
    peak_shipping_day psd
    JOIN lineitem l ON psd.l_shipdate = l.l_shipdate
ORDER BY
    l.l_quantity DESC
LIMIT [LIMIT_N];
