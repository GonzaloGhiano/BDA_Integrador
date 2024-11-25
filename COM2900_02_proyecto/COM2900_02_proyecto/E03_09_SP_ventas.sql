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
-- CREACIÓN DEL SP DE INSERCIÓN DE CUIT SUPERMERCADO
-------------------------------------------------------------------------------------

CREATE or ALTER PROCEDURE gestion_ventas.insertarCUIT_supermercado
@CUIT char(13)
AS
BEGIN
	INSERT INTO gestion_ventas.Configuracion_Supermercado(CUIT_supermercado)
	values (@CUIT);
END
GO



-------------------------------------------------------------------------------------
-- CREACIÓN DE LOS SP DE LINEA DE COMPROBANTE DE VENTA Y DETALLE DE VENTA
-------------------------------------------------------------------------------------

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Predetalle') 
AND type in (N'U'))
BEGIN
		CREATE TABLE gestion_ventas.Predetalle (
			ID_punto_venta INT,
			ID_prod INT,
			subtotal DECIMAL(10,2),
			cantidad INT);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Prefactura') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_ventas.Prefactura (
		ID_punto_venta INT UNIQUE,
		ID_cliente INT,
		ID_empleado INT,
		total DECIMAL(10,2),
		IVA DECIMAL(10,2));
END
GO

