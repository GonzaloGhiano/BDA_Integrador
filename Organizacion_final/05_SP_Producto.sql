/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	DNIXXXXX Felipe Morales 
	DNI XXXX Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a la creación de los Store Procedure de las tablas pertenecientes al esquema Producto.
*/

USE Com2900G02
GO


-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE LINEA DE PRODUCTO
-------------------------------------------------------------------------------------



create or alter procedure datos_productos.insertar_lineaProducto
@linea_prod varchar(35)
as
begin
	insert gestion_productos.Linea_Producto(linea_prod)
	values (@linea_prod)

end
GO

create or alter procedure datos_productos.modificar_lineaProducto
@ID_lineaprod int,
@linea_prod varchar(35) = NULL
as
begin
	--validar ID_lineaprod
	DECLARE @error varchar(max) = '';

	IF(NOT EXISTS (SELECT 1 from gestion_productos.Linea_Producto lp
					where lp.ID_lineaprod = @ID_lineaprod))
		SET @error = @error + 'ID de Linea de Producto inexistente';

	IF(@error = '')
	BEGIN

		update gestion_productos.Linea_Producto
		set	linea_prod = isnull(@linea_prod, linea_prod)
		where ID_lineaprod = @ID_lineaprod

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO

create or alter procedure datos_productos.borrar_lineaProducto
@ID_lineaprod int
AS
BEGIN
	--validar ID_lineaprod
	DECLARE @error varchar(max) = '';

	IF(NOT EXISTS (SELECT 1 from gestion_productos.Linea_Producto lp
					where lp.ID_lineaprod = @ID_lineaprod))
		SET @error = @error + 'ID de Linea de Producto inexistente';

	IF(@error = '')
	BEGIN
		UPDATE gestion_productos.Linea_Producto
		SET habilitado = 0
		where ID_lineaprod = @ID_lineaprod
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO

create or alter procedure datos_productos.reactivar_lineaProducto
@ID_lineaprod int
AS
BEGIN
	--validar ID_lineaprod
	DECLARE @error varchar(max) = '';

	IF(NOT EXISTS (SELECT 1 from gestion_productos.Linea_Producto lp
					where lp.ID_lineaprod = @ID_lineaprod))
		SET @error = @error + 'ID de Linea de Producto inexistente';

	IF(@error = '')
	BEGIN
		UPDATE gestion_productos.Linea_Producto
		SET habilitado = 1
		where ID_lineaprod = @ID_lineaprod
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO



-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE PRODUCTO
-------------------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE datos_productos.insertar_producto
@nombre_Prod varchar(70) = null,
@categoria varchar(20) = null,
@precio decimal(10,2) = null,
@referencia_precio decimal(10,2) = null,
@referencia_unidad varchar(6) = null,
@cod_linea_prod int = null
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar nombre producto
	IF(ISNULL(@nombre_Prod, '') = '')
	SET @error = @error + 'ERROR: El nombre del producto no puede ser vacio'

	--Validar categoría producto
	IF(ISNULL(@categoria, '') = '')
	SET @error = @error + 'ERROR: La categoria del producto no puede ser vacio'
	
	--Validar precio producto
	IF(ISNULL(@precio, -1) <=0)
		SET @error = @error + 'ERROR: El precio del producto es invalido'
	
	--Validar linea de producto
	IF(@cod_linea_prod IS NOT NULL AND
		NOT EXISTS(SELECT 1 FROM gestion_productos.Linea_Producto lp
					WHERE lp.ID_lineaprod = @cod_linea_prod))
		SET @error = @error + 'ID de Linea de Producto inexistente';


	IF(@error = '')
	BEGIN
		INSERT gestion_productos.Producto(nombre_Prod, categoria, precio, referencia_precio, referencia_unidad,
		cod_linea_prod)
		VALUES(@nombre_Prod, @categoria, @precio, @referencia_precio, @referencia_unidad, @cod_linea_prod)
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO




CREATE OR ALTER PROCEDURE datos_productos.modificar_producto
@ID_prod int = null,
@nombre_Prod varchar(70) = null,
@categoria varchar(20) = null,
@precio decimal(10,2) = null,
@referencia_precio decimal(10,2) = null,
@referencia_unidad varchar(6) = null,
@cod_linea_prod int = null
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--Validar ID_prod
	IF(NOT EXISTS (SELECT 1 from gestion_productos.Producto p
					where p.ID_prod = (ISNULL(@ID_prod, -1))))
		SET @error = @error + 'ID Producto inexistente';

	--Validar cod_linea_prod
	IF(@cod_linea_prod IS NOT NULL AND
		NOT EXISTS(SELECT 1 FROM gestion_productos.Linea_Producto lp
					WHERE lp.ID_lineaprod = @cod_linea_prod))
		SET @error = @error + 'ID de Linea de Producto inexistente';

	--Validar precio producto
	IF(@precio IS NOT NULL AND @precio <=0)
		SET @error = @error + 'ERROR: El precio del producto es invalido'
	

	IF(@error = '')
	BEGIN
		update gestion_productos.Producto
		set	nombre_Prod = isnull(@nombre_Prod, nombre_Prod),
			categoria = isnull(@categoria, categoria),
			precio = isnull(@precio, precio),
			referencia_precio = isnull(@referencia_precio, referencia_precio),
			referencia_unidad = isnull(@referencia_unidad, referencia_unidad),
			cod_linea_prod = isnull(@cod_linea_prod,cod_linea_prod)
		where ID_prod = @ID_prod
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO



CREATE OR ALTER PROCEDURE datos_productos.borrar_producto
@ID_prod int = null
AS
BEGIN
	IF(@ID_prod IS NULL OR NOT EXISTS(SELECT 1 FROM gestion_productos.Producto p
									WHERE p.ID_prod = @ID_prod))
		RAISERROR('ERROR: El ID de producto es invalido', 16, 1);
	ELSE
	BEGIN
		update gestion_productos.Producto
		SET habilitado = 0
		WHERE ID_prod = @ID_prod
	END
END
GO



CREATE OR ALTER PROCEDURE datos_productos.reactivar_producto
@ID_prod int = null
AS
BEGIN
	IF(@ID_prod IS NULL OR NOT EXISTS(SELECT 1 FROM gestion_productos.Producto p
									WHERE p.ID_prod = @ID_prod))
		RAISERROR('ERROR: El ID de producto es invalido', 16, 1);
	ELSE
	BEGIN
		update gestion_productos.Producto
		SET habilitado = 1
		WHERE ID_prod = @ID_prod
	END
END
GO