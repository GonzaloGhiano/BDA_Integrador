/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a las pruebas unitarias de las tablas del esquema DATOS_VENTAS.
*/


USE Com2900G02;
GO


------------------------------------------------------------------------------------
--	PRUEBAS UNITARIAS DE LAS TABLAS COMPROBANTE DE VENTA Y DETALLE DE VENTA
-------------------------------------------------------------------------------------

----------------------------------------------------------------------
--Prueba unitaria venta exitosa
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
@ID_sucursal = 1;
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


--Insertamos un empleado:
EXEC datos_tienda.insertar_empleado
@legajo = 000001,
@nombre = 'Felipe',
@apellido = 'Probando',
@num_documento = 43440000,
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

--Insertamos un medio de pago:
EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'Efectivo2',
@nombre_EN = 'Cash2';
GO
SELECT TOP 3 * from gestion_ventas.Medio_de_Pago;
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
@ID_prod = 1,
@cantidad = 2;
GO


EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 2,
@cantidad = 3;
GO

select top 3 * from gestion_ventas.Predetalle;
GO

--Cerramos la venta, ingresandose el ID de factura, el comprobante de pago y demas datos. La venta y los detalles se ven
--reflejados en las tablas permanentes
EXEC datos_ventas.cerrarVenta
@ID_punto_venta = 1,
@nro_factura = 'MJJ-AAV-ANA',
@tipo_factura = 'B',
@id_medio_pago = 1,
@identificador_pago = '1129421';
GO

SELECT TOP 5 * FROM gestion_ventas.Venta;
SELECT TOP 5 * FROM gestion_ventas.Factura;
SELECT TOP 20 * FROM gestion_ventas.Detalle_venta;
select top 3 * from gestion_ventas.Prefactura;
select top 3 * from gestion_ventas.Predetalle;
GO

----------------------------------------------------------------------
--Prueba unitaria Cliente con CUIL
----------------------------------------------------------------------

--Prueba con cliente con CUIL
exec datos_clientes.insertar_cliente
@num_documento = 11112222,
@tipo_documento = 'DU',
@tipo_cliente = 'normal',
@genero = 'Male',
@CUIL = '30-11112222-2'
GO
SELECT TOP 10 * from gestion_clientes.Cliente;

--Iniciamos una venta en un punto de venta:
EXEC datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta = 1,
@ID_cliente = 1,
@ID_empleado = 1;
GO

EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 2,
@cantidad = 3;
GO

EXEC datos_ventas.cerrarVenta
@ID_punto_venta = 1,
@nro_factura = 'NAJ-ACC-AZA',
@tipo_factura = 'C',
@id_medio_pago = 1,
@identificador_pago = '1153121';
GO

SELECT TOP 5 * FROM gestion_ventas.Venta;
SELECT TOP 5 * FROM gestion_ventas.Factura;
SELECT TOP 20 * FROM gestion_ventas.Detalle_venta;
select top 3 * from gestion_ventas.Prefactura;
select top 3 * from gestion_ventas.Predetalle;
GO

--Prueba de punto de venta incorrecto:
EXEC datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta = 500,
@ID_cliente = null,
@ID_empleado = 1;
GO--Error esperado: "No existe el punto de venta"

--Prueba de punto de venta incorrecto:
EXEC datos_ventas.agregarProducto
@ID_punto_venta = 451,
@ID_prod = 1,
@cantidad = 2;
GO--Error esperado: "ERROR: No hay venta en curso"

--Prueba de punto de venta incorrecto:
EXEC datos_ventas.cerrarVenta
@ID_punto_venta = 3213,
@nro_factura = 'ZZB-ACC-AAA',
@tipo_factura = 'A',
@id_medio_pago = 1,
@identificador_pago = '11111';
GO--Error esperado: "ERROR: No hay venta en curso"


----------------------------------------------------------------------
--Prueba unitaria venta cancelada
----------------------------------------------------------------------

--Primero necesitamos una sucursal
EXEC datos_tienda.insertar_sucursal
@nombre = 'San pedrito',
@ciudad = 'La Matanza 2',
@direccion = 'Florencio Varela 912',
@horario = '8AM - 11PM',
@telefono = 999;

SELECT TOP 3 * from gestion_tienda.Sucursal;
GO

--Necesitamos una caja en esa sucursal, representada como un punto de venta
EXEC datos_tienda.insertar_puntoDeVenta
@nro_caja = 2,
@ID_sucursal = 2;
SELECT TOP 2 * from gestion_tienda.punto_de_venta;
GO

EXEC datos_productos.insertar_lineaProducto
@linea_prod = 'Pañales y vinos';
GO
SELECT TOP 3 * from gestion_productos.Linea_Producto;
GO


--Insertamos dos productos:
EXEC datos_productos.insertar_producto
@nombre_Prod = 'Pampers',
@categoria = 'Pañales',
@precio = 200.99,
@cod_linea_prod = 2
GO
SELECT TOP 5 * from gestion_productos.Producto;
GO

