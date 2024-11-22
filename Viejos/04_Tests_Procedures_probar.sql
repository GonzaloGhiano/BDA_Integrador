USE Com2900G02
GO
----------------------------------------------------------------------
--TEST
----------------------------------------------------------------------

----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla medios de pago
----------------------------------------------------------------------
EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'Tarjeta de debito VISA',
@nombre_EN = 'Debit card VISA'
GO

select * from gestion_ventas.Medio_de_Pago

EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'Tarjeta de debito VISA',
@nombre_EN = 'VISA'
GO
--Error esperado: "Nombre en español repetido"

EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'VISA',
@nombre_EN = 'Debit card VISA'
GO
--Error esperado: "Nombre en ingles repetido"

----------------------------------------------------------------------
--Prueba unitaria inserción de actualización de datos de la tabla medios de pago
----------------------------------------------------------------------
EXEC datos_ventas.modificar_medioDePago
@ID_MP = -2,
@nombre_ES = 'Billete',
@nombre_EN = 'Money'
GO

--Error esperado: "ID_MP NO ENCONTRADO"

EXEC datos_ventas.modificar_medioDePago
@ID_MP = 1,
@nombre_ES = 'Billete',
@nombre_EN = 'Money'
GO

EXEC datos_ventas.modificar_medioDePago
@ID_MP = 1,
@nombre_ES = 'Billete'
GO

SELECT TOP 3 * FROM gestion_ventas.Medio_de_Pago;
GO

----------------------------------------------------------------------
--Prueba unitaria de eliminación de datos en tabla medios de pago
----------------------------------------------------------------------
SELECT TOP 3 * FROM gestion_ventas.Medio_de_Pago;

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

----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla Linea Producto
----------------------------------------------------------------------
EXEC datos_productos.insertar_lineaProducto
@linea_prod = 'Muy Congelados'
GO

select top 1 * from gestion_productos.Linea_Producto

----------------------------------------------------------------------
--Prueba unitaria actualización de datos de la tabla Linea Producto
----------------------------------------------------------------------
EXEC datos_productos.modificar_lineaProducto
@ID_lineaprod = 1,
@linea_prod = 'Super Congelados'
GO

SELECT TOP 1 * FROM gestion_productos.Linea_Producto;
GO

----------------------------------------------------------------------
--Prueba unitaria de eliminación de datos en tabla Linea Producto
----------------------------------------------------------------------
EXEC datos_productos.borrar_lineaProducto
@ID_lineaprod = 1
GO

SELECT TOP 1 * FROM gestion_productos.Linea_Producto;
GO

EXEC datos_productos.reactivar_lineaProducto
@ID_lineaprod = 1
GO

SELECT TOP 1 * FROM gestion_productos.Linea_Producto;
GO

EXEC datos_productos.borrar_lineaProducto
@ID_lineaprod = -1
GO

--Error esperado: "ID de Linea de Producto inexistente"

EXEC datos_productos.reactivar_lineaProducto
@ID_lineaprod = -1
GO

-- Error esperado: "ID de Linea de Producto inexistente"

