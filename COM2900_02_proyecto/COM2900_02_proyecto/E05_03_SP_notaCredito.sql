/*
	Entrega 5. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente creacion de los Store Procedures para la inserción de notas de credito
	en el sistema.
*/


USE Com2900G02;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Nota_credito') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_ventas.Nota_credito(
		ID_nota_credito INT IDENTITY(1,1) primary key,
		ID_factura INT,
		total_neto_sinIVA decimal(10,2) CHECK(total_neto_sinIVA>0) not null,
		IVA decimal(10,2) CHECK(IVA>0) not null,
		fecha_hora_emision datetime DEFAULT getdate(),
		ID_empleado int not null,
		ID_punto_venta int not null,

		CONSTRAINT fk_nc_factura FOREIGN KEY (ID_factura) references gestion_ventas.Factura(ID_factura),
		CONSTRAINT fk_nc_empleado foreign key(ID_empleado) references gestion_tienda.Empleado(ID_empleado),
		CONSTRAINT fk_nc_punt_venta foreign key(ID_punto_venta) references gestion_tienda.punto_de_venta(ID_punto_venta)
	);
END
GO

--drop table gestion_ventas.Detalle_nota_credito
--drop table gestion_ventas.Nota_credito
--drop table gestion_ventas.Pre_notaCredito
--drop table gestion_ventas.Pre_detalle_notaCredito

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Detalle_nota_credito') 
AND type in (N'U'))
BEGIN
	CREATE TABLE gestion_ventas.Detalle_nota_credito(
		ID_detalle_notaCredito INT IDENTITY(1,1) primary key,
		ID_nota_credito INT,
		ID_prod int not null,
		ID_detalle_venta int not null,
		subtotal decimal(10,2) check(subtotal>0) not null,
		cantidad int not null check(cantidad>0),

		CONSTRAINT fk_dcn_nota_credito FOREIGN KEY (ID_nota_credito) references gestion_ventas.Nota_credito(ID_nota_credito),
		CONSTRAINT fk_dnc_producto foreign key(ID_prod) references gestion_productos.Producto(ID_prod),
		CONSTRAINT fk_dnc_detalleVenta foreign key (ID_detalle_venta) references gestion_ventas.Detalle_venta(ID_detalle_venta)
	);
END
GO


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Pre_notaCredito') 
AND type in (N'U'))
BEGIN
		CREATE TABLE gestion_ventas.Pre_notaCredito (
			ID_punto_venta INT primary key,
			ID_factura INT,
			ID_empleado INT,
			total DECIMAL(10,2)
			);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'gestion_ventas.Pre_detalle_notaCredito') 
AND type in (N'U'))
BEGIN
		CREATE TABLE gestion_ventas.Pre_detalle_notaCredito (
			ID_punto_venta INT,
			ID_detalle_venta INT unique,
			ID_prod INT,
			cantidad INT,
			subtotal DECIMAL(10,2)
			);
END
GO


CREATE OR ALTER PROCEDURE datos_notas_credito.iniciar_nota_credito
@ID_factura int,
@ID_empleado int,
@ID_punto_venta int
AS
BEGIN
	DECLARE @error varchar(max) = '';

	--validar Factura
	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Factura fact where fact.ID_factura = @ID_factura
				AND fact.estado_factura = 'PA'))
		SET @error = @error + 'No existe la factura ingresada o su estado no es pagada';

	--validar empleado
	IF(NOT EXISTS(SELECT 1 FROM gestion_tienda.Empleado emp where emp.ID_empleado = @ID_empleado))
		SET @error = @error + 'No existe el empleado ingresado';

	--validar punto de venta
	IF(NOT EXISTS(SELECT 1 FROM gestion_tienda.punto_de_venta pv where pv.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'No existe el punto de venta';

	IF(@error = '')
	BEGIN
		INSERT INTO gestion_ventas.Pre_notaCredito(ID_punto_venta, ID_factura, ID_empleado, total)
		VALUES (@ID_punto_venta, @ID_factura, @ID_empleado, 0)
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO

CREATE OR ALTER PROCEDURE datos_notas_credito.nota_credito_agregarProducto
@ID_punto_venta int,
@ID_detalle_venta INT,
@cantidad int
AS
BEGIN
	DECLARE @error varchar(max) = '',
			@subtotalAux DECIMAL(10,2) = 0,
			@precioUnitario DECIMAL(10,2),
			@ID_prod_aux INT = 0;

	--Validar nota de credito en curso
	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Pre_notaCredito pre_nc where pre_nc.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay Nota de Credito en curso';

	--Validar detalle de venta existente
	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Detalle_venta dv where dv.ID_detalle_venta = @ID_detalle_venta))
		SET @error = @error + 'ERROR: No existe ese detalle de venta';

	--Validar cantidad maxima
	IF(EXISTS(SELECT 1 FROM gestion_ventas.Detalle_venta dv where dv.ID_detalle_venta = @ID_detalle_venta
				AND dv.cantidad < @cantidad))
		SET @error = @error + 'ERROR: La cantidad sobrepasa a la vendida';

	IF(@error = '')
	BEGIN
		--Obtenemos los subtotales necesarios para la inserción a las tablas temporales
		SET @subtotalAux = (SELECT TOP 1 dv.subtotal from gestion_ventas.Detalle_venta dv where dv.ID_detalle_venta = @ID_detalle_venta)
		SET @precioUnitario = @subtotalAux / (SELECT TOP 1 dv.cantidad from gestion_ventas.Detalle_venta dv where dv.ID_detalle_venta = @ID_detalle_venta)
		SET @ID_prod_aux = (SELECT TOP 1 dv.ID_prod from gestion_ventas.Detalle_venta dv where dv.ID_detalle_venta = @ID_detalle_venta)

		--Insertamos un pre detalle
		insert gestion_ventas.Pre_detalle_notaCredito(ID_punto_venta, ID_detalle_venta, ID_prod, cantidad, subtotal)
		values(@ID_punto_venta, @ID_detalle_venta, @ID_prod_aux , @cantidad, @precioUnitario * @cantidad);

		--Actualizamos la preNota de credito
		UPDATE gestion_ventas.Pre_notaCredito
		SET total = total + @precioUnitario*@cantidad
		WHERE ID_punto_venta = @ID_punto_venta;
	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO



----------------------------------------------------------------------
--SP de confirmacion de una nota de credito
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE datos_notas_credito.confirmar_notaCredito
@ID_punto_venta int
AS
BEGIN
	DECLARE @error varchar(max) = '',
	@ID_notaCredito_aux int = 0;

	--Validar nota de credito en curso
	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Pre_notaCredito pre_nc where pre_nc.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay Nota de Credito en curso';
	--Validamos que no se realice una nota de credito vacia
	ELSE IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Pre_detalle_notaCredito pre_detalle where pre_detalle.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: La nota no tiene detalles';

	IF(@error = '')
	BEGIN
	--Insertamos la nota de credito
		INSERT INTO gestion_ventas.Nota_credito(ID_factura, total_neto_sinIVA, IVA, fecha_hora_emision, ID_empleado, ID_punto_venta)
		SELECT pre_nc.ID_factura, pre_nc.total, pre_nc.total * 0.21, getdate(), pre_nc.ID_empleado, pre_nc.ID_punto_venta
		FROM gestion_ventas.Pre_notaCredito pre_nc
		WHERE pre_nc.ID_punto_venta = @ID_punto_venta;

		--Selecciono el ID de la nota de credito generada, haciendo un join con la preNotaCredito que aun mantenemos, pidiendole que su
		--ID_punto_venta sea el que estamos trabajando (solo puede haber 1 nc en curso por punto de venta)
		SET @ID_notaCredito_aux = (SELECT TOP 1 nc.ID_nota_credito FROM gestion_ventas.Nota_credito nc
						INNER JOIN gestion_ventas.Pre_notaCredito pre_nc on pre_nc.ID_factura = nc.ID_factura
						WHERE pre_nc.ID_punto_venta = @ID_punto_venta)
	
	--Insertamos los detalles de nota de credito
		INSERT INTO gestion_ventas.Detalle_nota_credito(ID_nota_credito, ID_prod, ID_detalle_venta, subtotal, cantidad)
		SELECT @ID_notaCredito_aux, pre_detalle.ID_prod, pre_detalle.ID_detalle_venta, pre_detalle.subtotal, pre_detalle.cantidad
		FROM gestion_ventas.Pre_detalle_notaCredito pre_detalle
		WHERE pre_detalle.ID_punto_venta = @ID_punto_venta

	--Eliminamos las pre notas y los predetalles
		DELETE from gestion_ventas.Pre_notaCredito
		WHERE ID_punto_venta = @ID_punto_venta;

		DELETE FROM gestion_ventas.Pre_detalle_notaCredito
		WHERE ID_punto_venta = @ID_punto_venta

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO


----------------------------------------------------------------------
--SP de cancelación de una nota de credito en curso
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE datos_notas_credito.cancelar_notaCredito_enCurso
@ID_punto_venta INT
AS
BEGIN
	DECLARE @error varchar(max) = '',
	@ID_venta INT = 0;

	--Validamos que exista una nota en curso en este punto de venta
	IF(NOT EXISTS(SELECT 1 FROM gestion_ventas.Pre_notaCredito pre_nc 
					where pre_nc.ID_punto_venta = @ID_punto_venta))
		SET @error = @error + 'ERROR: No hay nota de credito en curso en ese punto de venta';

	IF(@error = '')
	BEGIN
		--Borramos la factura de temporales
		DELETE FROM gestion_ventas.Pre_notaCredito
		WHERE ID_punto_venta = @ID_punto_venta;
	
		--Borramos los detalles temporales
		DELETE FROM gestion_ventas.Pre_detalle_notaCredito
		WHERE ID_punto_venta = @ID_punto_venta;

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO


----------------------------------------------------------------------
--SP de cancelación de todas las notas de credito en curso
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE datos_notas_credito.cancelar_todasLasNotasCredito_enCurso
AS
BEGIN
		--Borramos las pre-nota de credito
	DELETE FROM gestion_ventas.Pre_notaCredito;
	
		--Borramos los detalles temporales
	DELETE FROM gestion_ventas.Pre_detalle_notaCredito;
END
GO