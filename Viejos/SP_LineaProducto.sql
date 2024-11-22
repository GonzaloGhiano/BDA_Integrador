USE Com2900G02
GO

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
