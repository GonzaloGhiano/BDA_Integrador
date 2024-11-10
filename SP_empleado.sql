USE Com2900G02;
GO

create or alter procedure datos_tienda.insertar_empleado
@legajo char(6),
@nombre varchar(40),
@apellido varchar(30),
@num_documento char(8),
@tipo_documento char(3),
@direccion varchar(80),
@email_personal varchar(80) = NULL,
@email_empresarial varchar(80),
@CUIL char(13),
@cargo int,
@sucursal_id int,
@turno char(2) = 'NA'
as
begin

	DECLARE @error varchar(max) = '';

	-- Validar formato legajo
	IF(@legajo not like('[0-9][0-9][0-9][0-9][0-9][0-9]'))
		SET @error = @error + 'Formato de legajo incorrecto';

	IF(@error = '')
	BEGIN

		insert gestion_tienda.Empleado(legajo,nombre,apellido,num_documento,tipo_documento,direccion,email_personal,email_empresarial,CUIL,cargo,sucursal_id,turno)
		values (@legajo,@nombre,@apellido,@num_documento,@tipo_documento,@direccion,@email_personal,@email_empresarial,@CUIL,@cargo,@sucursal_id,@turno)

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END

	

end
GO

create or alter procedure datos_tienda.modificar_empleado
@ID_empleado int,
@legajo char(6) = NULL,
@nombre varchar(40) = NULL,
@apellido varchar(30) = NULL,
@num_documento char(8) = NULL,
@tipo_documento char(3) = NULL,
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

	-- Validar formato legajo
	IF(@legajo is not null and @legajo not like('[0-9][0-9][0-9][0-9][0-9][0-9]'))
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
		where legajo = @legajo

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