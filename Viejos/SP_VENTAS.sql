USE Com2900G02;
GO

/*
CREATE TABLE gestion_ventas.Comprobante_venta(
		ID_venta INT IDENTITY(1,1) primary key,
		ID_factura CHAR(11) not null UNIQUE,
		tipo_factura char(1) not null,
		ID_punto_venta int not null,
		ID_cliente int null,
		fecha DATE not null,
		hora TIME not null,
		id_medio_pago int not null,
		ID_empleado int not null,
		identificador_pago varchar(22),
		factura_pagada bit default 0,
		total_sinIVA decimal(10,2) CHECK(total_sinIVA>0) not null,
		IVA decimal(10,2) CHECK(iva>0) not null,


		CONSTRAINT fk_empleado foreign key(ID_empleado) references gestion_tienda.Empleado(ID_empleado),
		CONSTRAINT fk_cliente foreign key(ID_cliente) references gestion_clientes.cliente(ID_cliente),
		CONSTRAINT fk_medio_pago foreign key(id_medio_pago) references gestion_ventas.Medio_de_Pago(ID_MP),
		CONSTRAINT CHECK_tipo_factura CHECK(
			tipo_factura in('A','B','C')),
		CONSTRAINT fk_punt_venta foreign key(ID_punto_venta) references 
		gestion_tienda.punto_de_venta(ID_punto_venta)



			CREATE TABLE gestion_ventas.Detalle_venta(
		ID_detalle_venta INT IDENTITY(1,1) primary key,
		ID_venta int not null,
		ID_prod int not null,
		subtotal decimal(10,2) check(subtotal>0) not null,
		cantidad int not null check(cantidad>0),
		CONSTRAINT fk_factura foreign key(ID_venta) references gestion_ventas.Comprobante_venta(ID_venta),
		CONSTRAINT fk_producto foreign key(ID_prod) references gestion_productos.Producto(ID_prod),
	);
*/

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

		insert Detalle_tmp(ID_punto_venta,ID_prod,subtotal,cantidad)
		values(@ID_punto_venta, @ID_prod, @subtotalAux, @cantidad);

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


EXEC datos_tienda.insertar_sucursal
@nombre = 'Ramos',
@ciudad = 'La Matanza',
@direccion = 'Amancio Alcorta 33',
@horario = '9AM - 11AM',
@telefono = 1111;

SELECT TOP 1 * from gestion_tienda.Sucursal;
GO

EXEC datos_tienda.insertar_puntoDeVenta
@nro_caja = 1,
@ID_sucursal = 1;
SELECT TOP 1 * from gestion_tienda.punto_de_venta;
GO

EXEC datos_productos.insertar_lineaProducto
@linea_prod = 'Prueba LP';
GO
SELECT TOP 3 * from gestion_productos.Linea_Producto;
GO


EXEC datos_productos.insertar_producto
@nombre_Prod = 'Lapiz triple',
@categoria = 'Libreria prueba',
@precio = 100.99,
@cod_linea_prod = 1
GO
SELECT TOP 5 * from gestion_productos.Producto;
GO

EXEC datos_productos.insertar_producto
@nombre_Prod = 'Boligoma especial',
@categoria = 'Libreria prueba',
@precio = 200.50,
@cod_linea_prod = 1
GO
SELECT TOP 5 * from gestion_productos.Producto;
GO

EXEC datos_tienda.insertar_empleado
@legajo = '000001',
@nombre = 'Felipe',
@apellido = 'Probando',
@num_documento = '43440000',
@tipo_documento = 'DU',
@direccion = 'Su casa 123',
@email_personal = 'felipe.com',
@email_empresarial = 'felipe.org',
@CUIL = '23-43440000-7',
@sucursal_id = 1,
@turno = 'TM';
GO
SELECT TOP 5 * from gestion_tienda.Empleado;
GO

EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'Billuta',
@nombre_EN = 'Cash';
GO
SELECT TOP 3 * from gestion_ventas.Medio_de_Pago;
GO

EXEC datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta = 1,
@ID_cliente = null,
@ID_empleado = 1;
GO

select top 3 * from Factura_tmp;

EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 1,
@cantidad = 2;
GO

EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 2,
@cantidad = 3;
GO

select top 3 * from Detalle_tmp;
GO

EXEC datos_ventas.cerrarVenta
@ID_punto_venta = 1,
@ID_factura = 'ZZB-ACC-AAA',
@tipo_factura = 'A',
@id_medio_pago = 1,
@identificador_pago = '11111';
GO

SELECT TOP 5 * FROM gestion_ventas.Comprobante_venta;
SELECT TOP 20 * FROM gestion_ventas.Detalle_venta;
