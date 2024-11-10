USE Com2900G02;
GO

-------------------------------------------------------------------------------------------------------------
--					PRUEBAS UNITARIAS DE LA TABLA PRODUCTO
-------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------
--Prueba unitaria inserción de producto
----------------------------------------------------------------------

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


EXEC datos_productos.insertar_producto
@nombre_Prod = '',
@categoria = 'Patio',
@precio = 100.99,
@referencia_precio = null,
@referencia_unidad = null,
@cod_linea_prod = 1;
GO
--Error esperado: "El nombre del producto no puede ser vacio"

EXEC datos_productos.insertar_producto
@nombre_Prod = 'Peluche',
@precio = 100.99,
@referencia_precio = null,
@referencia_unidad = null,
@cod_linea_prod = 1;
GO
--Error esperado: "ERROR: La categoria del producto no puede ser vacio"


EXEC datos_productos.insertar_producto
@nombre_Prod = 'Lapicera',
@categoria = 'Patio',
@referencia_precio = null,
@referencia_unidad = null,
@cod_linea_prod = 1;
GO
--Error esperado: "El precio del producto es invalido"


EXEC datos_productos.insertar_producto
@nombre_Prod = 'Lapicera',
@categoria = 'Patio',
@precio = -1,
@referencia_precio = null,
@referencia_unidad = null,
@cod_linea_prod = 1;
GO
--Error esperado: "El precio del producto es invalido"

SELECT TOP 1 * FROM gestion_productos.Producto;

----------------------------------------------------------------------
--Prueba unitaria actualización del producto
----------------------------------------------------------------------

EXEC datos_productos.modificar_producto
@ID_prod = 1,
@nombre_Prod = 'Bic',
@categoria = 'Biblioteca',
@precio = 3.92;
GO

SELECT TOP 3 * FROM gestion_productos.Producto;

EXEC datos_productos.modificar_producto
@ID_prod = 1,
@nombre_Prod = 'Bic',
@categoria = 'Biblioteca',
@precio = -3.92;
GO

SELECT TOP 3 * FROM gestion_productos.Producto;


EXEC datos_productos.modificar_producto
@ID_prod = 1,
@nombre_Prod = 'Bic',
@categoria = 'Biblioteca',
@precio = -3.92;
GO
--Error esperado: "ERROR: El precio del producto es invalido"

----------------------------------------------------------------------
--Prueba unitaria actualización del producto
----------------------------------------------------------------------
SELECT TOP 3 * FROM gestion_productos.Producto;

EXEC datos_productos.borrar_producto
@ID_prod = 1
GO
SELECT TOP 3 * FROM gestion_productos.Producto;
GO

EXEC datos_productos.reactivar_producto
@ID_prod=1
GO
SELECT TOP 3 * FROM gestion_productos.Producto;
GO

EXEC datos_productos.borrar_producto
SELECT TOP 3 * FROM gestion_productos.Producto;
-- Error esperado: "ERROR: El ID de producto es invalido"

EXEC datos_productos.reactivar_producto
SELECT TOP 3 * FROM gestion_productos.Producto;
-- Error esperado: "ERROR: El ID de producto es invalido"

