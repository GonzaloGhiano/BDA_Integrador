USE Com2900G02
GO

----------------------------------------------------------------------
--TEST
----------------------------------------------------------------------

----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla medios de pago
----------------------------------------------------------------------
EXEC gestion_ventas.InsertarMedio_de_Pago
@nombre_ES = 'Tarjeta de debito2',
@nombre_EN = 'Debit card1'
GO

select * from gestion_ventas.Medio_de_Pago

----------------------------------------------------------------------
--Prueba unitaria inserción de actualización de datos de la tabla medios de pago
----------------------------------------------------------------------
EXEC gestion_ventas.Modificar_medio_de_pago
@ID_MP = 2,
@nombre_ES = 'Billete',
@nombre_EN = 'Money'
GO

SELECT TOP 1 * FROM gestion_ventas.Medio_de_Pago;
GO

----------------------------------------------------------------------
--Prueba unitaria de eliminación de datos en tabla medios de pago
----------------------------------------------------------------------
EXEC gestion_ventas.borrar_medio_de_pago 
@ID_MP = 2
GO

SELECT TOP 1 * FROM gestion_ventas.Medio_de_Pago;
GO

-
----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla Linea Producto
----------------------------------------------------------------------
EXEC gestion_productos.InsertarLinea_Producto
@linea_prod = 'Muy Congelados'
GO

select top 1 * from gestion_productos.Linea_Producto

----------------------------------------------------------------------
--Prueba unitaria inserción de actualización de datos de la tabla Linea Producto
----------------------------------------------------------------------
EXEC gestion_productos.ModificarLinea_Producto
@ID_lineaprod = 1,
@linea_prod = 'Super Congelados'
GO

SELECT TOP 1 * FROM gestion_productos.Linea_Producto;
GO

----------------------------------------------------------------------
--Prueba unitaria de eliminación de datos en tabla Linea Producto
----------------------------------------------------------------------
EXEC gestion_productos.BorrarLinea_Producto
@ID_lineaprod = 1
GO

SELECT TOP 1 * FROM gestion_productos.Linea_Producto;
GO

