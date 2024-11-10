USE Com2900G02
GO

----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla sucursal
----------------------------------------------------------------------
DELETE FROM gestion_ventas.Detalle_venta;
DELETE FROM gestion_ventas.Comprobante_venta;
DELETE FROM gestion_clientes.cliente;
DELETE FROM gestion_productos.Producto;
DELETE FROM gestion_productos.Linea_Producto;
DELETE FROM gestion_ventas.Medio_de_Pago;
DELETE FROM gestion_tienda.Empleado;
DELETE FROM gestion_tienda.Cargo;
DELETE FROM gestion_tienda.punto_de_venta;
DELETE FROM gestion_tienda.Sucursal;


EXEC datos_tienda.insertar_sucursal 
@nombre = 'Sucursal Central', 
@ciudad = 'Buenos Aires', 
@direccion = 'Av. Siempre Viva 123', 
@horario = '9:00 AM - 6:00 PM', 
@telefono = 123456789;
GO

SELECT TOP 1 * FROM gestion_tienda.Sucursal;
GO
----------------------------------------------------------------------
--Prueba unitaria actualización de datos de sucursal
----------------------------------------------------------------------

EXEC datos_tienda.actualizar_sucursal
@ID_sucursal = 1,
@nombre = 'Nuevo nombre',
@telefono = 123;
GO

SELECT TOP 1 * FROM gestion_tienda.Sucursal;
GO

----------------------------------------------------------------------
--Prueba unitaria borrado logico de sucursal
----------------------------------------------------------------------

EXEC datos_tienda.borrar_sucursal
@ID_sucursal = 1;
GO

SELECT TOP 1 * FROM gestion_tienda.Sucursal;
GO

EXEC datos_tienda.reactivar_sucursal
@ID_sucursal = 1;
GO

SELECT TOP 1 * FROM gestion_tienda.Sucursal;
GO


-------------------------------------------------------------------------------------------------------------
--					PRUEBAS UNITARIAS DE LA TABLA PUNTO DE VENTA
-------------------------------------------------------------------------------------------------------------

EXEC datos_tienda.insertar_puntoDeVenta
@nro_caja = 1,
@ID_sucursal = -421;
GO

-- Error esperado sucursal no válida

EXEC datos_tienda.insertar_puntoDeVenta
@nro_caja = 1,
@ID_sucursal = 1;
GO

SELECT TOP 1 * FROM gestion_tienda.punto_de_venta;
GO

----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla punto de venta
----------------------------------------------------------------------
