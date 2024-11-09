USE Com2900G02
GO

-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE SUCURSAL
-------------------------------------------------------------------------------------

CREATE or ALTER PROCEDURE datos_tienda.insertar_sucursal
@nombre varchar(30),
@ciudad varchar(30),
@direccion varchar(70),
@horario varchar(40),
@telefono int = null
AS
BEGIN
	insert into gestion_tienda.Sucursal (nombre_sucursal,ciudad,direccion,horario,telefono)
	values (@nombre,@ciudad,@direccion,@horario,@telefono)
END;
GO

CREATE or ALTER PROCEDURE datos_tienda.actualizar_sucursal
@ID_sucursal int,
@nombre varchar(30) = NULL,
@ciudad varchar(30) = NULL,
@direccion varchar(70) = NULL,
@horario varchar(40) = NULL,
@telefono int = NULL
AS
BEGIN
	update gestion_tienda.Sucursal
	set	nombre_sucursal = isnull(@nombre,nombre_sucursal),
		ciudad = isnull(@ciudad,ciudad),
		direccion = isnull(@direccion,direccion),
		horario = isnull(@horario, horario),
		telefono = isnull(@telefono, telefono)
	where ID_sucursal = @ID_sucursal;
END;
GO


create or alter procedure datos_tienda.borrar_sucursal
@ID_sucursal int
as
begin
	update gestion_tienda.Sucursal
	set habilitado = 0;
end
GO

create or alter procedure datos_tienda.reactivar_sucursal
@ID_sucursal int
as
begin
	update gestion_tienda.Sucursal
	set habilitado = 1;
end
GO

-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE PUNTO DE VENTA
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_tienda.punto_de_venta') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_tienda.punto_de_venta(
		ID_punto_venta int primary key,
		nro_caja int CHECK(nro_caja>0),
		ID_sucursal int,
		habilitado bit default 1,
		CONSTRAINT fk_medio_pago foreign key(ID_sucursal) references gestion_tienda.Sucursal(ID_sucursal),
		CONSTRAINT UNIQUE_cajaPorSucursal UNIQUE(nro_caja,ID_sucursal)
	);
END		
GO
-------------------------------------------------------------------------------------

CREATE or ALTER PROCEDURE datos_tienda.insertar_puntoDeVenta
@ID_sucursal int,
AS
BEGIN
	insert into gestion_tienda.Sucursal (nombre_sucursal,ciudad,direccion,horario,telefono)
	values (@nombre,@ciudad,@direccion,@horario,@telefono)
END;
GO

CREATE or ALTER PROCEDURE datos_tienda.actualizarSucursal
@ID_sucursal int,
@nombre varchar(30) = NULL,
@ciudad varchar(30) = NULL,
@direccion varchar(70) = NULL,
@horario varchar(40) = NULL,
@telefono int = NULL
AS
BEGIN
	update gestion_tienda.Sucursal
	set	nombre_sucursal = isnull(@nombre,nombre_sucursal),
		ciudad = isnull(@ciudad,ciudad),
		direccion = isnull(@direccion,direccion),
		horario = isnull(@horario, horario),
		telefono = isnull(@telefono, telefono)
	where ID_sucursal = @ID_sucursal;
END;
GO


create or alter procedure datos_tienda.BorrarSucursal
@ID_sucursal int
as
begin
	update gestion_tienda.Sucursal
	set habilitado = 0;
end
GO




create or alter procedure gestion_empleados.InsertarCargo
@cargo varchar(25)
as
begin

	insert into gestion_empleados.Cargo (cargo)
	values (@cargo)

end
GO

create or alter procedure gestion_empleados.ModificarCargo
@cargo varchar(25)
as
begin

	update gestion_empleados.Cargo
	set	cargo = @cargo
	where cargo = @cargo

end
GO

create or alter procedure gestion_empleados.BorrarCargo
@cargo varchar(25)
as
begin

	delete from gestion_empleados.Cargo
	where cargo = @cargo

end
GO

-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE EMPLEADO
-------------------------------------------------------------------------------------


