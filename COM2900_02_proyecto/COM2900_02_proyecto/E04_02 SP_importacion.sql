/*
	Entrega 4. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a las pruebas de importacion de los archivos del sistema
*/

USE Com2900G02;
GO

/*
DELETE FROM gestion_ventas.Detalle_nota_credito
DELETE FROM gestion_ventas.Nota_credito

DELETE FROM gestion_ventas.Detalle_venta
DELETE FROM gestion_ventas.Venta
DELETE FROM gestion_ventas.Factura

DELETE FROM gestion_tienda.Empleado
DELETE FROM gestion_tienda.punto_de_venta
DELETE FROM gestion_tienda.Sucursal

DELETE FROM gestion_ventas.Medio_de_Pago
DELETE FROM gestion_clientes.Cliente
DELETE FROM gestion_productos.Producto
DELETE FROM gestion_productos.Linea_Producto
*/

DECLARE @ruta_comp varchar(max)= 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\informacion_complementaria.xlsx',
		@ruta_catalogo varchar(max)= 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\Productos\catalogo.csv',
		@ruta_electronica varchar(max)= 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\Productos\Electronic accessories',
		@ruta_importados varchar(max)= 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\Productos\Productos_importados.xlsx',
		@ruta_ventas varchar(max)= 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\Ventas_registradas.csv';
GO


-------------------------------------------------------------------------
-- Configuración CUIT supermercado
-------------------------------------------------------------------------
EXEC gestion_ventas.insertarCUIT_supermercado
@CUIT = '11-11111111-1'


-------------------------------------------------------------------------
-- Prueba de importacion del archivo catalogo.csv
-------------------------------------------------------------------------
exec inserts.insertar_catalogo @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\Productos\catalogo.csv';
GO
SELECT TOP 100 * FROM gestion_productos.Producto;
GO


-------------------------------------------------------------------------
-- Prueba de importacion del archivo informacion_complementaria tabla Lineas de Producto
-- Y posterior actualizacion de los productos correspondientes
-------------------------------------------------------------------------
SELECT TOP 100 * FROM gestion_productos.Linea_Producto;
exec inserts.insertar_clasificacion @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\informacion_complementaria.xlsx';
GO
SELECT TOP 100 * FROM gestion_productos.Producto;
SELECT TOP 100 * FROM gestion_productos.Linea_Producto;
GO

-------------------------------------------------------------------------
-- Prueba de importacion del archivo Electronic accessories.xlsx
-------------------------------------------------------------------------
exec inserts.insertar_electronic @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\Productos\Electronic accessories.xlsx';
GO
SELECT TOP 100 * FROM gestion_productos.Producto where categoria = 'Electronico';


-------------------------------------------------------------------------
-- Prueba de importacion del archivo Productos_importados.xlsx
-------------------------------------------------------------------------
exec inserts.insertar_importado @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
GO
SELECT TOP 100 * FROM gestion_productos.Producto where categoria = 'Importado';

---------------------------------------------------------------------------------
-- Prueba de importacion del archivo informacion_complementaria tabla Sucursal
---------------------------------------------------------------------------------
exec inserts.insertar_sucursal @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO
SELECT TOP 20 * FROM gestion_tienda.Sucursal;

exec inserts.insertar_puntodeVenta_archivos;
GO
SELECT TOP 20 * FROM gestion_tienda.punto_de_venta;

---------------------------------------------------------------------------------
-- Prueba de importacion del archivo informacion_complementaria tabla empleado
---------------------------------------------------------------------------------
EXEC inserts.insertarCargosArchivos;
GO
SELECT TOP 10 * FROM gestion_tienda.Cargo;

exec inserts.insertar_empleado @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO
SELECT TOP 30 * FROM gestion_tienda.Empleado;

---------------------------------------------------------------------------------
-- Prueba de importacion de los medios de pago del archivo informacion complementaria
---------------------------------------------------------------------------------
exec inserts.insertarMediosdePago @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO
SELECT * FROM gestion_ventas.Medio_de_Pago;

---------------------------------------------------------------------------------
-- Prueba de importacion del archivo venta
---------------------------------------------------------------------------------
--DELETE FROM gestion_ventas.Detalle_venta
--DELETE FROM gestion_ventas.Venta
--DELETE FROM gestion_ventas.Factura

exec inserts.insertar_venta @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\Ventas_registradas.csv'
GO

select TOP 100 * from gestion_ventas.Venta order by ID_venta desc;
select TOP 100 * from gestion_ventas.Factura order by ID_factura desc;

select TOP 100 * from gestion_ventas.Detalle_venta order by ID_detalle_venta desc;


---------------------------------------------------------------------------------
-- Prueba de importacion del archivo informacion_complementaria tabla empleado encriptados
---------------------------------------------------------------------------------
EXEC inserts.insertarCargosArchivos;
GO
SELECT TOP 10 * FROM gestion_tienda.Cargo;

EXEC encriptacion.configuracion_encriptacion
@clave = 'ClaveSegura';

select * from encriptacion.Credenciales

exec inserts.insertar_empleado_encriptado 
@ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\informacion_complementaria.xlsx',
@claveEncripcion = 'ClaveSegura';
GO
SELECT TOP 30 * FROM gestion_tienda.Empleado;


