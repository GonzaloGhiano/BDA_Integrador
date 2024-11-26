/*
	Entrega 5. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a las pruebas unitarias de la nota de credito
*/


----------------------------------------------------------------------
--Prueba unitaria Nota Credito exitosa
----------------------------------------------------------------------
USE Com2900G02;
GO

--Agregamos configuración de CUIT del supermercado

EXEC gestion_ventas.insertarCUIT_supermercado
@CUIT = '11-23456789-1'
GO
SELECT TOP 10 * FROM gestion_ventas.Configuracion_Supermercado
GO


--Cancelamos todas las ventas en curso
EXEC datos_ventas.cancelar_todasLasVentas
GO

select top 3 * from gestion_ventas.Predetalle;
GO
select top 3 * from gestion_ventas.Prefactura;
GO
select top 3 * from gestion_ventas.Factura
GO
select top 3 * from gestion_ventas.Venta
GO
select top 3 * from gestion_ventas.Detalle_venta
GO


--Insertamos una cotizacion del dolar
EXEC datos_tienda.insertar_Cotizacion_USD
@valor = 1000
GO
SELECT TOP 3 * FROM gestion_tienda.Cotizacion_USD order by fecha desc;


--Primero necesitamos una sucursal
EXEC datos_tienda.insertar_sucursal
@nombre = 'Ramos',
@ciudad = 'La Matanza',
@direccion = 'Amancio Alcorta 33',
@horario = '9AM - 11AM',
@telefono = 1111;

SELECT TOP 10 * from gestion_tienda.Sucursal;
GO

--Necesitamos una caja en esa sucursal, representada como un punto de venta
EXEC datos_tienda.insertar_puntoDeVenta
@nro_caja = 1,
@ID_sucursal = 1
SELECT TOP 10 * from gestion_tienda.punto_de_venta;
GO

EXEC datos_productos.insertar_lineaProducto
@linea_prod = 'Prueba LP';
GO
SELECT TOP 3 * from gestion_productos.Linea_Producto;
GO


--Insertamos dos productos:
EXEC datos_productos.insertar_producto
@nombre_Prod = 'Lapiz triple',
@categoria = 'Libreria prueba',
@precio = 100.99,
@cod_linea_prod = 1
GO
SELECT TOP 5 * from gestion_productos.Producto where nombre_Prod like 'Lapiz triple';
GO

EXEC datos_productos.insertar_producto
@nombre_Prod = 'Boligoma especial',
@categoria = 'Libreria prueba',
@precio = 200.50,
@cod_linea_prod = 1
GO
SELECT TOP 5 * from gestion_productos.Producto where nombre_Prod like 'Boligoma especial';
GO


--Insertamos un empleado:
EXEC datos_tienda.insertar_empleado_encriptado
@legajo = 000001,
@nombre = 'Felipe',
@apellido = 'Probando',
@num_documento = 43440000,
@tipo_documento = 'DU',
@direccion = 'Su casa 123',
@email_personal = 'felipe.com',
@email_empresarial = 'felipe@empresa.com',
@CUIL = '23-43440000-7',
@sucursal_id = 1,
@turno = 'TM';
GO
SELECT TOP 50 * from gestion_tienda.Empleado;
GO

--Insertamos un medio de pago:
EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'Mercado Pago',
@nombre_EN = 'MP Ewallet';
GO
SELECT TOP 5 * from gestion_ventas.Medio_de_Pago;
GO

--Iniciamos una venta en un punto de venta:
EXEC datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta = 1,
@ID_cliente = null,
@ID_empleado = 1;
GO

select top 3 * from gestion_ventas.Prefactura;

--Agregamos productos al carrito para el punto de venta (la caja) particular:
EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 5794,
@cantidad = 2;
GO


EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 5795,
@cantidad = 3;
GO

select top 3 * from gestion_ventas.Predetalle;
GO

--Cerramos la venta, ingresandose el ID de factura, el comprobante de pago y demas datos. La venta y los detalles se ven
--reflejados en las tablas permanentes
EXEC datos_ventas.cerrarVenta
@ID_punto_venta = 1,
@nro_factura = 'MkJ-A8V-55A',
@tipo_factura = 'C',
@id_medio_pago = 1,
@identificador_pago = '1229421';
GO

