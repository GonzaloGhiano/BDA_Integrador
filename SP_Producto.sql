USE Com2900G02;
GO

/*
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_productos.Producto') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_productos.Producto(
		ID_prod INT IDENTITY(1,1),
		nombre_Prod varchar(70) not null,
		categoria varchar(20) not null,
		precio decimal(10,2) check(precio>0) not null,
		referencia_precio decimal(10,2) check(referencia_precio>0) null,
		reference_unit varchar(6) null, --variabilidad de 1 a 6, mayoria 2, que conviene?
		cod_linea_prod int,
		habilitado bit default 1,

		CONSTRAINT pk_producto primary key(ID_prod),
		CONSTRAINT fk_linea_prod foreign key(cod_linea_prod) references gestion_productos.Linea_Producto(ID_lineaprod)
	);
END
GO
*/

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