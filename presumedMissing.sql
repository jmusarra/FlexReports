SELECT 
    CONVERT_TZ(scan_timestamp, 'UTC', 'US/Pacific') AS 'Last Record',
    (SELECT COUNT(id) from st_ivt_serial_number WHERE item_id = s.item_id and is_deleted=0) AS "totalQty",
    p.element_name AS 'Show Name',
    p.planned_end_date as "Expected Return Date",
    g.full_display_string AS 'Group',
    m.display_string AS 'Item Name',
    s.bar_code_id,
    sn.stencil,
    i.replacement_cost,
    s.scan_mode,
    s.is_virtual_scan AS 'Virtual?',
    s.is_auto_scan AS 'Auto?',
    u.name AS 'User'
FROM
    report_dev.st_ivt_scan_record AS s
        INNER JOIN
    (SELECT 
        bar_code_id, MAX(scan_timestamp) AS mostRecent
    FROM
        report_dev.st_ivt_scan_record
    WHERE
        is_reversed = 0
    GROUP BY bar_code_id) AS lastSeen ON s.bar_code_id = lastSeen.bar_code_id
        AND s.scan_timestamp = lastSeen.mostRecent
        JOIN
    report_dev.rh_userprofile AS u ON u.userprofileid = s.user_id
        JOIN
    report_dev.st_biz_managed_resource AS m ON m.id = s.serial_number_id
        JOIN
    st_ivt_inventory_item AS i ON i.id = s.item_id
        JOIN
    st_ivt_inventory_group AS g ON g.id = i.group_id
        LEFT JOIN
    report_dev.st_prj_project_element_line_item AS li ON li.id = s.line_item_id
        LEFT JOIN
    report_dev.st_prj_project_element AS p ON p.id = li.project_element_id
        JOIN st_ivt_serial_number AS sn ON sn.id = s.serial_number_id
WHERE
    s.serial_number_id IN (SELECT 
            m.id
        FROM
            report_dev.st_biz_managed_resource AS m
                JOIN
            st_ivt_serial_number AS s ON s.id = m.id
                JOIN
            st_ivt_inventory_item AS i ON i.id = s.item_id
                JOIN
            st_ivt_inventory_group AS g ON g.id = i.group_id
        WHERE
            m.presumed_missing 
            AND m.is_deleted = 0
			AND g.full_display_string NOT LIKE "Test%"
            AND g.full_display_string NOT LIKE "Client Storage%"
			AND s.is_sold=0
            AND s.is_decommissioned = 0)
ORDER BY g.full_display_string ASC, m.display_string ASC, scan_timestamp DESC
