-- Migrations will appear here as you chat with AI

create table partidas_arancelarias (
  id bigint primary key generated always as identity,
  codigo text not null,
  descripcion text not null,
  tasa_arancelaria numeric(5, 2) not null,
  unidad_medida text not null,
  fecha_vigencia date not null
);

create table detalles_partidas (
  id bigint primary key generated always as identity,
  partida_id bigint not null references partidas_arancelarias (id),
  detalle text not null,
  valor numeric(10, 2) not null,
  fecha_registro timestamp with time zone default now()
);

create table categorias (
  id bigint primary key generated always as identity,
  nombre text not null,
  descripcion text
);

create table partida_categoria (
  id bigint primary key generated always as identity,
  partida_id bigint not null references partidas_arancelarias (id),
  categoria_id bigint not null references categorias (id)
);

create table usuarios (
  id bigint primary key generated always as identity,
  nombre_usuario text not null unique,
  correo_electronico text not null unique,
  contrasena text not null,
  fecha_registro timestamp with time zone default now()
);

alter table partidas_arancelarias
add column usuario_id bigint references usuarios (id);

alter table detalles_partidas
add column usuario_id bigint references usuarios (id);

alter table categorias
add column usuario_id bigint references usuarios (id);

alter table detalles_partidas
drop usuario_id;

alter table categorias
drop usuario_id;

alter table partidas_arancelarias
drop usuario_id;

alter table partidas_arancelarias
add column usuario_id bigint references usuarios (id);