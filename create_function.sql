create or replace noneditionable function get_payment (
	sender#    in int,
	recipient# in int,
	parcel#    in int
) return int as
	sender_zip#      int;
	recipient_zip#   int;
	parcel_cost_rate int;
begin
	select to_number(zip#)
	  into sender_zip#
	  from customer
	 where customer# = sender#;

	select to_number(zip#)
	  into recipient_zip#
	  from customer
	 where customer# = recipient#;

	select weight * 0.1 * cost_rate
	  into parcel_cost_rate
	  from parcel
	 inner join transport
	    on parcel.transport# = transport.transport#
	 where parcel# = parcel#;

-- The formula below is made up and not the practical way to calculate delivery cost
	return abs(sender_zip# - recipient_zip#) * parcel_cost_rate;
end get_payment;