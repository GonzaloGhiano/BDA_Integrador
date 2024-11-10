USE Com2900G02;
GO

create or alter procedure datos_clientes.insertar_cliente
@num_documento char(8),
@tipo_documento char(3),
@tipo_cliente char(6),
@genero char(6)
AS
BEGIN

	DECLARE @error varchar(max) = '';

	-- Validar formato documento
	IF(@num_documento not like('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
		SET @error = @error + 'Formato invalido de documento';

	-- Validar tipo documento
	IF(@tipo_documento not like('[A-Z][A-Z][A-Z]'))
		SET @error = @error + 'Tipo documento no válido';

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

create or alter procedure datos_clientes.modificar_cliente
@ID_cliente int,
@num_documento char(8) = NULL,
@tipo_documento char(3) = NULL,
@tipo_cliente char(6) = NULL,
@genero char(6) = NULL
AS
BEGIN

	DECLARE @error varchar(max) = '';

	--Validar existencia del ID
	IF NOT EXISTS (SELECT 1 from gestion_clientes.Cliente
					WHERE ID_cliente = @ID_cliente)
		SET @error = @error + 'ID de empleado inexistente';

	-- Validar formato documento
	IF(@num_documento is not null and @num_documento not like('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
		SET @error = @error + 'Formato invalido de documento';

	-- Validar tipo documento
	IF(@tipo_documento is not null and @tipo_documento not like('[A-Z][A-Z][A-Z]'))
		SET @error = @error + 'Tipo documento no válido';

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