-- 1 up
create table if not exists bot_status (
  name    text not null unique,
  status  text not null,
  comment text,
  meta text,
  updated text not null default current_timestamp
);

-- 1 down
drop table if exists bot_status;
