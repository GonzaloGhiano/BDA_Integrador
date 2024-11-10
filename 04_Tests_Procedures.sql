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

SELECT TOP 3 * FROM gestion_tienda.Sucursal;
GO

EXEC datos_tienda.insertar_sucursal
@nombre = 'Sucursal Centralaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 
@ciudad = 'Buenos Aires', 
@direccion = 'Av. Siempre Viva 123', 
@horario = '9:00 AM - 6:00 PM', 
@telefono = 123456789;
GO
--Error esperado: "Nombre demasiado largo. Longitud maxima de 30 caracteres"


EXEC datos_tienda.insertar_sucursal
@nombre = '', 
@ciudad = 'Buenos Aires', 
@direccion = 'Av. Siempre Viva 123', 
@horario = '9:00 AM - 6:00 PM', 
@telefono = 123456789;
GO
--Error esperado: "ERROR: El nombre de la sucursal no puede ser vacio."


----------------------------------------------------------------------
--Prueba unitaria actualización de datos de sucursal
----------------------------------------------------------------------

EXEC datos_tienda.actualizar_sucursal
@ID_sucursal = 1,
@nombre = 'Nuevo nombre',
@telefono = 123;
GO

SELECT TOP 3 * FROM gestion_tienda.Sucursal;
GO

----------------------------------------------------------------------
--Prueba unitaria borrado logico de sucursal
----------------------------------------------------------------------

EXEC datos_tienda.borrar_sucursal
@ID_sucursal = 1;
GO

SELECT TOP 3 * FROM gestion_tienda.Sucursal;
GO

EXEC datos_tienda.reactivar_sucursal
@ID_sucursal = 1;
GO

SELECT TOP 3 * FROM gestion_tienda.Sucursal;
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
--Prueba unitaria actualización de punto de venta
----------------------------------------------------------------------

EXEC datos_tienda.actualizar_puntoDeVenta
@ID_punto_venta = -3213,
@nro_caja = 1,
@ID_sucursal = 1;
GO

--Error esperado: "El punto de venta no existe"

EXEC datos_tienda.actualizar_puntoDeVenta
@ID_punto_venta = 1,
@nro_caja = -1,
@ID_sucursal = 1;
GO

--Error esperado: "La caja debe ser mayor a 0"

EXEC datos_tienda.actualizar_puntoDeVenta
@ID_punto_venta = 1,
@nro_caja = 3,
@ID_sucursal = 5;
GO

--Error esperado: "La sucursal no es valida"

EXEC datos_tienda.actualizar_puntoDeVenta
@ID_punto_venta = 1,
@nro_caja = 3,
@ID_sucursal = 1;
GO

SELECT TOP 1 * FROM gestion_tienda.punto_de_venta;
GO

EXEC datos_tienda.insertar_sucursal
@nombre = 'Flores Abasto', 
@ciudad = 'Buenos Aires', 
@direccion = 'Av. Rivadavia 666', 
@horario = '8:00 AM - 6:00 PM', 
@telefono = 4312321;
GO

EXEC datos_tienda.insertar_puntoDeVenta
@nro_caja = 1,
@ID_sucursal = 1;
GO

SELECT TOP 3 * FROM gestion_tienda.punto_de_venta;
GO

-- Inserto un nuevo punto de venta, caja 1 en sucursal 1

EXEC datos_tienda.insertar_puntoDeVenta
@nro_caja = 1,
@ID_sucursal = 1;
GO

SELECT TOP 3 * FROM gestion_tienda.punto_de_venta;
GO

--Error esperado, no puedo tener 2 mismas cajas en una misma sucursal (CONSTRAINT UNIQUE)

EXEC datos_tienda.actualizar_puntoDeVenta
@ID_punto_venta = 2,
@nro_caja = 2,
@ID_sucursal = 2;
GO

SELECT TOP 3 * FROM gestion_tienda.punto_de_venta;
GO


----------------------------------------------------------------------
--Prueba unitaria borrado lógico punto de venta
----------------------------------------------------------------------

EXEC datos_tienda.borrar_puntoDeVenta
@ID_punto_venta = -2;
GO

--Error esperado: "El punto de venta -2 no existe"


EXEC datos_tienda.borrar_puntoDeVenta
@ID_punto_venta = 2;
GO

SELECT * FROM gestion_tienda.punto_de_venta pv
where pv.ID_punto_venta = 2;
GO

EXEC datos_tienda.reactivar_puntoDeVenta
@ID_punto_venta = 2;
GO

SELECT * FROM gestion_tienda.punto_de_venta pv
where pv.ID_punto_venta = 2;
GO