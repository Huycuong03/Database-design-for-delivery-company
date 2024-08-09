-- Get the number of parcel in a month
select count(parcel#) as "num_parcel"
  from sending
 where extract(month from send_date) = 1
   and extract(year from send_date) = 2024;

-- Get revenue in a month
select sum(payment) as "revenue"
  from (
	select get_payment(
		sender#,
		recipient#,
		parcel#
	) as payment
	  from sending
	 where extract(month from send_date) = 1
	   and extract(year from send_date) = 2024
);

-- Get track list of a parcel - format: (date, warehouse, to)
-- The date customer send parcel
select send_date as "date",
       wh#,
       null as "to"
  from parcel
natural join sending
natural join (
	select parcel#,
	       wh#
	  from packing
	 where parcel = 0
	 fetch next 1 rows only
)
union
-- Transittions between warehouses
select transit_date as "date",
       wh#,
       address as "to"
  from transition
natural join (
	select wh#,
	       pack_date,
	       cargo#
	  from packing
	 where parcel# = 0
)
 inner join warehouse
on transition.dst_wh# = warehouse.wh#
union
-- The date shipper deliver parcel
select delivery_date as "date",
       dst_wh# as "wh#",
       address as "to"
  from (
	select parcel#,
	       dst_wh#
	  from packing
	 where parcel# = 0
	 order by pack_date desc
	 fetch next 1 rows only
)
natural join sending
 inner join customer
on sending.recipient# = customer.customer#;

-- Get the number of parcel received from other warehouses in a month
select wh#,
       count(parcel#) as "num_parcel"
  from (
	select wh#,
	       pack_date,
	       cargo#
	  from transition
	 where dst_wh# = 0
	   and extract(month from transit_date) = 1
	   and extract(year from transit_date) = 2024
)
natural join packing
 group by wh#;

-- Get the number of parcel received from customers daily in a month
select extract(day from send_date),
       count(parcel#) as "num_parcel"
  from sending
 where extract(month from send_date) = 1
 group by send_date
 order by send_date;

-- Get transport types' portion in a month
select title,
       count(transport#) as "portion"
  from (
	select parcel#
	  from sending
	 where extract(month from send_date) = 1
	   and extract(year from send_date) = 2024
)
natural join parcel
natural join transport;