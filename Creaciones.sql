CREATE DATABASE Com2900G02
GO
USE Com2900G02
GO
CREATE SCHEMA gestion_empleados;
GO
CREATE SCHEMA gestion_productos;
GO
CREATE SCHEMA reportes;
GO
CREATE SCHEMA gestion_sistema;
GO
-- Esquema ventas para la tabla ventas?

/*
	Esquemas en minuscula sin espacios
	Tablas con primera letra en mayuscula y singular
	Atributos en miniscula excepcion de ID, DNI, CUIL u otras siglas significativas
*/

/*
drop table gestion_empleados.Empleado;
drop table gestion_empleados.Cargo;
drop table gestion_sistema.Sucursal;
drop table gestion_sistema.Medio_de_Pago
drop table gestion_productos.Linea_Producto
drop table gestion_productos.Producto
drop table gestion_productos.Venta
*/

/*
	Verificar si no existe y crear la tabla sucursal.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_sistema.Sucursal') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_sistema.Sucursal(
		ID_sucursal int IDENTITY(1,1),
		nombre_sucursal varchar(30) not null,
		ciudad varchar(30) not null,
		direccion varchar(70) not null,
		horario varchar(40) not null,
		telefono int,
		constraint pk_sucursal primary key(ID_sucursal)
	);
END
GO

-- ID para los sucursales? Y en que esquema queda mejor? uno nuevo?
-- en una tabla tan chica, el varchar o el char me cambia?

/*
	Verificar si no existe y crear la tabla sucursal.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_empleados.Cargo') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_empleados.Cargo(
		cargo varchar(25) primary key
	);
END
GO


/*
	Verificar si no existe y crear la tabla sucursal.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_empleados.Empleado') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_empleados.Empleado(
		legajo int not null,
		nombre varchar(40) not null,
		apellido varchar(30) not null,
		DNI char(9) not null unique, --unique? sin tipo-dni no es seguro hacerlo
		direccion varchar(70) not null,
		email_personal varchar(60),
		email_empresarial varchar(60) not null,
		CUIL varchar(20) not null, --calcularlo????? vasrchar o int?
		cargo varchar(25) not null,
		sucursal_id int not null,
		turno char(2) default 'NA', --no asignado
		CONSTRAINT pk_empleados primary key(legajo),
		CONSTRAINT fk_sucursal foreign key(sucursal_id) references gestion_sistema.Sucursal(ID_sucursal),
		CONSTRAINT CHECK_turno CHECK(
			turno in('TM','TT','TN','JC', 'NA')),
		CONSTRAINT fk_cargo foreign key(cargo) references gestion_empleados.Cargo(cargo),
	);
END
GO



/*
	Verificar si no existe y crear la tabla sucursal.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_sistema.Medio_de_Pago') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_sistema.Medio_de_Pago(
		ID_MP INT IDENTITY(1,1) primary key,
		nombre_ES varchar(20) not null unique,
		nombre_EN varchar(20) not null unique, 
		habilitado bit default 1
	);
END
GO
--drop table gestion_sistema.Medio_de_Pago;
--Vale la pena tener ES y EN? Vale la pena tener una tabla para los MP?
-- Booleano o multiples estados con CHAR?


/*
	Verificar si no existe y crear la tabla sucursal.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_productos.Linea_Producto') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_productos.Linea_Producto(
		ID_lp INT identity(1,1) primary key,
		linea_prod varchar(35) not null,
		nombre_prod varchar(70) not null
	);
END
GO



/*
	Verificar si no existe y crear la tabla sucursal.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_productos.Producto') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_productos.Producto(
		ID_prod INT IDENTITY(1,1),
		nombreProd varchar(70) not null,
		categoria varchar(20) not null,
		precio decimal(10,2) check(precio>0) not null,
		referencia_precio decimal(10,2) check(referencia_precio>0) null,
		reference_unit varchar(6) null, --variabilidad de 1 a 6, mayoria 2, que conviene?
		cod_linea_prod int,
		CONSTRAINT pk_producto primary key(ID_prod),
		CONSTRAINT fk_linea_prod foreign key(cod_linea_prod) references gestion_productos.Linea_Producto(ID_lp)
	);
END
GO


/*
	Verificar si no existe y crear la tabla sucursal.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_productos.Comprobante_venta') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_productos.Comprobante_venta(
		ID_venta INT IDENTITY(1,1) primary key,
		ID_factura CHAR(11) not null UNIQUE,
		tipo_factura char(1) not null,
		ID_sucursal int not null,
		tipo_cliente char(6),
		genero char(6),
		fecha DATE not null,
		hora TIME not null,
		id_medio_pago int not null,
		empleado_legajo int not null,
		identificador_pago varchar(22) not null,
		total decimal(10,2) CHECK(total>0),
		CONSTRAINT fk_empleado foreign key(empleado_legajo) references gestion_empleados.Empleado(legajo),
		CONSTRAINT fk_medio_pago foreign key(id_medio_pago) references gestion_sistema.Medio_de_Pago(ID_MP),
		CONSTRAINT CHECK_tipo_factura CHECK(
			tipo_factura in('A','B','C')),
		CONSTRAINT CHECK_genero CHECK(
			genero LIKE 'Female' or
			genero LIKE 'Male'),
		CONSTRAINT CHECK_tipoCliente CHECK(
			tipo_cliente LIKE 'Member' or
			tipo_cliente LIKE 'Normal'),
		CONSTRAINT fk_sucursal foreign key(ID_sucursal) references gestion_sistema.Sucursal(ID_sucursal)
	);
END
GO



/*
	Verificar si no existe y crear la tabla sucursal.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_productos.Detalle_venta') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_productos.Detalle_venta(
		ID_detalle_factura INT IDENTITY(1,1) primary key,
		ID_factura CHAR(11) not null,
		ID_prod int not null,
		precio_unitario decimal(10,2) check(precio_unitario>0) not null,
		cantidad int not null check(cantidad>0),
		CONSTRAINT fk_producto foreign key(ID_prod) references gestion_productos.Producto(ID_prod),
	);
END
GO