create or alter procedure gestion_tienda.InsertarEmpleado
@legajo int,
@nombre varchar(40),
@apellido varchar(30),
@num_documento int,
@tipo_documento char(3),
@direccion varchar(70),
@email_personal varchar(70) = NULL,
@email_empresarial varchar(70) = NULL,
@CUIL char(13) = NULL,
@cargo int,
@sucursal_id int,
@turno char(2) = 'NA'
as
begin

	insert into gestion_tienda.Empleado(legajo,nombre,apellido,num_documento,tipo_documento,direccion,email_personal,email_empresarial,CUIL,cargo,sucursal_id,turno)
	values (@legajo,@nombre,@apellido,@num_documento,@tipo_documento,@direccion,@email_personal,@email_empresarial,@CUIL,@cargo,@sucursal_id,@turno)

end
GO

create or alter procedure gestion_empleados.ModificarEmpleado
@legajo int,
@nombre varchar(40) = NULL,
@apellido varchar(30) = NULL,
@DNI int = NULL,
@direccion varchar(70) = NULL,
@email_personal varchar(70) = NULL,
@email_empresarial varchar(70) = NULL,
@CUIL int = NULL,
@cargo varchar(25) = NULL,
@sucursal_ID int = NULL,
@turno char(2) = 'NA'
as
begin

	update gestion_empleados.Empleado
	set	nombre = isnull(@nombre,nombre),
		apellido = isnull(@apellido,apellido),
		DNI = isnull(@DNI,DNI),
		direccion = isnull(@direccion,direccion),
		email_personal = isnull(@email_personal,email_personal),
		email_empresarial = isnull(@email_empresarial,email_empresarial),
		CUIL = isnull(@CUIL,CUIL),
		cargo = isnull(@cargo,cargo),
		sucursal_ID = isnull(@sucursal_ID,sucursal_ID),
		turno = isnull(@turno,turno)
	where legajo = @legajo

end
GO

create or alter procedure gestion_empleados.BorrarEmpleado
@legajo int
as
begin

	delete from gestion_empleados.Empleado
	where legajo = @legajo

end
GO

create or alter procedure gestion_sistema.InsertarMedio_de_Pago
@nombre_ES varchar(20),
@nombre_EN varchar(20)
as
begin

	insert gestion_sistema.Medio_de_Pago(nombre_ES,nombre_EN)
	values (@nombre_ES,@nombre_EN)

end
GO

create or alter procedure gestion_sistema.ModificarMedio_de_Pago
@ID_MP int,
@nombre_ES varchar(20) = NULL,
@nombre_EN varchar(20) = NULL,
@habilitado bit = 1
as
begin

	update gestion_sistema.Medio_de_Pago
	set	nombre_ES = isnull(@nombre_ES,nombre_ES),
		nombre_EN = isnull(@nombre_EN,nombre_EN)
	where ID_MP = @ID_MP

end
GO

create or alter procedure gestion_sistema.BorrarMedio_de_Pago
@ID_MP int
as
begin

	update gestion_sistema.Medio_de_Pago
	set habilitado = 0

end
GO

create or alter procedure gestion_productos.InsertarLinea_Producto
@linea_prod varchar(35),
@nombre_prod varchar(70)
as
begin

	insert gestion_productos.Linea_Producto(linea_prod,nombre_prod)
	values (@linea_prod,@nombre_prod)

end
GO

create or alter procedure gestion_productos.ModificarLinea_Producto
@ID_lp int,
@linea_prod varchar(35) = NULL,
@nombre_prod varchar(70) = NULL
as
begin

	update gestion_productos.Linea_Producto
	set	linea_prod = isnull(@linea_prod,linea_prod),
		nombre_prod = isnull(@nombre_prod,nombre_prod)
	where ID_lp = @ID_lp

end
GO

create or alter procedure gestion_productos.BorrarLinea_Producto
@ID_lp int
as
begin

	delete from gestion_productos.Linea_Producto
	where ID_lp = @ID_lp

end
GO

create or alter procedure gestion_productos.InsertarProducto
@nombreProd varchar(70),
@categoria varchar(20),
@precio decimal(10,2),
@referencia_precio decimal(10,2) = NULL,
@reference_unit varchar(6) = NULL,
@cod_linea_prod int
as
begin

	insert gestion_productos.Producto(nombreProd,categoria,precio,referencia_precio,reference_unit,cod_linea_prod)
	values (@nombreProd,@categoria,@precio,@referencia_precio,@reference_unit,@cod_linea_prod)

end
GO

