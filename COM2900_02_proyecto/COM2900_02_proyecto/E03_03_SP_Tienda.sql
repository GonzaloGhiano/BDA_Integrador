/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a la creación de los Store Procedure de las tablas pertenecientes al esquema tienda.
*/

USE Com2900G02
GO

-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE SUCURSAL
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



-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE PUNTOS DE VENTA
-------------------------------------------------------------------------------------


CREATE or ALTER PROCEDURE datos_tienda.insertar_puntoDeVenta
@nro_caja int,
@ID_sucursal int
AS
BEGIN
	DECLARE @error varchar(max) = '';

	-- Validar nro_caja
	IF(@nro_caja <= 0)
		SET @error = @error + 'La caja debe ser mayor a 0';

	-- Validar sucursal
	IF NOT EXISTS (SELECT 1 from gestion_tienda.Sucursal sucursal
					WHERE sucursal.ID_sucursal = @ID_sucursal)
		SET @error = @error + 'La sucursal no es valida';

	IF(@error = '')
	BEGIN
		insert into gestion_tienda.punto_de_venta(nro_caja, ID_sucursal)
		values (@nro_caja,@ID_sucursal)
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END;
GO


CREATE or ALTER PROCEDURE datos_tienda.actualizar_puntoDeVenta
@ID_punto_venta int,
@nro_caja int = NULL,
@ID_sucursal int = NULL
AS
BEGIN
	DECLARE @error varchar(max) = '';

	
	-- Validar nro_caja
	IF(@nro_caja <= 0)
		SET @error = @error + 'La caja debe ser mayor a 0';

	-- Validar ID_PuntodeVenta
	IF NOT EXISTS (SELECT 1 from gestion_tienda.punto_de_venta pv
					WHERE pv.ID_punto_venta = @ID_punto_venta)
		SET @error = @error + 'El punto de venta no existe';

	-- Validar sucursal
	IF @ID_sucursal IS NOT NULL AND NOT EXISTS (SELECT 1 from gestion_tienda.Sucursal sucursal
					WHERE sucursal.ID_sucursal = @ID_sucursal)
		SET @error = @error + 'La sucursal no es valida';

	IF(@error = '')
	BEGIN
		UPDATE gestion_tienda.punto_de_venta
		set nro_caja = isnull(@nro_caja,nro_caja),
			ID_sucursal = isnull(@ID_sucursal,ID_sucursal)
		where ID_punto_venta = @ID_punto_venta;
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END;
GO

create or alter procedure datos_tienda.borrar_puntoDeVenta
@ID_punto_venta int
as
begin
	IF NOT EXISTS(Select 1 from gestion_tienda.punto_de_venta pv
				where pv.ID_punto_venta = @ID_punto_venta)
		  RAISERROR('El punto de venta %d no existe', 16, 1, @ID_punto_venta);
	ELSE
	BEGIN
		update gestion_tienda.punto_de_venta
		set habilitado = 0;
	END
END
GO

create or alter procedure datos_tienda.reactivar_puntoDeVenta
@ID_punto_venta int
as
begin
	IF NOT EXISTS(Select 1 from gestion_tienda.punto_de_venta pv
				where pv.ID_punto_venta = @ID_punto_venta)
		  RAISERROR('El punto de venta %d no existe', 16, 1, @ID_punto_venta);
	ELSE
	BEGIN
		update gestion_tienda.punto_de_venta
		set habilitado = 1;
	END
END
GO



-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE EMPLEADO
-------------------------------------------------------------------------------------


create or alter procedure datos_tienda.insertar_empleado
@legajo int,
@nombre varchar(40),
@apellido varchar(30),
@num_documento int = NULL,
@tipo_documento char(2) = NULL,
@direccion varchar(80),
@email_personal varchar(80) = NULL,
@email_empresarial varchar(80),
@CUIL char(13),
@cargo int = NULL,
@sucursal_id int = NULL,
@turno char(2) = 'NA'
AS
BEGIN

	DECLARE @error varchar(max) = '';
	--Validar CUIL
	IF(ISNULL(@CUIL, '') = '')
		SET @error = @error + 'ERROR: El CUIL no puede ser vacio'
	
	--Validar num_Documento
	IF(gestion_tienda.validar_num_documento(@num_documento) = 0)
		SET @error = @error + 'ERROR: Numero de documento invalido';
	
	--Validar Tipo_Doc
	IF(gestion_tienda.validar_tipo_documento(@tipo_documento) = 0)
		SET @error = @error + 'ERROR: Tipo de documento invalido'

	-- Validar formato legajo
	IF(ISNULL(@legajo, 0) = 0)
		SET @error = @error + 'ERROR: El legajo no puede ser vacio'
	ELSE IF(@legajo <= 0)
		SET @error = @error + 'Formato de legajo incorrecto';
	

	IF(@error = '')
	BEGIN

		insert gestion_tienda.Empleado
		(legajo,nombre,apellido,num_documento,tipo_documento,direccion,email_personal,email_empresarial,
		CUIL,cargo,sucursal_id,turno)
		values 
		(@legajo,@nombre,@apellido,@num_documento,@tipo_documento,@direccion,@email_personal,@email_empresarial,
		@CUIL,@cargo,@sucursal_id,@turno)

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO

create or alter procedure datos_tienda.modificar_empleado
@ID_empleado int,
@legajo int = NULL,
@nombre varchar(40) = NULL,
@apellido varchar(30) = NULL,
@num_documento int = NULL,
@tipo_documento char(2) = NULL,
@direccion varchar(80) = NULL,
@email_personal varchar(80) = NULL,
@email_empresarial varchar(80) = NULL,
@CUIL char(13) = NULL,
@cargo int = NULL,
@sucursal_id int = NULL,
@turno char(2) = 'NA'
as
begin

	DECLARE @error varchar(max) = '';

	--Validar existencia del ID
	IF NOT EXISTS (SELECT 1 from gestion_tienda.Empleado
					WHERE ID_empleado = @ID_empleado)
		SET @error = @error + 'ID de empleado inexistente';

	--Validar num_Documento
	IF(@num_documento is not null and gestion_tienda.validar_num_documento(@num_documento) = 0)
		SET @error = @error + 'ERROR: Numero de documento invalido';

	--Validar Tipo_Doc
	IF(@tipo_documento is not null and gestion_tienda.validar_tipo_documento(@tipo_documento) = 0)
		SET @error = @error + 'ERROR: Tipo de documento invalido'

	-- Validar formato legajo
	IF(@legajo is not null and @legajo <= 0)
		SET @error = @error + 'Formato de legajo incorrecto';

	IF(@error = '')
	BEGIN

		update gestion_tienda.Empleado
		set	legajo = isnull(@legajo,legajo),
			nombre = isnull(@nombre,nombre),
			apellido = isnull(@apellido,apellido),
			num_documento = isnull(@num_documento,num_documento),
			tipo_documento = isnull(@tipo_documento,tipo_documento),
			direccion = isnull(@direccion,direccion),
			email_personal = isnull(@email_personal,email_personal),
			email_empresarial = isnull(@email_empresarial,email_empresarial),
			CUIL = isnull(@CUIL,CUIL),
			cargo = isnull(@cargo,cargo),
			sucursal_id = isnull(@sucursal_id,sucursal_id),
			turno = isnull(@turno,turno)
		where ID_empleado = @ID_empleado

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
end
GO

create or alter procedure datos_tienda.borrar_empleado
@ID_empleado int
as
begin

	DECLARE @error varchar(max) = '';

	--Validar existencia del ID
	IF NOT EXISTS (SELECT 1 from gestion_tienda.Empleado
					WHERE ID_empleado = @ID_empleado)
		SET @error = @error + 'ID de empleado inexistente';

	IF(@error = '')
	BEGIN

		update gestion_tienda.Empleado
		set habilitado = 0
		where ID_empleado = @ID_empleado

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
end
GO

create or alter procedure datos_tienda.reactivar_empleado
@ID_empleado int
as
begin

	DECLARE @error varchar(max) = '';

	--Validar existencia del ID
	IF NOT EXISTS (SELECT 1 from gestion_tienda.Empleado
					WHERE ID_empleado = @ID_empleado)
		SET @error = @error + 'ID de empleado inexistente';

	IF(@error = '')
	BEGIN

		update gestion_tienda.Empleado
		set habilitado = 1
		where ID_empleado = @ID_empleado

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
end
GO


-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE SUCURSAL Cotizacion_USD
-------------------------------------------------------------------------------------

create or alter procedure datos_tienda.insertar_Cotizacion_USD
@valor decimal(10,2)
as
begin
	insert gestion_tienda.Cotizacion_USD(valor_dolar)
	values (@valor)

end
GO


create or alter procedure datos_tienda.eliminar_Cotizacion_USD
@ID_cotizacion int
as
begin
	DELETE FROM gestion_tienda.Cotizacion_USD
	where ID_cotizacion = @ID_cotizacion

end
GO

create or alter procedure datos_tienda.modificar_Cotizacion_USD
@ID_cotizacion int,
@valor decimal(10,2)
as
begin
	UPDATE gestion_tienda.Cotizacion_USD
	SET valor_dolar = @valor,
	fecha = GETDATE()
	where ID_cotizacion = @ID_cotizacion

end
GO


-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE SUCURSAL Cargo
-------------------------------------------------------------------------------------

create or alter procedure datos_tienda.insertar_cargo
@cargo varchar(25)
as
begin
	insert gestion_tienda.Cargo(cargo)
	values (@cargo)
end
GO


create or alter procedure datos_tienda.eliminar_cargo
@id_cargo int
as
begin
	IF(EXISTS(SELECT 1 FROM gestion_tienda.Cargo WHERE id_cargo = @id_cargo))
		DELETE FROM gestion_tienda.Cargo
		where id_cargo = @id_cargo
	ELSE
		RAISERROR('Id no encontrado',16,1);
end
GO

create or alter procedure datos_tienda.modificar_Cotizacion_USD
@id_cargo int,
@cargo varchar(25)
as
BEGIN
	IF(EXISTS(SELECT 1 FROM gestion_tienda.Cargo WHERE id_cargo = @id_cargo))
		UPDATE gestion_tienda.Cargo
		SET cargo = @cargo
		WHERE id_cargo = @id_cargo
	ELSE
		RAISERROR('Id no encontrado',16,1);
END
GO

