/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agust�n 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisi�n: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a las pruebas unitarias de las tablas del esquema DATOS_PRODUCTOS.
*/


USE Com2900G02;
GO

-------------------------------------------------------------------------------------------------------------
--					PRUEBAS UNITARIAS DE LA TABLA PRODUCTO
-------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------
--Prueba unitaria inserci�n de datos en tabla Linea Producto
----------------------------------------------------------------------

--Inserci�n exitosa:
EXEC datos_productos.insertar_lineaProducto
@linea_prod = 'Muy Congelados'
GO

select top 1 * from gestion_productos.Linea_Producto

----------------------------------------------------------------------
--Prueba unitaria actualizaci�n de datos de la tabla Linea Producto
----------------------------------------------------------------------

--Actualizacion exitosa:
EXEC datos_productos.modificar_lineaProducto
@ID_lineaprod = 1,
@linea_prod = 'Super Congelados'
GO

SELECT TOP 1 * FROM gestion_productos.Linea_Producto;
GO

----------------------------------------------------------------------
--Prueba unitaria de eliminaci�n de datos en tabla Linea Producto
----------------------------------------------------------------------

--Borrado exitoso si existe la linea de producto de ID=1:
EXEC datos_productos.borrar_lineaProducto
@ID_lineaprod = 1
GO

SELECT TOP 1 * FROM gestion_productos.Linea_Producto;
GO

--Reactivacion exitosa si existe la linea de producto de ID=1:
EXEC datos_productos.reactivar_lineaProducto
@ID_lineaprod = 1
GO

SELECT TOP 1 * FROM gestion_productos.Linea_Producto;
GO

EXEC datos_productos.borrar_lineaProducto
@ID_lineaprod = -1
GO --Error esperado: "ID de Linea de Producto inexistente"

EXEC datos_productos.reactivar_lineaProducto
@ID_lineaprod = -1
GO -- Error esperado: "ID de Linea de Producto inexistente"



-------------------------------------------------------------------------------------------------------------
--					PRUEBAS UNITARIAS DE LA TABLA PRODUCTO
-------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------
--Prueba unitaria inserci�n de producto
----------------------------------------------------------------------

--Inserci�n exitosa:
EXEC datos_productos.insertar_lineaProducto 'Perfumeria';
SELECT TOP 1 * FROM gestion_productos.Linea_Producto;

EXEC datos_productos.insertar_producto
@nombre_Prod = 'Juguete',
@categoria = 'Patio',
@precio = 100.99,
@referencia_precio = null,
@referencia_unidad = null,
@cod_linea_prod = 1;

SELECT TOP 1 * FROM gestion_productos.Producto;

--Inserci�n con error:
EXEC datos_productos.insertar_producto
@nombre_Prod = '',
@categoria = 'Patio',
@precio = 100.99,
@referencia_precio = null,
@referencia_unidad = null,
@cod_linea_prod = 1;
GO--Error esperado: "El nombre del producto no puede ser vacio"

--Inserci�n con error:
EXEC datos_productos.insertar_producto
@nombre_Prod = 'Peluche',
@precio = 100.99,
@referencia_precio = null,
@referencia_unidad = null,
@cod_linea_prod = 1;
GO--Error esperado: "ERROR: La categoria del producto no puede ser vacio"


--Inserci�n con error:
EXEC datos_productos.insertar_producto
@nombre_Prod = 'Lapicera',
@categoria = 'Patio',
@referencia_precio = null,
@referencia_unidad = null,
@cod_linea_prod = 1;
GO --Error esperado: "El precio del producto es invalido"


--Inserci�n con error:
EXEC datos_productos.insertar_producto
@nombre_Prod = 'Lapicera',
@categoria = 'Patio',
@precio = -1,
@referencia_precio = null,
@referencia_unidad = null,
@cod_linea_prod = 1;
GO --Error esperado: "El precio del producto es invalido"

SELECT TOP 1 * FROM gestion_productos.Producto;

----------------------------------------------------------------------
--Prueba unitaria actualizaci�n del producto
----------------------------------------------------------------------

--Actualizaci�n exitosa:
EXEC datos_productos.modificar_producto
@ID_prod = 1,
@nombre_Prod = 'Bic',
@categoria = 'Biblioteca',
@precio = 3.92;
GO

SELECT TOP 3 * FROM gestion_productos.Producto;


--Actualizaci�n con error
EXEC datos_productos.modificar_producto
@ID_prod = 1,
@nombre_Prod = 'Bic',
@categoria = 'Biblioteca',
@precio = -3.92;
GO --Error esperado: "ERROR: El precio del producto es invalido"

----------------------------------------------------------------------
--Prueba unitaria borrado del producto
----------------------------------------------------------------------
SELECT TOP 3 * FROM gestion_productos.Producto;

--Borrado exitoso si existe el producto con id=1
EXEC datos_productos.borrar_producto
@ID_prod = 1
GO
SELECT TOP 3 * FROM gestion_productos.Producto;
GO

--Reactivacion exitosa si existe el producto con id=1
EXEC datos_productos.reactivar_producto
@ID_prod=1
GO
SELECT TOP 3 * FROM gestion_productos.Producto;
GO

--Borrado con error:
EXEC datos_productos.borrar_producto
SELECT TOP 3 * FROM gestion_productos.Producto;
-- Error esperado: "ERROR: El ID de producto es invalido"

--Reactivacion con error:
EXEC datos_productos.reactivar_producto
SELECT TOP 3 * FROM gestion_productos.Producto;
-- Error esperado: "ERROR: El ID de producto es invalido"