EXEC datos_productos.insertar_producto
@nombre_Prod = 'Toro',
@categoria = 'Vino',
@precio = 50.50,
@cod_linea_prod = 1
GO
SELECT TOP 5 * from gestion_productos.Producto;
GO


--Insertamos un empleado:
EXEC datos_tienda.insertar_empleado
@legajo = 000022,
@nombre = 'Gonza',
@apellido = 'Errando',
@num_documento = 43245000,
@tipo_documento = 'DU',
@direccion = 'Su casa 123',
@email_personal = 'gonza.com',
@email_empresarial = 'gonza.org',
@CUIL = '23-43443000-7',
@sucursal_id = 1,
@turno = 'TM';
GO
SELECT TOP 5 * from gestion_tienda.Empleado;
GO

--Insertamos un medio de pago:
EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'Tarjeta',
@nombre_EN = 'Card';
GO
SELECT TOP 3 * from gestion_ventas.Medio_de_Pago;
GO

--Iniciamos una venta en un punto de venta:
EXEC datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta = 2,
@ID_cliente = null,
@ID_empleado = 2;
GO

select top 3 * from gestion_ventas.Prefactura;
select top 3 * from gestion_ventas.Predetalle;

--Agregamos productos al carrito para el punto de venta (la caja) particular:
EXEC datos_ventas.agregarProducto
@ID_punto_venta = 2,
@ID_prod = 2,
@cantidad = 2;
GO

EXEC datos_ventas.agregarProducto
@ID_punto_venta = 2,
@ID_prod = 1,
@cantidad = 3;
GO

select top 3 * from gestion_ventas.Predetalle;
GO

--Cancelamos la venta con el ID_punto_venta indicado
EXEC datos_ventas.cancelar_venta
@ID_punto_venta = 2
GO

select top 3 * from gestion_ventas.Predetalle;
GO
select top 3 * from gestion_ventas.Prefactura;
GO
select top 3 * from gestion_ventas.Venta
GO
select top 3 * from gestion_ventas.Factura
GO
select top 3 * from gestion_ventas.Detalle_venta
GO


--Cancelacion erronea por punto de venta inexistente
EXEC datos_ventas.cancelar_venta
@ID_punto_venta =54
GO -- Error esperado: "ERROR: No hay venta en curso"

----------------------------------------------------------------------
--Prueba unitaria todas las ventas son canceladas
----------------------------------------------------------------------

--Iniciamos una venta en un punto de venta:
EXEC datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta = 1,
@ID_cliente = null,
@ID_empleado = 2;
GO

--Agregamos productos al carrito para el punto de venta (la caja) particular:
EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 1,
@cantidad = 2;
GO

select top 3 * from gestion_ventas.Predetalle;
select top 3 * from gestion_ventas.Prefactura;
GO

--Cancelamos todas las ventas en curso
EXEC datos_ventas.cancelar_todasLasVentas
GO

select top 3 * from gestion_ventas.Predetalle;
GO
select top 3 * from gestion_ventas.Prefactura;
GO
select top 3 * from gestion_ventas.Venta
GO
select top 3 * from gestion_ventas.Factura
GO
select top 3 * from gestion_ventas.Detalle_venta
GO

----------------------------------------------------------------------
--Prueba unitaria sacar producto del carrito
----------------------------------------------------------------------


--Necesitamos una caja en esa sucursal, representada como un punto de venta
EXEC datos_tienda.insertar_puntoDeVenta
@nro_caja = 3,
@ID_sucursal = 2;
SELECT TOP 10 * from gestion_tienda.punto_de_venta;
GO

EXEC datos_productos.insertar_lineaProducto
@linea_prod = 'Pañales y vinos';
GO
SELECT TOP 3 * from gestion_productos.Linea_Producto;
GO


--Insertamos dos productos:
EXEC datos_productos.insertar_producto
@nombre_Prod = 'Pampers',
@categoria = 'Pañales',
@precio = 200.99,
@cod_linea_prod = 3
GO
SELECT TOP 5 * from gestion_productos.Producto;
GO

--Insertamos dos productos:
EXEC datos_productos.insertar_producto
@nombre_Prod = 'Huggies',
@categoria = 'Pañales',
@precio = 200.99,
@cod_linea_prod = 3
GO
SELECT TOP 10 * from gestion_productos.Producto;
GO

--Iniciamos una venta en un punto de venta:
EXEC datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta = 1,
@ID_cliente = null,
@ID_empleado = 2;
GO



--Agregamos productos al carrito para el punto de venta (la caja) particular:
EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 1,
@cantidad = 2;
GO

EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 1,
@cantidad = 2;
GO

select top 3 * from gestion_ventas.Predetalle;
GO
select top 3 * from gestion_ventas.Prefactura;
GO
select top 3 * from gestion_ventas.Venta
GO
select top 3 * from gestion_ventas.Factura
GO
select top 3 * from gestion_ventas.Detalle_venta
GO


