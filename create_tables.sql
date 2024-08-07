create table warehouse (
	wh#     int primary key,
	status  number(1) default 0 not null check (status in (0, 1)),
	zip#    char(5) not null,
	address varchar(255) not null,
	phone#  char(10) not null,
	email   varchar(255),
	constraint existed_warehouse unique (zip#, address)
);

create table employee (
	employee#   int primary key,
	full_name   varchar(255) not null,
	phone#      char(10) not null,
	wh#         int not null,
	supervisor# int
);

create table supervisor (
	supervisor# int primary key,
	foreign key ( supervisor# )
		references employee ( employee# )
			on delete cascade
);

create table transitor (
	transitor# int primary key,
	foreign key ( transitor# )
		references employee
			on delete cascade
);

create table shipper (
	shipper# int primary key,
	foreign key ( shipper# )
		references employee
			on delete cascade
);

create table customer (
	customer#    int primary key,
	full_name    varchar(255) not null,
	phone#       char(10) not null,
	zip#         char(5) not null,
	address      varchar(255) not null,
	email        varchar(255),
	constraint existed_customer unique (full_name, phone#)
);

create table transport (
	transport# int primary key,
	title      varchar(255) not null,
	cost_rate  int not null check ( cost_rate > 0 ),
	note       varchar(255)
);

create table parcel (
	parcel#    int primary key,
	weight     int not null check ( weight >= 0 ),
	transport# int default 0
		references transport,
	title      varchar(255),
	note       varchar(255),
	cod        int not null check ( cod > 0 ),
	cod_status int not null check ( cod_status between 0 and 5 ),
	status     int default 0 check ( status between 0 and 8 )
);

create table sending (
	sending#   int primary key,
    payment    int generated always as ( 
        get_payment( sender#, recipient#, parcel# ) 
    ) not null,
	send_date  date default sysdate not null,
	sender#    int not null
		references customer ( customer# )
			on delete cascade,
	recipient# int not null
		references customer ( customer# )
			on delete cascade,
	parcel#    int not null unique
		references parcel
			on delete cascade,
	constraint valid_recipient check ( recipient# != sender# )
);

create table cargo (
	wh#       int,
	pack_date date default sysdate not null,
	cargo#    int,
	status    int default 0 check ( status between 0 and 2 ),
	primary key ( wh#, pack_date, cargo# ),
	foreign key ( wh# )
		references warehouse
			on delete cascade
);

create table packing (
	paking#   int primary key,
	parcel#   int not null
		references parcel,
	wh#       int not null,
	pack_date date not null,
	cargo#    int not null,
    foreign key ( wh#, pack_date, cargo# )
        references cargo
            on delete cascade
);

create table transition (
	transition#  int primary key,
	transit_date date default sysdate not null,
	note         varchar(255),
	transitor#   int not null
		references transitor,
	wh#          int not null,
	pack_date    date not null,
	cargo#       int not null,
	dst_wh#      int not null
		references warehouse ( wh# )
			on delete cascade,
    foreign key ( wh#, pack_date, cargo# )
        references cargo
            on delete cascade,
	constraint valid_dst_wh# check ( wh# != dst_wh# )
);

create table delivery (
	delivery#     int primary key,
	delivery_date date default sysdate not null,
	note          varchar(255),
	parcel#       int not null,
	shipper#      int not null,
	foreign key ( parcel# )
		references parcel
			on delete cascade,
	foreign key ( shipper# )
		references shipper
);