drop table if exists lexicon;

create table lexicon
(
        id serial primary key,

        function_name text unique not null,
        argument_count integer not null,
        word text unique not null,
        description text not null,
        --NULL if it's not an alias
        alias_definition text,
        group_name text not null,
        time_added timestamp not null,

        constraint argument_count_counstraint check (argument_count >= 0)
);