USE Com2900G02
GO

/*
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Medio_de_Pago') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_ventas.Medio_de_Pago(
		ID_MP INT IDENTITY(1,1) primary key,
		nombre_ES varchar(20) not null unique,
		nombre_EN varchar(20) not null unique, 
		habilitado bit default 1
	);
END
*/

CREATE or ALTER PROCEDURE datos_ventas.insertar_medioDePago
@nombre_ES varchar(20),
@nombre_EN varchar(20)
AS
BEGIN
	DECLARE @error varchar(max) = '';

		--Validar nombres repetidos
	IF(EXISTS (SELECT 1 from gestion_ventas.Medio_de_Pago mp
					where mp.nombre_ES = @nombre_ES))
		SET @error = @error + 'Nombre en español repetido ';

	IF(EXISTS (SELECT 1 from gestion_ventas.Medio_de_Pago mp
					where mp.nombre_EN = @nombre_EN))
		SET @error = @error + 'Nombre en ingles repetido';

	IF(@error = '')
	BEGIN
		insert gestion_ventas.Medio_de_Pago(nombre_ES, nombre_EN)
		values (@nombre_ES,@nombre_EN)
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO

CREATE or ALTER PROCEDURE datos_ventas.modificar_medioDePago
@ID_MP int,
@nombre_ES varchar(20) = null,
@nombre_EN varchar(20) = null
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar ID_MP
	IF(NOT EXISTS (SELECT 1 from gestion_ventas.Medio_de_Pago mp
					where mp.ID_MP = @ID_MP))
		SET @error = @error + 'ERROR: ID_MP NO ENCONTRADO ';


	--Validar nombres repetidos
	IF(EXISTS (SELECT 1 from gestion_ventas.Medio_de_Pago mp
					where mp.nombre_ES = @nombre_ES))
		SET @error = @error + 'Nombre en español repetido ';

	IF(EXISTS (SELECT 1 from gestion_ventas.Medio_de_Pago mp
					where mp.nombre_EN = @nombre_EN))
		SET @error = @error + 'Nombre en ingles repetido';

	IF(@error = '')
	BEGIN
		UPDATE gestion_ventas.Medio_de_Pago
		SET nombre_ES = ISNULL(@nombre_ES, nombre_ES),
			nombre_EN = ISNULL(@nombre_EN, nombre_EN)
		WHERE ID_MP = @ID_MP
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO


CREATE or ALTER PROCEDURE datos_ventas.borrar_medioDePago
@ID_MP int
AS
BEGIN
	DECLARE @error varchar(max) = '';

		--Validar ID_MP
	IF(NOT EXISTS (SELECT 1 from gestion_ventas.Medio_de_Pago mp
					where mp.ID_MP = @ID_MP))
		SET @error = @error + 'ERROR: ID_MP NO ENCONTRADO ';

	IF(@error = '')
	BEGIN
		UPDATE gestion_ventas.Medio_de_Pago
		SET habilitado = 0
		WHERE ID_MP = @ID_MP
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO


CREATE or ALTER PROCEDURE datos_ventas.reactivar_medioDePago
@ID_MP int
AS
BEGIN
	DECLARE @error varchar(max) = '';

		--Validar ID_MP
	IF(NOT EXISTS (SELECT 1 from gestion_ventas.Medio_de_Pago mp
					where mp.ID_MP = @ID_MP))
		SET @error = @error + 'ERROR: ID_MP NO ENCONTRADO ';

	IF(@error = '')
	BEGIN
		UPDATE gestion_ventas.Medio_de_Pago
		SET habilitado = 1
		WHERE ID_MP = @ID_MP
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO