SELECT
case when case when sr.is_returned is not null then sr.is_returned else !pm_unit.is_removed end then 'yes' else 'no' end as is_returned,
sr.scan_timestamp, scan_loc.resource_name AS scan_location,
pm_res.id as serial_id, item_res.resource_name AS item_name, pm_item.item_size, pm_item.id AS item_id, pm_res.bar_code_id as serial_barcode,
pm_unit.serial_number, pm_unit.stencil, pm_unit.model_number, COALESCE(pm_unit.replacement_cost, pm_item.replacement_cost,0) as replacement_cost, stor_loc.resource_name AS location,
prjel.document_number, prjel.element_name, prjel.id as document_id, 

case when gp_def.extension_id = 'shoptick.financials.document' then gp_prjel.planned_end_date
when par_def.extension_id = 'shoptick.financials.document' then par_prjel.planned_end_date
when par_def.extension_id = 'shoptick.inventory.equipment.list' then par_prjel.planned_end_date
else prjel.planned_end_date end as end_date,
case when gp_def.extension_id = 'shoptick.financials.document' then gp_prjel.document_number
when par_def.extension_id = 'shoptick.financials.document' then par_prjel.document_number
when par_def.extension_id = 'shoptick.inventory.equipment.list' then par_prjel.document_number
else prjel.document_number end as quote_num,
case when gp_def.extension_id = 'shoptick.financials.document' then gp_prjel.id
when par_def.extension_id = 'shoptick.financials.document' then par_prjel.id
when par_def.extension_id = 'shoptick.inventory.equipment.list' then par_prjel.id
else prjel.id end as quote_id,
item_grp.GROUP_NAME, item_grp_2.GROUP_NAME AS GROUP_NAME_2,  item_grp_3.GROUP_NAME AS GROUP_NAME_3,  item_grp_4.GROUP_NAME AS GROUP_NAME_4, item_grp_5.GROUP_NAME AS GROUP_NAME_5

FROM st_ivt_serial_number AS pm_unit
LEFT JOIN st_biz_managed_resource AS pm_res ON pm_res.id = pm_unit.id
LEFT JOIN st_ivt_inventory_item AS pm_item ON pm_item.id = pm_unit.item_id
LEFT JOIN st_biz_managed_resource AS item_res ON item_res.id = pm_item.id
LEFT JOIN st_prj_project_element_line_item AS eitem ON eitem.managed_resource_id = pm_unit.id 

LEFT JOIN (SELECT scan_timestamp, scan_rec.line_item_id, scan_rec.item_id, scan_rec.scan_location_id, scan_res.id AS res_id, scan_res.bar_code_id, item_res.resource_name,
			sn.serial_number, sn.stencil, sn.model_number, sn.replacement_cost, sn.storage_location_id, elist.is_returned
	FROM st_ivt_scan_record AS scan_rec
	LEFT JOIN st_ivt_inventory_item AS scan_item ON scan_item.id = scan_rec.item_id
    LEFT JOIN st_biz_managed_resource AS item_res ON item_res.id = scan_item.id
	LEFT JOIN st_biz_managed_resource AS scan_res ON scan_res.id = scan_rec.serial_number_id
    LEFT JOIN st_ivt_serial_number AS sn ON sn.id = scan_res.id
    LEFT JOIN st_ivt_equipment_list_line_item AS elist ON elist.id = scan_rec.line_item_id
    WHERE scan_res.presumed_missing and !scan_res.is_deleted and scan_rec.scan_mode = 'prep'
    and !sn.is_sold and !sn.is_decommissioned and !sn.ooc
    AND (case when $P{LOCATION_ID} is not null then sn.storage_location_id = $P{LOCATION_ID} else true end)
    ORDER BY scan_timestamp DESC) AS sr
ON (sr.line_item_id = eitem.id OR sr.bar_code_id = pm_res.bar_code_id)

LEFT JOIN st_prj_project_element AS prjel ON prjel.id = eitem.project_element_id

LEFT JOIN st_biz_managed_resource AS stor_loc ON stor_loc.id = sr.storage_location_id
LEFT JOIN st_biz_managed_resource AS scan_loc ON scan_loc.id = sr.scan_location_id

LEFT JOIN st_prj_project_element as par_prjel on par_prjel.id = prjel.parent_id
LEFT JOIN st_prj_element_definition as par_def on par_def.id = par_prjel.def_id

LEFT JOIN st_prj_project_element as gp_prjel on gp_prjel.id = par_prjel.parent_id
LEFT JOIN st_prj_element_definition as gp_def on gp_def.id = gp_prjel.def_id

LEFT JOIN st_ivt_inventory_group AS item_grp   ON (item_grp.id = pm_item.group_id)
LEFT JOIN st_ivt_inventory_group AS item_grp_2 ON (item_grp_2.id = item_grp.parent_group_id)
LEFT JOIN st_ivt_inventory_group AS item_grp_3 ON (item_grp_3.id = item_grp_2.parent_group_id)
LEFT JOIN st_ivt_inventory_group AS item_grp_4 ON (item_grp_4.id = item_grp_3.parent_group_id)
LEFT JOIN st_ivt_inventory_group AS item_grp_5 ON (item_grp_5.id = item_grp_4.parent_group_id)

WHERE pm_res.presumed_missing AND !pm_res.is_deleted
AND !pm_unit.is_sold and !pm_unit.is_decommissioned and !pm_unit.ooc

GROUP BY pm_res.bar_code_id
ORDER BY
case when $P{BY_JOB} = 'false' then item_grp.global_sort_ordinal end, 
case when $P{BY_JOB} = 'false' then pm_item.display_order end,
case when $P{BY_JOB} = 'false' then serial_barcode end,
case when $P{BY_JOB} = 'false' then scan_timestamp end,

case when $P{BY_JOB} = 'true' then 
(case when gp_prjel.planned_end_date is not null then gp_prjel.planned_end_date
when par_prjel.planned_end_date is not null then par_prjel.planned_end_date
else prjel.planned_end_date end) end,
case when $P{BY_JOB} = 'true' then prjel.id end,
case when $P{BY_JOB} = 'true' then item_grp.global_sort_ordinal end,
case when $P{BY_JOB} = 'true' then pm_item.display_order end,
case when $P{BY_JOB} = 'true' then serial_barcode end,
case when $P{BY_JOB} = 'true' then scan_timestamp end