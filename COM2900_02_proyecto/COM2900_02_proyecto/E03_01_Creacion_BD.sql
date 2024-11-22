/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a la creación de la base de datos, de los esquemas y de las tablas
	del sistema.
*/
--drop database Com2900G02;

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = N'Com2900G02')
BEGIN
	CREATE DATABASE Com2900G02
	COLLATE Modern_Spanish_CI_AI;
END
GO



USE Com2900G02;
GO
---------------------------------------------------------------------------------------------
-- Se crean los esquemas del sistema
---------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'gestion_tienda')
    exec('CREATE SCHEMA gestion_tienda');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'datos_tienda')
    exec('CREATE SCHEMA datos_tienda');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'gestion_productos')
    exec('CREATE SCHEMA gestion_productos');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'datos_productos')
    exec('CREATE SCHEMA datos_productos');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'gestion_ventas')
    exec('CREATE SCHEMA gestion_ventas');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'datos_ventas')
    exec('CREATE SCHEMA datos_ventas');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'gestion_clientes')
    exec('CREATE SCHEMA gestion_clientes');
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'datos_clientes')
    exec('CREATE SCHEMA datos_clientes');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'reportes')
    exec('CREATE SCHEMA reportes');
GO



/*
	Verificar si no existe y crear la tabla Sucursal.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_tienda.Sucursal') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_tienda.Sucursal(
		ID_sucursal int IDENTITY(1,1),
		nombre_sucursal varchar(30) not null,
		ciudad varchar(30) not null,
		direccion varchar(100) not null,
		horario varchar(80) not null,
		telefono int,
		habilitado bit default 1,
		constraint pk_sucursal primary key(ID_sucursal)
	);
END
GO


/*
	Verificar si no existe y crear la tabla punto de venta.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_tienda.punto_de_venta') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_tienda.punto_de_venta(
		ID_punto_venta INT IDENTITY(1,1) primary key,
		nro_caja int CHECK(nro_caja>0),
		ID_sucursal int,
		habilitado bit default 1,
		CONSTRAINT fk_medio_pago foreign key(ID_sucursal) references gestion_tienda.Sucursal(ID_sucursal),
		CONSTRAINT UNIQUE_cajaPorSucursal UNIQUE(nro_caja,ID_sucursal)
	);
END		
GO


/*
	Verificar si no existe y crear la tabla Cargo.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_tienda.Cargo') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_tienda.Cargo(
		id_cargo INT IDENTITY(1,1) primary key,
		cargo varchar(25) unique
	);
END
GO


/*
	Verificar si no existe y crear la tabla Empleado.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_tienda.Empleado') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_tienda.Empleado(
		ID_empleado INT IDENTITY(1,1),
		legajo INT unique not null,
		nombre varchar(40) not null,
		apellido varchar(30) not null,
		num_documento INT not null, 
		tipo_documento char(2) not null,
		direccion varchar(100) not null,
		email_personal varchar(80),
		email_empresarial varchar(80),
		CUIL char(13) not null,
		cargo int,
		sucursal_id int,
		turno char(2) default 'NA', --No Asignado
		habilitado bit default 1,

		
		CONSTRAINT pk_empleados primary key(ID_empleado),
		CONSTRAINT fk_sucursal foreign key(sucursal_id) references gestion_tienda.Sucursal(ID_sucursal),
		CONSTRAINT CHECK_turno CHECK(
			turno in('TM','TT','TN','JC', 'NA')),
		CONSTRAINT fk_cargo foreign key(cargo) references gestion_tienda.Cargo(id_cargo),
		CONSTRAINT CHECK_legajo CHECK(legajo > 0),
		CONSTRAINT CHECK_CUIL CHECK(
			CUIL like '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]'),
		CONSTRAINT UNIQUE_TipoDoc_NumDoc UNIQUE (tipo_documento, num_documento)
	);
END
GO



/*
	Verificar si no existe y crear la tabla Medios de pago.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Medio_de_Pago') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_ventas.Medio_de_Pago(
		ID_MP INT IDENTITY(1,1) primary key,
		nombre_ES varchar(24) not null unique,
		nombre_EN varchar(24) not null unique, 
		habilitado bit default 1
	);
END
GO


/*
	Verificar si no existe y crear la tabla Linea Producto.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_productos.Linea_Producto') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_productos.Linea_Producto(
		ID_lineaprod INT identity(1,1) primary key,
		linea_prod varchar(35) not null,
		habilitado bit default 1
	);
END
GO



/*
	Verificar si no existe y crear la tabla Producto.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_productos.Producto') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_productos.Producto(
		ID_prod INT IDENTITY(1,1),
		nombre_Prod varchar(90) not null,
		categoria varchar(50) not null,
		precio decimal(10,2) check(precio>0) not null,
		moneda char(3) default 'ARS' not null,
		referencia_precio decimal(10,2) check(referencia_precio>0) null,
		referencia_unidad varchar(6) null,
		cod_linea_prod int,
		habilitado bit default 1,

		CONSTRAINT pk_producto primary key(ID_prod),
		CONSTRAINT fk_linea_prod foreign key(cod_linea_prod) references gestion_productos.Linea_Producto(ID_lineaprod)
	);
END
GO

/*
	Verificar si no existe y crear la tabla Cliente.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_clientes.cliente') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_clientes.Cliente(
		ID_cliente INT IDENTITY(1,1) PRIMARY KEY,
		num_documento INT not null,
		tipo_documento char(2) not null,
		tipo_cliente char(6) not null,
		habilitado bit default 1,
		genero char(6),
		CUIL char(13) default '20-22222222-3' not null, --CUIL genérico definido por AFIP
		CONSTRAINT UNIQUE_TipoDoc_NumDoc UNIQUE (tipo_documento, num_documento),
		CONSTRAINT CHECK_tipoCliente CHECK(
			tipo_cliente LIKE 'Member' or
			tipo_cliente LIKE 'Normal'),
		CONSTRAINT CHECK_genero CHECK(
			genero LIKE 'Male' or
			genero LIKE 'Female'),
		CONSTRAINT CHECK_CUIL CHECK(
			CUIL like '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]')
	);
END
GO


/*
	Verificar si no existe y crear las tablas venta y factura.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Factura') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_ventas.Factura
	(
		ID_factura INT IDENTITY(1,1) primary key,
		nro_factura CHAR(11) not null UNIQUE,
		tipo_factura char(1) not null,
		estado_factura char(2) default 'PE' not null,
		total_neto_sinIVA decimal(10,2) CHECK(total_neto_sinIVA>0) not null,
		IVA decimal(10,2) CHECK(IVA>0) not null,
		CUIT_supermercado char(13) not null,
		CUIL_cliente char(13) not null,
		fecha_hora_emision datetime, --Con precision de milisegundos

		CONSTRAINT CHECK_tipo_factura CHECK(
			tipo_factura in('A','B','C')),
		CONSTRAINT CHECK_estado_factura CHECK(
			estado_factura in ('PE','PA','CA'))
	);
END
GO
/*
	Definimos el estado de factura como
	PE = Pendiente
	PA = Pagada
	CA = Cancelada
*/

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Venta') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_ventas.Venta(
		ID_venta INT IDENTITY(1,1) primary key,
		ID_punto_venta int not null,
		ID_cliente int null,
		fecha DATE not null,
		hora TIME not null,
		id_medio_pago int not null,
		ID_empleado int not null,
		identificador_pago varchar(40),
		ID_factura INT,

		CONSTRAINT fk_empleado foreign key(ID_empleado) references gestion_tienda.Empleado(ID_empleado),
		CONSTRAINT fk_cliente foreign key(ID_cliente) references gestion_clientes.cliente(ID_cliente),
		CONSTRAINT fk_medio_pago foreign key(id_medio_pago) references gestion_ventas.Medio_de_Pago(ID_MP),
		CONSTRAINT fk_punt_venta foreign key(ID_punto_venta) references 
		gestion_tienda.punto_de_venta(ID_punto_venta),
		CONSTRAINT fk_factura foreign key(ID_factura) references gestion_ventas.Factura(ID_factura)
	);
