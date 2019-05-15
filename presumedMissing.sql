SELECT 
    CONVERT_TZ(scan_timestamp, 'UTC', 'US/Pacific') AS "Last Record",
    p.element_name AS "Show Name",
    g.full_display_string AS "Group",
    m.display_string AS "Item Name",
    s.bar_code_id,
    s.scan_mode,
    s.is_virtual_scan as "Virtual?",
    s.is_auto_scan AS "Auto?",
    u.name AS "User"
FROM
    report_dev.st_ivt_scan_record AS s
        INNER JOIN
    (SELECT 
        bar_code_id, MAX(scan_timestamp) AS mostRecent
    FROM
        report_dev.st_ivt_scan_record
        where is_reversed = 0
    GROUP BY bar_code_id) AS lastSeen ON s.bar_code_id = lastSeen.bar_code_id
        AND s.scan_timestamp = lastSeen.mostRecent
        JOIN
    report_dev.rh_userprofile AS u ON u.userprofileid = s.user_id
        JOIN
    report_dev.st_biz_managed_resource AS m ON m.id = s.serial_number_id
        JOIN st_ivt_inventory_item as i on i.id = s.item_id
        JOIN st_ivt_inventory_group as g on g.id = i.group_id
        LEFT JOIN
    report_dev.st_prj_project_element_line_item AS li ON li.id = s.line_item_id
        LEFT JOIN
    report_dev.st_prj_project_element AS p ON p.id = li.project_element_id
    
WHERE
    s.serial_number_id IN (
    SELECT 
    m.id 
FROM 
    report_dev.st_biz_managed_resource as m
JOIN st_ivt_serial_number AS s on s.id = m.id
JOIN st_ivt_inventory_item as i on i.id = s.item_id
JOIN st_ivt_inventory_group as g on g.id = i.group_id
WHERE 
    m.presumed_missing
AND !m.is_deleted
AND g.full_display_string NOT LIKE '%Test%'
AND !s.is_sold)
ORDER BY m.display_string, scan_timestamp DESC
    