SELECT TOP 5 * FROM gestion_ventas.Venta;
SELECT TOP 5 * FROM gestion_ventas.Factura;
SELECT TOP 20 * FROM gestion_ventas.Detalle_venta;
select top 3 * from gestion_ventas.Prefactura;
select top 3 * from gestion_ventas.Predetalle;
GO


--Iniciamos una nota de credito, indicando el ID de factura correspondiente
EXEC datos_notas_credito.iniciar_nota_credito
@ID_factura = 1001,
@ID_empleado = 1,
@ID_punto_venta = 1;


SELECT fact.ID_factura, dv.ID_detalle_venta FROM gestion_ventas.Venta v
		INNER JOIN gestion_ventas.Factura fact on fact.ID_factura = v.ID_factura
		INNER JOIN gestion_ventas.Detalle_venta dv on dv.ID_venta = v.ID_venta
		WHERE fact.nro_factura like 'MkJ-A8V-55A';


SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;


--Agregamos detalles de venta que sean parte de la factura pagada
EXEC datos_notas_credito.nota_credito_agregarProducto
@ID_punto_venta = 1,
@ID_detalle_venta = 1001,
@cantidad = 2;

SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;

--Confirmamos la nota de credito en curso en el punto de venta indicado
EXEC datos_notas_credito.confirmar_notaCredito
@ID_punto_venta = 1;

SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;

--DELETE FROM gestion_ventas.Detalle_nota_credito;
--DELETE FROM gestion_ventas.Nota_credito



----------------------------------------------------------------------
--Prueba unitaria cancelacion de Nota de Credito
----------------------------------------------------------------------

SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;

SELECT fact.ID_factura, dv.ID_detalle_venta FROM gestion_ventas.Venta v
		INNER JOIN gestion_ventas.Factura fact on fact.ID_factura = v.ID_factura
		INNER JOIN gestion_ventas.Detalle_venta dv on dv.ID_venta = v.ID_venta
		WHERE fact.nro_factura like 'MkJ-A8V-55A';

--Iniciamos la nota de credito:
EXEC datos_notas_credito.iniciar_nota_credito
@ID_factura = 1001,
@ID_empleado = 1,
@ID_punto_venta = 1;

--Le agregamos un producto que forme parte de la venta pagada
EXEC datos_notas_credito.nota_credito_agregarProducto
@ID_punto_venta = 1,
@ID_detalle_venta = 1002,
@cantidad = 1;

SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;

--Intentamos cancelar en un punto de venta equivocado:
EXEC datos_notas_credito.cancelar_notaCredito_enCurso
@ID_punto_venta = 800
-- ERROR: No hay nota de credito en curso en ese punto de venta


--Cancelamos la nota de credito en el punto de venta indicado:
EXEC datos_notas_credito.cancelar_notaCredito_enCurso
@ID_punto_venta = 1

SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;


----------------------------------------------------------------------
--Prueba unitaria cancelacion de todas las notas de credito en curso
----------------------------------------------------------------------

--Iniciamos la nota de credito:
EXEC datos_notas_credito.iniciar_nota_credito
@ID_factura = 13001,
@ID_empleado = 46,
@ID_punto_venta = 22;

--Le agregamos un producto que forme parte de la venta pagada
EXEC datos_notas_credito.nota_credito_agregarProducto
@ID_punto_venta = 22,
@ID_detalle_venta = 10220,
@cantidad = 5;

SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;

--Cancelamos todas las notas de credito en curso:
EXEC datos_notas_credito.cancelar_todasLasNotasCredito_enCurso;

SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;


----------------------------------------------------------------------
--Prueba unitaria de Nota de credito vacia
----------------------------------------------------------------------

--Iniciamos la nota de credito:
EXEC datos_notas_credito.iniciar_nota_credito
@ID_factura = 13001,
@ID_empleado = 46,
@ID_punto_venta = 22;

SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;

--Intentamos confirmar una nota de credito vacia en el punto de venta indicado
EXEC datos_notas_credito.confirmar_notaCredito
@ID_punto_venta = 22;
--ERROR: La nota no tiene detalles

SELECT TOP 5 * FROM gestion_ventas.Nota_credito;
SELECT TOP 5 * FROM gestion_ventas.Detalle_nota_credito;
SELECT TOP 20 * FROM gestion_ventas.Pre_notaCredito;
SELECT TOP 5 * FROM gestion_ventas.Pre_detalle_notaCredito;

EXEC datos_notas_credito.cancelar_todasLasNotasCredito_enCurso;
