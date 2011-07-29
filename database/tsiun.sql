drop table if exists lexicon;

create table lexicon
(
        id serial primary key,

        function_name text unique not null,
        argument_count integer not null,
        word text unique not null,
        is_alias boolean not null,
        --NULL if is_alias is true
        description text,
        --NULL if is_alias is false
        alias_definition text,
        group_name text not null,

        constraint argument_count_counstraint check (argument_count >= 0)
);