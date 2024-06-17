DROP PROCEDURE create_result_table();
CREATE PROCEDURE create_result_table()
LANGUAGE sql
AS $$
CREATE TABLE sales_order (
	"Product ID" int8 NULL,
	"Sales QTY" int8 NULL,
	"Supply ID" int8 NULL,
	"Supply QTY" int8 NULL,
	"costs per PCS" int8 NULL,
	"Date" timestamp NULL
);
	ALTER TABLE sales_order ADD COLUMN "Sale VALUE" int8 DEFAULT 0;
$$;


DROP PROCEDURE create_summury();
CREATE PROCEDURE create_summury()
LANGUAGE sql
AS $$
select 
	sum("Sale VALUE"),
	extract(month from "Date") as mnth,
	extract(year from "Date") as yr
into summary
from sales_order 
group by yr, mnth
order by yr, mnth;
$$;


DROP PROCEDURE write_order_record(sale_rec record, supply_rec record, sale_value int8);
CREATE PROCEDURE write_order_record(sale_rec record, supply_rec record, sale_value int8)
LANGUAGE plpgsql
AS $$
BEGIN	
	INSERT INTO sales_order VALUES(
	sale_rec."Product ID",
	sale_rec."Sales QTY",
	supply_rec."#Supply",
	supply_rec."Supply QTY",
	supply_rec."Costs Per PCS",
	sale_rec."Date",
	sale_value
	);
END;
$$;


DROP PROCEDURE writeoff(inout sales_curs refcursor, inout supply_curs refcursor, inout sale_rec record, inout supply_rec record);
CREATE PROCEDURE writeoff(inout sales_curs refcursor, inout supply_curs refcursor, inout sale_rec record, inout supply_rec record)
LANGUAGE plpgsql
AS $$
DECLARE
	sales_qty int8;
	supply_qty int8;
	qty int8;
	price int8;
	price_default int8; -- for returned sales;
	sale_value int8;
BEGIN
	
	-- initialization declared vars
	sales_qty = sale_rec."Sales QTY";
	supply_qty = supply_rec."Supply QTY";
	price = supply_rec."Costs Per PCS";
	price_default = 0; -- returned sales value mean? supply_rec."Costs Per PCS"?

	-- Sales QTY conditions
	CASE	
	WHEN sales_qty < 0	-- negative sales qty case. return to supply 
	THEN
		qty = sales_qty;
		sale_value = price_default * qty;
		call write_order_record(sale_rec, supply_rec, sale_value);
		supply_rec."Supply QTY" = supply_rec."Supply QTY" - sales_qty;
		sale_rec."Sales QTY" = 0;
	WHEN sales_qty = supply_qty	-- equals case. move both of curs
	THEN
		qty = sales_qty;
		sale_value = price * qty;
		call write_order_record(sale_rec, supply_rec, sale_value);
		sale_rec."Sales QTY" = 0;
		supply_rec."Supply QTY" = 0;
	WHEN sales_qty > supply_qty -- sales > supply. move sales curs
	THEN
		qty = supply_qty;
		sale_value = price * qty;
		call write_order_record(sale_rec, supply_rec, sale_value);
		sale_rec."Sales QTY" = sale_rec."Sales QTY" - supply_qty;
		supply_rec."Supply QTY" = 0;
	WHEN sales_qty < supply_qty -- sales < supply. null, muv sales curs
	THEN
		qty = sales_qty;
		sale_value = price * qty;
		call write_order_record(sale_rec, supply_rec, sale_value);
		sale_rec."Sales QTY" = 0;
		supply_rec."Supply QTY" = supply_rec."Supply QTY" - sales_qty;
	ELSE
	END CASE; 
END;
$$;



