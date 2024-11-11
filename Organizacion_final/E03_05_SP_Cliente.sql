/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a la creación de los Store Procedure de las tablas pertenecientes al esquema Cliente.
*/

USE Com2900G02;
GO


-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE CLIENTE
-------------------------------------------------------------------------------------



create or alter procedure datos_clientes.insertar_cliente
@num_documento char(8),
@tipo_documento char(2),
@tipo_cliente char(6),
@genero char(6) = NULL
AS
BEGIN

	DECLARE @error varchar(max) = '';

	--Validar num_Documento
	IF(gestion_tienda.validar_num_documento(@num_documento) = 0)
		SET @error = @error + 'ERROR: Numero de documento invalido';

	--Validar Tipo_Doc
	IF(gestion_tienda.validar_tipo_documento(@tipo_documento) = 0)
		SET @error = @error + 'ERROR: Tipo de documento invalido'

	IF(@error = '')
	BEGIN

		insert gestion_clientes.Cliente(num_documento,tipo_documento,tipo_cliente,genero)
		values (@num_documento,@tipo_documento,@tipo_cliente,@genero)

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END

END
GO

create or alter procedure datos_clientes.modificar_cliente
@ID_cliente int,
@num_documento char(8) = NULL,
@tipo_documento char(2) = NULL,
@tipo_cliente char(6) = NULL,
@genero char(6) = NULL
AS
BEGIN

	DECLARE @error varchar(max) = '';

	--Validar existencia del ID
	IF NOT EXISTS (SELECT 1 from gestion_clientes.Cliente
					WHERE ID_cliente = @ID_cliente)
		SET @error = @error + 'ID de empleado inexistente';

	--Validar num_Documento
	IF(@num_documento is not null and gestion_tienda.validar_num_documento(@num_documento) = 0)
		SET @error = @error + 'ERROR: Numero de documento invalido';

	--Validar Tipo_Doc
	IF(@tipo_documento is not null and gestion_tienda.validar_tipo_documento(@tipo_documento) = 0)
		SET @error = @error + 'ERROR: Tipo de documento invalido'

	IF(@error = '')
	BEGIN

		update gestion_clientes.Cliente
		set num_documento = isnull(@num_documento,num_documento),
			tipo_documento = isnull(@tipo_documento,tipo_documento),
			tipo_cliente = isnull(@tipo_cliente,tipo_cliente),
			genero = isnull(@genero,genero)
		where ID_cliente = @ID_cliente

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END

END
GO

create or alter procedure datos_clientes.borrar_cliente
@ID_cliente int
AS
BEGIN

	DECLARE @error varchar(max) = '';

	--Validar existencia del ID
	IF NOT EXISTS (SELECT 1 from gestion_clientes.Cliente
					WHERE ID_cliente = @ID_cliente)
		SET @error = @error + 'ID de cliente inexistente';

	IF(@error = '')
	BEGIN

		update gestion_clientes.Cliente
		set habilitado = 0
		where ID_cliente = @ID_cliente

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END

END
GO

create or alter procedure datos_clientes.reactivar_cliente
@ID_cliente int
AS
BEGIN

	DECLARE @error varchar(max) = '';

	--Validar existencia del ID
	IF NOT EXISTS (SELECT 1 from gestion_clientes.Cliente
					WHERE ID_cliente = @ID_cliente)
		SET @error = @error + 'ID de cliente inexistente';

	IF(@error = '')
	BEGIN

		update gestion_clientes.Cliente
		set habilitado = 1
		where ID_cliente = @ID_cliente

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END

END
GO