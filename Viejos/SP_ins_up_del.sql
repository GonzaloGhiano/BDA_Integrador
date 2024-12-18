USE Com2900G02
GO

-------------------------------------------------------------------------------------
-- CREACI�N DE LOS SP DE SUCURSAL
-------------------------------------------------------------------------------------

CREATE or ALTER PROCEDURE datos_tienda.insertar_sucursal
@nombre varchar(MAX) = null,
@ciudad varchar(MAX) = null,
@direccion varchar(MAX) = null,
@horario varchar(MAX) = null,
@telefono int = null
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar nombre de la sucursal
	IF(ISNULL(@nombre, '') = '') --Si vino vacio, es error. Si vino null, lo hago vacio y es error. 
		SET @error = @error + 'ERROR: El nombre de la sucursal no puede ser vacio.'
	ELSE IF(LEN(@nombre)>30)
		SET @error = @error + 'Nombre demasiado largo. Longitud maxima de 30 caracteres'

	--Validar ciudad
	IF(ISNULL(@ciudad, '') = '')
		SET @error = @error + 'ERROR: La ciudad de la sucursal no puede ser vacio'
	ELSE IF(LEN(@ciudad)>30)
		SET @error = @error + 'Longitud de ciudad ingresada demasiado largo. Longitud maxima de 30 caracteres'

	--Validar direccion
	IF(ISNULL(@direccion, '') = '')
		SET @error = @error + 'ERROR: La direccion de la sucursal no puede ser vacio.'

	--Validar horario
	IF(ISNULL(@horario, '') = '')
		SET @error = @error + 'ERROR: El horario de la sucursal no puede ser vacio.'
	
	IF(@error = '')
	BEGIN
		insert into gestion_tienda.Sucursal (nombre_sucursal,ciudad,direccion,horario,telefono)
		values (@nombre,@ciudad,@direccion,@horario,@telefono)
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END;
GO

CREATE or ALTER PROCEDURE datos_tienda.actualizar_sucursal
@ID_sucursal int,
@nombre varchar(MAX) = NULL,
@ciudad varchar(MAX) = NULL,
@direccion varchar(MAX) = NULL,
@horario varchar(MAX) = NULL,
@telefono int = NULL
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar nombre de la sucursal
	IF(@nombre = '') --Si vino vacio, es error. Si vino null, lo hago vacio y es error. 
		SET @error = @error + 'ERROR: El nombre de la sucursal no puede ser vacio.'
	ELSE IF(LEN(@nombre)>30)
		SET @error = @error + 'Nombre demasiado largo. Longitud maxima de 30 caracteres'

	--Validar ciudad
	IF(@ciudad = '')
		SET @error = @error + 'ERROR: La ciudad de la sucursal no puede ser vacio'
	ELSE IF(LEN(@ciudad)>30)
		SET @error = @error + 'Longitud de ciudad ingresada demasiado largo. Longitud maxima de 30 caracteres'

	--Validar direccion
	IF(@direccion = '')
		SET @error = @error + 'ERROR: La direccion de la sucursal no puede ser vacio.'

	--Validar horario
	IF(@horario = '')
		SET @error = @error + 'ERROR: El horario de la sucursal no puede ser vacio.'
	
	IF(@error = '')
	BEGIN
		update gestion_tienda.Sucursal
		set	nombre_sucursal = isnull(@nombre,nombre_sucursal),
			ciudad = isnull(@ciudad,ciudad),
			direccion = isnull(@direccion,direccion),
			horario = isnull(@horario, horario),
			telefono = isnull(@telefono, telefono)
		where ID_sucursal = @ID_sucursal;
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END;
GO


create or alter procedure datos_tienda.borrar_sucursal
@ID_sucursal int
as
begin
	IF NOT EXISTS(Select 1 from gestion_tienda.Sucursal sucursal
				where sucursal.ID_sucursal = @ID_sucursal)
		  RAISERROR('La sucursal %d no existe', 16, 1, @ID_sucursal);
	ELSE
	BEGIN
		update gestion_tienda.Sucursal
		set habilitado = 0;
	END
END
GO


create or alter procedure datos_tienda.reactivar_sucursal
@ID_sucursal int
as
begin
	IF NOT EXISTS(Select 1 from gestion_tienda.Sucursal sucursal
				where sucursal.ID_sucursal = @ID_sucursal)
		  RAISERROR('La sucursal %d no existe', 16, 1, @ID_sucursal);
	ELSE
	BEGIN
		update gestion_tienda.Sucursal
		set habilitado = 1;
	END
END
GO


/*
-------------------------------------------------------------------------------------------------

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


create or alter procedure gestion_empleados.InsertarEmpleado
@legajo int,
@nombre varchar(40),
@apellido varchar(30),
@DNI int,
@direccion varchar(70),
@email_personal varchar(70) = NULL,
@email_empresarial varchar(70),
@CUIL int,
@cargo varchar(25),
@sucursal_ID int,
@turno char(2) = 'NA'
as
begin

	insert into gestion_empleados.Empleado(legajo,nombre,apellido,DNI,direccion,email_personal,email_empresarial,CUIL,cargo,sucursal_ID,turno)
	values (@legajo,@nombre,@apellido,@DNI,@direccion,@email_personal,@email_empresarial,@CUIL,@cargo,@sucursal_ID,@turno)

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

*/