END
GO



/*
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Comprobante_venta') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_ventas.Comprobante_venta(
		ID_venta INT IDENTITY(1,1) primary key,
		ID_factura CHAR(11) not null UNIQUE,
		tipo_factura char(1) not null,
		ID_punto_venta int not null,
		ID_cliente int null,
		fecha DATE not null,
		hora TIME not null,
		id_medio_pago int not null,
		ID_empleado int not null,
		identificador_pago varchar(40),
		factura_pagada bit default 1,
		total_sinIVA decimal(10,2) CHECK(total_sinIVA>0) not null,
		IVA decimal(10,2) CHECK(iva>0) not null,


		CONSTRAINT fk_empleado foreign key(ID_empleado) references gestion_tienda.Empleado(ID_empleado),
		CONSTRAINT fk_cliente foreign key(ID_cliente) references gestion_clientes.cliente(ID_cliente),
		CONSTRAINT fk_medio_pago foreign key(id_medio_pago) references gestion_ventas.Medio_de_Pago(ID_MP),
		CONSTRAINT CHECK_tipo_factura CHECK(
			tipo_factura in('A','B','C')),
		CONSTRAINT fk_punt_venta foreign key(ID_punto_venta) references 
		gestion_tienda.punto_de_venta(ID_punto_venta)
	);
END
GO
*/


/*
	Verificar si no existe y crear la tabla detalle_venta.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Detalle_venta') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_ventas.Detalle_venta(
		ID_detalle_venta INT IDENTITY(1,1) primary key,
		ID_venta int not null,
		ID_prod int not null,
		subtotal decimal(10,2) check(subtotal>0) not null,
		cantidad int not null check(cantidad>0),
		CONSTRAINT fk_venta foreign key(ID_venta) references gestion_ventas.Venta(ID_venta),
		CONSTRAINT fk_producto foreign key(ID_prod) references gestion_productos.Producto(ID_prod),
	);
END
GO


/*
	Verificar si no existe y crear la tabla cotizacion para su utilizacion en la insercion de ventas.
*/
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_tienda.Cotizacion_USD') 
               AND type = N'U')
BEGIN
    CREATE TABLE gestion_tienda.Cotizacion_USD (
		ID_cotizacion int identity(1,1),
        valor_dolar DECIMAL(10,2),
        fecha SMALLDATETIME DEFAULT GETDATE()
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Configuracion_Supermercado') 
               AND type = N'U')
BEGIN
    CREATE TABLE gestion_ventas.Configuracion_Supermercado (
		CUIT_supermercado char(13),
		fecha_hora_actualizacion datetime default GETDATE()
    );
END
GO


