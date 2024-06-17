-- типизация по умолчанию. если подвох в ней - то я ее не проверял

do 
LANGUAGE plpgsql
$$
DECLARE 
	products integer[];
	i int;

	sale_rec record;
	supply_rec record;

	sales_curs CURSOR (k integer) FOR SELECT * FROM sales WHERE "Product ID" = k order by "Date";	-- scroll?
	supply_curs CURSOR (k integer) FOR SELECT * FROM supply WHERE "Product ID" = k order by "#Supply";
BEGIN
	call create_result_table();	-- add sale value column
	products = array(select distinct "Product ID" from sales order by "Product ID");
	-- raise notice '%', products;
	
	FOREACH i IN ARRAY products
	LOOP
		open sales_curs(i);
		open supply_curs(i);
		fetch sales_curs into sale_rec;
		fetch supply_curs into supply_rec;
		
		LOOP
			IF sale_rec."Sales QTY" <= 0
			THEN 
				fetch sales_curs into sale_rec;
			END IF; 
			IF supply_rec."Supply QTY" <= 0
			THEN 
				fetch supply_curs into supply_rec;
			END IF;

			-- raise notice '%', sale_rec;
			exit when not FOUND;
			call writeoff(sales_curs, supply_curs, sale_rec, supply_rec);
		END LOOP;
	
		close sales_curs;	
		close supply_curs;
  	END LOOP;
	
	call create_summury(); 
END;
$$