EXEC datos_ventas.sacarProductodeVenta
@ID_punto_venta = 1,
@ID_prod = 1;
GO


EXEC datos_ventas.cancelar_todasLasVentas;
GO

----------------------------------------------------------------------
--Prueba unitaria articulos en pesos y dolares
----------------------------------------------------------------------

--Insertamos dos productos:
EXEC datos_productos.insertar_producto
@nombre_Prod = 'Lapiz Nacional',
@categoria = 'Libreria prueba',
@precio = 20,
@cod_linea_prod = 445,
@moneda = 'ARS'
GO

SELECT TOP 10 * from gestion_productos.Linea_Producto;

SELECT TOP 5 * from gestion_productos.Producto p where p.nombre_Prod like 'Lapiz Nacional';
GO

--Insertamos producto importado con precio en USD
EXEC datos_productos.insertar_producto
@nombre_Prod = 'Lapiz Importado',
@categoria = 'Importado',
@precio = 20,
@cod_linea_prod = 445,
@moneda = 'USD'
GO 
SELECT TOP 5 * from gestion_productos.Producto p where p.nombre_Prod like 'Lapiz Importado';
GO


SELECT TOP 5 * FROM gestion_tienda.punto_de_venta;
SELECT TOP 5 * FROM gestion_tienda.Empleado;

--Iniciamos una venta en un punto de venta:
EXEC datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta = 22,
@ID_cliente = null,
@ID_empleado = 46;
GO


--Agregamos productos al carrito para el punto de venta (la caja) particular:
EXEC datos_ventas.agregarProducto
@ID_punto_venta = 22,
@ID_prod = 23176,
@cantidad = 2;
GO

EXEC datos_ventas.agregarProducto
@ID_punto_venta = 22,
@ID_prod = 23175,
@cantidad = 2;
GO

select top 3 * from gestion_ventas.Predetalle;
GO
select top 3 * from gestion_ventas.Prefactura;
GO
select top 3 * from gestion_ventas.Venta
GO
select top 3 * from gestion_ventas.Factura
GO
select top 3 * from gestion_ventas.Detalle_venta
GO

SELECT * FROM gestion_ventas.Medio_de_Pago;

EXEC datos_ventas.cerrarVenta
@ID_punto_venta = 22,
@nro_factura = '4AA-BBA-BCC',
@tipo_factura = 'C',
@id_medio_pago = 13,
@identificador_pago = '3421412451';

SELECT * FROM gestion_ventas.Factura fact
INNER JOIN gestion_ventas.Venta v on v.ID_factura = fact.ID_factura
INNER JOIN gestion_ventas.Detalle_venta dv on dv.ID_venta = v.ID_venta
WHERE fact.nro_factura = '4AA-BBA-BCC';

------------------------------------------------------------------------------------
--	PRUEBAS UNITARIAS DE LA TABLA MEDIOS DE PAGO
-------------------------------------------------------------------------------------

----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla medios de pago
----------------------------------------------------------------------

--Inserción exitosa:
EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'Tarjeta de debito VISA',
@nombre_EN = 'Debit card VISA'
GO

select * from gestion_ventas.Medio_de_Pago

EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'Tarjeta de debito VISA',
@nombre_EN = 'VISA'
GO --Error esperado: "Nombre en español repetido"

EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'VISA',
@nombre_EN = 'Debit card VISA'
GO --Error esperado: "Nombre en ingles repetido"

----------------------------------------------------------------------
--Prueba unitaria inserción de actualización de datos de la tabla medios de pago
----------------------------------------------------------------------

EXEC datos_ventas.modificar_medioDePago
@ID_MP = -2,
@nombre_ES = 'Billete',
@nombre_EN = 'Money'
GO --Error esperado: "ID_MP NO ENCONTRADO"

--Modificacion exitosa si existe el MP con ID=1
EXEC datos_ventas.modificar_medioDePago
@ID_MP = 1,
@nombre_ES = 'Billete',
@nombre_EN = 'Money'
GO

EXEC datos_ventas.modificar_medioDePago
@ID_MP = 1,
@nombre_ES = 'Billete'
GO --Nombre en español repetido

SELECT TOP 3 * FROM gestion_ventas.Medio_de_Pago;
GO

----------------------------------------------------------------------
--Prueba unitaria de eliminación de datos en tabla medios de pago
----------------------------------------------------------------------
SELECT TOP 3 * FROM gestion_ventas.Medio_de_Pago;

--Eliminación y reactivacion exitosas si existe el MP con ID=1
EXEC datos_ventas.borrar_medioDePago
@ID_MP = 1
GO

SELECT TOP 3 * FROM gestion_ventas.Medio_de_Pago;
GO

EXEC datos_ventas.reactivar_medioDePago
@ID_MP = 1
GO
SELECT TOP 3 * FROM gestion_ventas.Medio_de_Pago;
GO



