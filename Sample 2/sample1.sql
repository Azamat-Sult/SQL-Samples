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