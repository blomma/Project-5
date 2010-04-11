\\ Table for useraccount

create table useraccount (
       id         serial,
       username   varchar(120),
       password   varchar(120),
       email      varchar(120),
       realname   text,
       address    text,
       status     int2,
       action     int2
);