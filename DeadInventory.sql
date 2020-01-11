SELECT 
    -- 'Bulk' AS inventoryType,
    -- i.id AS item_id,
    r.bar_code_id,
    g.full_display_string,
    r.display_string AS 'itemName'
    -- 0 AS 'prepScans',
    -- 0 as 'perWeek',
    -- IFNULL(q.quantity,0) AS qtyOwned,
    -- 0 AS usageFactor

FROM st_ivt_inventory_item AS i
JOIN st_biz_managed_resource AS r ON r.id = i.id
JOIN st_ivt_inventory_group AS g ON g.id = i.group_id
-- JOIN st_ivt_allocated_qty_matrix as q on q.item_id = i.id

WHERE
    i.id NOT IN (SELECT 
            item_id
        FROM st_ivt_scan_record AS s
        WHERE
            s.scan_timestamp >= NOW() - INTERVAL 1 YEAR)
        AND (g.full_display_string LIKE 'Rental%' OR 'Production Support%')
        AND (i.virtual_item = 0)
        AND (i.expendable = 0)
        AND r.created_by_date <= NOW() - INTERVAL 1 YEAR
       -- AND i.tracked_by_sn = 0
	   -- AND q.stock_type_id = 'fb2cb3ac-aedd-11df-b8d5-00e08175e43e';
       ORDER BY g.full_display_string, itemName ASC;
       