/*
	Se utilizaran tablas prefectura y predetalle para cargar los productos a la venta
	en una misma linea de caja, posibilitando una unica venta en proceso por linea de 
	venta.
	Luego, se emitira una factura que puede ser pagada o cancelada.
*/


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
	ELSE IF(EXISTS(SELECT 1 FROM gestion_ventas.Predetalle fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'Un mismo punto de venta no puede hacer dos ventas a la vez';

	--validar empleado
	IF(NOT EXISTS(SELECT 1 FROM gestion_tienda.Empleado emp where emp.ID_empleado = @ID_empleado))
		SET @error = @error + 'No existe el empleado ingresado';

	IF(@error = '')
	BEGIN
		insert gestion_ventas.Prefactura(ID_punto_venta,ID_cliente,ID_empleado, total, IVA)
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
			@subtotalAux DECIMAL(10,2) = 0,
			@precioARS DECIMAL(10,2) = 0;

	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Prefactura fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay venta en curso';
	IF(NOT EXISTS(SELECT 1 FROM gestion_productos.Producto where ID_prod = @ID_prod))
		SET @error = @error + 'ERROR: No existe ese producto';

	IF(@error = '')
	BEGIN
		
		SET @precioARS = gestion_tienda.obtener_precioARS(@ID_prod);

		SET @subtotalAux = @cantidad * @precioARS;

		-- Si ya se ingreso ese producto, se lo suma a la cantidad de ese detalle temporal
		IF(EXISTS(SELECT 1 FROM gestion_ventas.Predetalle 
					where ID_punto_venta = @ID_punto_venta AND ID_prod = @ID_prod))
		BEGIN
			UPDATE gestion_ventas.Predetalle
			SET cantidad = cantidad + @cantidad, --Se suma la cantidad
				subtotal = subtotal + @subtotalAux --Se suma el subtotal
			where ID_punto_venta = @ID_punto_venta AND ID_prod = @ID_prod
		END
		ELSE --Si no existia, lo inserto
		BEGIN
			insert gestion_ventas.Predetalle(ID_punto_venta,ID_prod,subtotal,cantidad)
			values(@ID_punto_venta, @ID_prod, @subtotalAux, @cantidad);
		END

		UPDATE gestion_ventas.Prefactura
		SET total = total + @subtotalAux
		WHERE ID_punto_venta = @ID_punto_venta;

		UPDATE gestion_ventas.Prefactura
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
@nro_factura CHAR(11),
@tipo_factura char(1),
@id_medio_pago INT,
@identificador_pago varchar(22)
AS
BEGIN
	DECLARE @error varchar(max) = '',
	@ID_venta INT = 0,
	@CUIT_SUPERMERCADO char(13) = '',
	@ID_factura_aux int = 0,
	@ID_cliente_aux int = 0,
	@CUIL_cliente char(13) = '';

	--Verificar que exista una venta en curso
	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Prefactura fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay venta en curso ';

	-- Verificar que la venta no esté vacia
	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Predetalle det where det.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: La venta no tiene productos ';

	--Verificar que exista el medio de pago
	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Medio_de_Pago mp where mp.ID_MP = @id_medio_pago))
		SET @error = @error + 'ERROR: El medio de pago no es valido ';

	--Verificar que el numero de factura sea unico
	IF(EXISTS(SELECT 1 FROM gestion_ventas.Factura fact where fact.nro_factura = @nro_factura))
		SET @error = @error + 'ERROR: Numero de factura repetido ';

	IF(@error = '')
	BEGIN
		SET @CUIT_SUPERMERCADO = (SELECT TOP 1 cs.CUIT_supermercado 
								FROM gestion_ventas.Configuracion_Supermercado cs 
								order by cs.fecha_hora_actualizacion desc)

		SET @ID_cliente_aux = (Select TOP 1 pre.ID_cliente from gestion_ventas.Prefactura pre
							where pre.ID_punto_venta = @ID_punto_venta)

		SET @CUIL_cliente = gestion_tienda.obtenerCUIL(@ID_cliente_aux)

		INSERT INTO gestion_ventas.Factura(nro_factura, tipo_factura, estado_factura, total_neto_sinIVA, IVA,
					CUIT_supermercado, CUIL_cliente, fecha_hora_emision)
		SELECT @nro_factura, @tipo_factura, 'PA', f_tmp.total, f_tmp.IVA,
				@CUIT_SUPERMERCADO, @CUIL_cliente, getdate()
		FROM gestion_ventas.Prefactura f_tmp
		WHERE f_tmp.ID_punto_venta = @ID_punto_venta;
			
		SET @ID_factura_aux = (SELECT ID_factura from gestion_ventas.Factura fact
								where fact.nro_factura = @nro_factura);

		INSERT INTO gestion_ventas.Venta(ID_punto_venta,ID_cliente,fecha,hora,id_medio_pago,ID_empleado,
					identificador_pago, ID_factura)
		SELECT @ID_punto_venta, f_tmp.ID_cliente, 
				cast(getdate() as date), 
				cast(getdate() as time),
				@id_medio_pago, f_tmp.ID_empleado, @identificador_pago, @ID_factura_aux
		FROM gestion_ventas.Prefactura f_tmp
		WHERE f_tmp.ID_punto_venta = @ID_punto_venta;
		
		--Borramos la factura de temporales
		DELETE FROM gestion_ventas.Prefactura
		WHERE ID_punto_venta = @ID_punto_venta;
		
		--Creamos los detalles de venta
		SET @ID_venta = (SELECT v.ID_venta from gestion_ventas.Venta v where v.ID_factura = @ID_factura_aux);

		INSERT INTO gestion_ventas.Detalle_venta(ID_venta, ID_prod, subtotal, cantidad)
		SELECT @ID_venta, d_tmp.ID_prod, d_tmp.subtotal, d_tmp.cantidad
		FROM gestion_ventas.Predetalle d_tmp
		WHERE d_tmp.ID_punto_venta = @ID_punto_venta;


		--Borramos los detalles temporales
		DELETE FROM gestion_ventas.Predetalle
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

	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Prefactura fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay venta en curso';

	IF(@error = '')
	BEGIN
		--Borramos la factura de temporales
		DELETE FROM gestion_ventas.Prefactura
		WHERE ID_punto_venta = @ID_punto_venta;
	
		--Borramos los detalles temporales
		DELETE FROM gestion_ventas.Predetalle
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
	DELETE FROM gestion_ventas.Prefactura;
	
		--Borramos los detalles temporales
	DELETE FROM gestion_ventas.Predetalle;
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

	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Prefactura fact where fact.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay venta en curso';

	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Predetalle d_tmp where  d_tmp.ID_punto_venta = @ID_punto_venta AND d_tmp.ID_prod = @ID_prod))
		SET @error = @error + 'ERROR: Producto no encontrado en esta venta';

	IF(@error = '')
	BEGIN

		SET @subtotalAux = (select subtotal FROM gestion_ventas.Predetalle
		WHERE ID_punto_venta = @ID_punto_venta AND ID_prod = @ID_prod);

		--Borramos los detalles temporales
		DELETE FROM gestion_ventas.Predetalle
		WHERE ID_punto_venta = @ID_punto_venta AND ID_prod = @ID_prod;


		UPDATE gestion_ventas.Prefactura
		SET total = total - @subtotalAux
		WHERE ID_punto_venta = @ID_punto_venta;

		UPDATE gestion_ventas.Prefactura
		SET IVA = Total*0.21
		WHERE ID_punto_venta = @ID_punto_venta;

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO

