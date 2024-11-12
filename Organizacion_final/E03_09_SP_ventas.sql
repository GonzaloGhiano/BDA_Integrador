/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a la creación de los Store Procedure de las tablas pertenecientes al esquema Venta.
*/

USE Com2900G02;
GO

-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE MEDIO DE PAGO
-------------------------------------------------------------------------------------


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



-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE LINEA DE COMPROBANTE DE VENTA Y DETALLE DE VENTA
-------------------------------------------------------------------------------------


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Detalle_tmp') 
AND type in (N'U'))
BEGIN
		CREATE TABLE Detalle_tmp (
			ID_punto_venta INT,
			ID_prod INT,
			subtotal DECIMAL(10,2),
			cantidad INT);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Factura_tmp') 
AND type in (N'U'))
BEGIN
	CREATE TABLE Factura_tmp (
		ID_punto_venta INT UNIQUE,
		ID_cliente INT,
		ID_empleado INT,
		total DECIMAL(10,2),
		IVA DECIMAL(10,2));
END
GO

CREATE OR ALTER PROCEDURE datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta int,
@ID_cliente int,
@ID_empleado int
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--validar punto de venta
	IF(NOT EXISTS(SELECT 1 FROM gestion_tienda.punto_de_venta pv where pv.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'No existe el punto de venta';
	ELSE IF(EXISTS(SELECT 1 FROM Factura_tmp fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'Un mismo punto de venta no puede hacer dos ventas a la vez';

	--validar empleado
	IF(NOT EXISTS(SELECT 1 FROM gestion_tienda.Empleado emp where emp.ID_empleado = @ID_empleado))
		SET @error = @error + 'No existe el empleado ingresado';

	IF(@error = '')
	BEGIN
		insert Factura_tmp(ID_punto_venta,ID_cliente,ID_empleado, total, IVA)
		values(@ID_punto_venta, @ID_cliente, @ID_empleado, 0, 0);
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO


CREATE OR ALTER PROCEDURE datos_ventas.agregarProducto
@ID_punto_venta int,
@ID_prod int,
@cantidad int
AS
BEGIN
	DECLARE @error varchar(max) = '',
			@subtotalAux DECIMAL(10,2) = 0;

	IF(NOT EXISTS(SELECT 1 FROM Factura_tmp fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay venta en curso';

	IF(@error = '')
	BEGIN
		SET @subtotalAux = @cantidad * (select precio from gestion_productos.Producto p where p.ID_prod = @ID_prod);

		-- Si ya se ingreso ese producto, se lo suma a la cantidad de ese detalle temporal
		IF(EXISTS(SELECT 1 FROM Detalle_tmp 
					where ID_punto_venta = @ID_punto_venta AND ID_prod = @ID_prod))
		BEGIN
			UPDATE Detalle_tmp
			SET cantidad = cantidad + @cantidad, --Se suma la cantidad
				subtotal = subtotal + @subtotalAux --Se suma el subtotal
			where ID_punto_venta = @ID_punto_venta AND ID_prod = @ID_prod
		END
		ELSE --Si no existia, lo inserto
		BEGIN
			insert Detalle_tmp(ID_punto_venta,ID_prod,subtotal,cantidad)
			values(@ID_punto_venta, @ID_prod, @subtotalAux, @cantidad);
		END

		UPDATE Factura_tmp
		SET total = total + @subtotalAux
		WHERE ID_punto_venta = @ID_punto_venta;

		UPDATE Factura_tmp
		SET IVA = Total*0.21
		WHERE ID_punto_venta = @ID_punto_venta;

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO

CREATE OR ALTER PROCEDURE datos_ventas.cerrarVenta
@ID_punto_venta INT,
@ID_factura CHAR(11),
@tipo_factura char(1),
@id_medio_pago INT,
@identificador_pago varchar(22)
AS
BEGIN
	DECLARE @error varchar(max) = '',
	@ID_venta INT = 0;

	--Verificar que exista una venta en curso
	IF(NOT EXISTS(SELECT 1 FROM Factura_tmp fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay venta en curso';

	IF(@error = '')
	BEGIN
		INSERT INTO gestion_ventas.Comprobante_venta(ID_factura, tipo_factura, ID_punto_venta, ID_cliente, fecha,
					hora, id_medio_pago, ID_empleado, identificador_pago, total_sinIVA, IVA)
		SELECT @ID_factura, @tipo_factura, @ID_punto_venta, f_tmp.ID_cliente, 
				cast(getdate() as date), 
				cast(getdate() as time),
				@id_medio_pago, f_tmp.ID_empleado, @identificador_pago, f_tmp.total, f_tmp.IVA
		FROM Factura_tmp f_tmp
		WHERE f_tmp.ID_punto_venta = @ID_punto_venta;
		
		--Borramos la factura de temporales
		DELETE FROM Factura_tmp
		WHERE ID_punto_venta = @ID_punto_venta;
		
		--Creamos los detalles de venta
		SET @ID_venta = (SELECT cv.ID_venta from gestion_ventas.Comprobante_venta cv where cv.ID_factura = @ID_factura);

		INSERT INTO gestion_ventas.Detalle_venta(ID_venta, ID_prod, subtotal, cantidad)
		SELECT @ID_venta, d_tmp.ID_prod, d_tmp.subtotal, d_tmp.cantidad
		FROM Detalle_tmp d_tmp
		WHERE d_tmp.ID_punto_venta = @ID_punto_venta;


		--Borramos los detalles temporales
		DELETE FROM Detalle_tmp
		WHERE ID_punto_venta = @ID_punto_venta;

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO



CREATE OR ALTER PROCEDURE datos_ventas.cancelar_venta
@ID_punto_venta INT
AS
BEGIN
	DECLARE @error varchar(max) = '',
	@ID_venta INT = 0;

	IF(NOT EXISTS(SELECT 1 FROM Factura_tmp fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay venta en curso';

	IF(@error = '')
	BEGIN
		--Borramos la factura de temporales
		DELETE FROM Factura_tmp
		WHERE ID_punto_venta = @ID_punto_venta;
	
		--Borramos los detalles temporales
		DELETE FROM Detalle_tmp
		WHERE ID_punto_venta = @ID_punto_venta;

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO

CREATE OR ALTER PROCEDURE datos_ventas.cancelar_todasLasVentas
AS
BEGIN
		--Borramos la factura de temporales
	DELETE FROM Factura_tmp;
	
		--Borramos los detalles temporales
	DELETE FROM Detalle_tmp;
END
GO


CREATE OR ALTER PROCEDURE datos_ventas.sacarProductodeVenta
@ID_punto_venta INT,
@ID_prod INT
AS
BEGIN
	DECLARE @error varchar(max) = '',
	@ID_venta INT = 0,
	@subtotalAux INT = 0;

	IF(NOT EXISTS(SELECT 1 FROM Factura_tmp fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay venta en curso';

	IF(NOT EXISTS(SELECT 1 FROM Detalle_tmp d_tmp where  d_tmp.ID_punto_venta = @ID_punto_venta AND d_tmp.ID_prod = @ID_prod))
		SET @error = @error + 'ERROR: Producto no encontrado en esta venta';

	IF(@error = '')
	BEGIN

		SET @subtotalAux = (select subtotal FROM Detalle_tmp
		WHERE ID_punto_venta = @ID_punto_venta AND ID_prod = @ID_prod);

		--Borramos los detalles temporales
		DELETE FROM Detalle_tmp
		WHERE ID_punto_venta = @ID_punto_venta AND ID_prod = @ID_prod;


		UPDATE Factura_tmp
		SET total = total - @subtotalAux
		WHERE ID_punto_venta = @ID_punto_venta;

		UPDATE Factura_tmp
		SET IVA = Total*0.21
		WHERE ID_punto_venta = @ID_punto_venta;

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO



/*
CREATE OR ALTER PROCEDURE datos_ventas.insertar_detalleVenta
@ID_venta int,
@ID_prod int,
@subtotal decimal(10,2),
@cantidad int
AS
BEGIN
    
    DECLARE @error varchar(max) = '';

    --Validar ID venta
    IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Comprobante_venta
                    WHERE ID_venta = @ID_venta))
        SET @error = @error + 'ID de venta inexistente';

    --Validar ID producto
    IF(NOT EXISTS(SELECT 1 FROM gestion_productos.Producto
                    WHERE ID_prod = @ID_prod))
        SET @error = @error + 'ID de producto inexistente';

    IF(@error = '')
    BEGIN
        
        INSERT gestion_ventas.Detalle_venta (ID_venta,ID_prod,subtotal,cantidad)
        values (@ID_venta,@ID_prod,@subtotal,@cantidad)

    END
    ELSE
    BEGIN
        RAISERROR (@error, 16, 1);
    END

END
GO
*/