create or alter procedure gestion_productos.ModificarProducto
@ID_prod int,
@nombreProd varchar(70) = NULL,
@categoria varchar(20) = NULL,
@precio decimal(10,2) = NULL,
@referencia_precio decimal(10,2) = NULL,
@reference_unit varchar(6) = NULL,
@cod_linea_prod int = NULL
as
begin

	update gestion_productos.Producto
	set	nombreProd = isnull(@nombreProd,nombreProd),
		categoria = isnull(@categoria,categoria),
		precio = isnull(@precio,precio),
		referencia_precio = isnull(@referencia_precio, referencia_precio),
		reference_unit = isnull(@reference_unit, reference_unit),
		cod_linea_prod = isnull(@cod_linea_prod,cod_linea_prod)
	where ID_prod = @ID_prod

end
GO

create or alter procedure gestion_productos.BorrarProducto
@ID_prod int
as
begin

	delete from gestion_productos.Producto
	where ID_prod = @ID_prod

end
GO

create or alter procedure gestion_productos.InsertarComprobante_venta
@ID_factura CHAR(11),
@tipo_factura char(1),
@ID_sucursal int,
@tipo_cliente char(6) = NULL,
@genero char(6) = NULL,
@id_medio_pago int,
@empleado_legajo int,
@identificador_pago varchar(22),
@total decimal(10,2) = NULL
as
begin

	insert gestion_productos.Comprobante_venta(ID_factura,tipo_factura,ID_sucursal,tipo_cliente,genero,fecha,hora,id_medio_pago,empleado_legajo,identificador_pago,total)
	values (@ID_factura,@tipo_factura,@ID_sucursal,@tipo_cliente,@genero,cast(GETDATE() as DATE),cast(GETDATE() as TIME),@id_medio_pago,@empleado_legajo,@identificador_pago,@total)

end
GO

create or alter procedure gestion_productos.ModificarComprobante_venta
@ID_venta int,
@ID_factura CHAR(11) = NULL,
@tipo_factura char(1) = NULL,
@ID_sucursal int = NULL,
@tipo_cliente char(6) = NULL,
@genero char(6) = NULL,
@id_medio_pago int = NULL,
@empleado_legajo int = NULL,
@identificador_pago varchar(22) = NULL,
@total decimal(10,2) = NULL
as
begin

	update gestion_productos.Comprobante_venta
	set	ID_factura = isnull(@ID_factura,ID_factura),
		tipo_factura = isnull(@tipo_factura,tipo_factura),
		ID_sucursal = isnull(@ID_sucursal,ID_sucursal),
		tipo_cliente = isnull(@tipo_cliente, tipo_cliente),
		genero = isnull(@genero, genero),
		id_medio_pago = isnull(@id_medio_pago, id_medio_pago),
		empleado_legajo = isnull(@empleado_legajo, empleado_legajo),
		identificador_pago = isnull(@identificador_pago, identificador_pago),
		total = isnull(@total, total)
	where ID_venta = @ID_venta

end
GO

create or alter procedure gestion_productos.BorrarComprobante_venta
@ID_venta int
as
begin

	delete from gestion_productos.Comprobante_venta
	where ID_venta = @ID_venta

end
GO

create or alter procedure gestion_productos.InsertarDetalle_venta
@ID_factura CHAR(11),
@ID_prod int,
@precio_unitario decimal(10,2),
@cantidad int
as
begin

	insert gestion_productos.Detalle_venta(ID_factura,ID_prod,precio_unitario,cantidad)
	values (@ID_factura,@ID_prod,@precio_unitario,@cantidad)

end
GO

create or alter procedure gestion_productos.ModificarDetalle_venta
@ID_detalle_factura int,
@ID_factura CHAR(11) = NULL,
@ID_prod int = NULL,
@precio_unitario decimal(10,2) = NULL,
@cantidad int = NULL
as
begin

	update gestion_productos.Detalle_venta
	set	ID_factura = isnull(@ID_factura,ID_factura),
		ID_prod = isnull(@ID_prod,ID_prod),
		precio_unitario = isnull(@precio_unitario,precio_unitario),
		cantidad = isnull(@cantidad, cantidad)
	where ID_detalle_factura = @ID_detalle_factura

end
GO

create or alter procedure gestion_productos.BorrarDetalle_venta
@ID_detalle_factura int
as
begin

	delete from gestion_productos.Detalle_venta
	where ID_detalle_factura = @ID_detalle_factura

end
GO