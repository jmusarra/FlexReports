with t as (
SELECT 
    'Bulk' AS inventoryType,
    r.bar_code_id,
    g.full_display_string,
    r.display_string AS 'itemName',
    SUM(s.quantity) AS 'prepScans',
    ROUND(SUM(s.quantity) / ROUND(DATEDIFF(CURDATE(),'2018-01-01')/7,0),1) as 'perWeek',
    IFNULL((SELECT 
                    m.quantity
                FROM
                    st_ivt_allocated_qty_matrix AS m
                WHERE
                    m.item_id = s.item_id
                        AND stock_type_id = 'fb2cb3ac-aedd-11df-b8d5-00e08175e43e'),
            0) AS qtyOwned,
    IFNULL((SELECT ROUND((SUM(s.quantity) / qtyOwned), 2)),
            0) AS usageFactor
FROM
    st_ivt_scan_record AS s
        JOIN
    st_ivt_inventory_item AS i ON i.id = s.item_id
        JOIN
    st_biz_managed_resource AS r ON r.id = s.item_id
        JOIN
    st_ivt_inventory_group AS g ON g.id = i.group_id
WHERE
    (i.tracked_by_sn = 0)
        AND (s.scan_timestamp >= '2018-01-01')
        AND (s.scan_mode = 'prep')
        AND (s.is_reversed = 0)
        AND (g.full_display_string NOT LIKE '%Tools%')
        AND (g.full_display_string NOT LIKE '%Shims%')
        AND (g.full_display_string LIKE 'Rental >%'
        OR g.full_display_string LIKE 'Production Support%')
GROUP BY s.item_id 
UNION SELECT 
    'Serialized' AS inventoryType,
    -- s.item_id,
    r.bar_code_id,
    g.full_display_string,
    r.display_string AS 'itemName',
    SUM(s.quantity) AS 'prepScans',
	ROUND(SUM(s.quantity) / ROUND(DATEDIFF(CURDATE(),'2018-01-01')/7,0),1) as 'perWeek',
    (SELECT 
            COUNT(id)
        FROM
            st_ivt_serial_number AS n
        WHERE
            n.item_id = s.item_id AND ! n.is_sold
                AND ! n.is_deleted
                AND ! n.is_decommissioned) AS qtyOwned,
    IFNULL((SELECT ROUND((SUM(s.quantity) / qtyOwned), 2)),
            0) AS usageFactor
FROM
    st_ivt_scan_record AS s
        JOIN
    st_ivt_inventory_item AS i ON i.id = s.item_id
        JOIN
    st_ivt_inventory_group AS g ON g.id = i.group_id
        JOIN
    st_biz_managed_resource AS r ON r.id = s.item_id
WHERE
    s.scan_mode = 'prep'
        AND s.scan_timestamp >= '2018-01-01'
        AND s.is_reversed = 0
        AND i.tracked_by_sn = 1
        AND r.is_deleted = 0
        AND (g.full_display_string LIKE 'Rental%'
        OR g.full_display_string LIKE 'Production%Support%')
        AND g.full_display_string NOT LIKE '%Tools%'
GROUP BY s.item_id 

        )
SELECT prepScans, itemName, ROUND(PERCENT_RANK() OVER(ORDER BY prepScans),2) AS Percentile FROM t
ORDER BY prepScans DESC;

