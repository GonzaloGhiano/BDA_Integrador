USE Com2900G02
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