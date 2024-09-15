create table city(
                     id integer primary key generated by default as identity,
                     name varchar(20)
);

create table person(
                       id integer primary key generated by default as identity,
                       name varchar(20),
                       salary integer,
                       city_id integer references city(id)
);

insert into city(name) values ('Москва');
insert into city(name) values ('Санкт-Петербург');
insert into city(name) values ('Казань');
insert into city(name) values ('Уфа');
insert into city(name) values ('Самара');

insert into person(name, salary, city_id) VALUES ('Андрей', 1000, 1);
insert into person(name, salary, city_id) VALUES ('Леонид', 2000, 2);
insert into person(name, salary, city_id) VALUES ('Сергей', 4000, 1);
insert into person(name, salary, city_id) VALUES ('Азамат', 10000, 4);
insert into person(name, salary, city_id) VALUES ('TEST', 10000, 4);

update person set name = 'TEST 2' where name = 'TEST';
delete from person where name = 'TEST 2';

select *
from person
         join city c on c.id = person.city_id;

select *
from person
         left join city c on c.id = person.city_id;

select *
from person
         right join city c on c.id = person.city_id;

select *
from person
         cross join city;

select *
from person
         full join city c on person.city_id = c.id;

select salary, count(*), avg(salary)
from person p
group by salary
having count(*) >= 1;