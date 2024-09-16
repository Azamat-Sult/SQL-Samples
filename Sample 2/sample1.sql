create schema testdata;

create table testdata.words (word text);
copy testdata.words (word) from 'D:\Projects\SQL-Samples\Sample 2\words.txt';

create or replace function testdata.random_word() returns text as $$
    select * from testdata.words order by random() limit 1
$$ language sql;

create or replace function testdata.random_uuid() returns text as $$
    select uuid_in(md5(random()::text || random()::text)::cstring)
$$ language sql;

create or replace function testdata.array_slice(arr int[], idx1 int, idx2 int) returns int[] as $$
    select arr[idx1:idx2];
$$ language sql;
-- указать в окне :idx2

create or replace function testdata.array_slice(arr varchar[], idx1 int, idx2 int) returns varchar[] as $$
    select arr[idx1:idx2];
$$ language sql;
-- указать в окне :idx2

create or replace function testdata.random_element(elements anyarray) returns anyelement as $$
    BEGIN
        if elements is null or elements = '{}' then
            return null;
        end if;
        return elements[ceil(random() * array_upper(elements, 1))::int];
    END
$$ language plpgsql volatile returns null on null input;

create or replace function testdata.random_element(elements anyarray, weights int[]) returns anyelement as $$
    DECLARE
        sumWeight int;
        rnd int;
    BEGIN
        if elements is null or elements = '{}' then
            return null;
        end if;
        sumWeight := 0;
        for i in array_lower(elements, 1) .. array_upper(elements, 1) loop
            sumWeight := sumWeight + weights[i];
        end loop;
        rnd := ceil(random() * sumWeight);
        sumWeight := 0;
        for i in array_lower(elements, 1) .. array_upper(elements, 1) loop
            if rnd <= sumWeight + weights[i] then
                return elements[i];
            end if;
        end loop;
        return null;
    END
$$ language plpgsql volatile returns null on null input;

create or replace function testdata.random_title(num_words int default 1) returns text as $$
    select initcap(array_to_string(array(select * from testdata.words order by random() limit num_words), ' '))
$$ language sql;

create or replace function testdata.random_number(len int default 1) returns text as $$
    DECLARE
        lefttogo int = len;
        res varchar(1000) = '';
    BEGIN
        loop
            res := res || lpad(round(random() * pow(10, least(lefttogo, 16)))::text, least(lefttogo, 16), '0');
            lefttogo := lefttogo - least(lefttogo, 16);
            exit when lefttogo <= 0;
        end loop;
        return res;
    END
$$ language plpgsql;

create or replace function testdata.random_timestamp(days_past int default 100, days_future int default 0) returns timestamp as $$
    select (now() - '1 day'::interval * (random() * days_past)::int + '1 day'::interval * (random() * days_future)::int - '1 millisecond'::interval * (random() * 86400000)::int)::timestamp
$$ language sql;

create or replace function testdata.random_date(days_past int default 100, days_future int default 0) returns date as $$
    select (date_trunc('day', now()) - '1 day'::interval * (random() * days_past)::int + '1 day'::interval * (random() * days_future)::int)::date
$$ language sql;

create sequence testdata.global_id_seq;

create or replace function testdata.snowflake() returns bigint as $$
    DECLARE
        our_epoch bigint := 1314220021721;
        seq_id bigint;
        now_millis bigint;
        shard_id int := 1;
        result bigint := 0;
    BEGIN
        select nextval('testdata.global_id_seq') % 1024 into seq_id;
        select floor(extract(epoch from clock_timestamp()) * 1000) into now_millis;
        result := (now_millis - our_epoch) << 23;
        result := result | (shard_id << 10);
        result := result | (seq_id);
        return result;
    END
$$ language plpgsql;

create table randomtestdata (
    id varchar(254) constraint someprimarykey primary key,
    random_id_1 varchar(254),
    random_id_2 varchar(254),
    random_date_1 timestamp(3),
    random_date_2 timestamp(3),
    random_text_1 varchar(254)
);

insert into randomtestdata (
                            id,
                            random_id_1,
                            random_id_2,
                            random_date_1,
                            random_date_2,
                            random_text_1
)
select
    testdata.snowflake(),
    testdata.random_number(10),
    md5(random()::text),
    testdata.random_date(100),
    '2024-01-01'::timestamptz,
    '111'||lpad(upper(to_hex(i)),6,'0')||'999'
from generate_series(0, 1000) as i;