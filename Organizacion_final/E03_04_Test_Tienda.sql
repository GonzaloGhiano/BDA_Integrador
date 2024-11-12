/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a las pruebas unitarias de las tablas del esquema TIENDA.
*/

USE Com2900G02
GO

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


-------------------------------------------------------------------------------------------------------------
--					PRUEBAS UNITARIAS DE LA TABLA SUCURSAL
-------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla sucursal
----------------------------------------------------------------------

--Inserción exitosa
EXEC datos_tienda.insertar_sucursal 
@nombre = 'Sucursal Central', 
@ciudad = 'Buenos Aires', 
@direccion = 'Av. Siempre Viva 123', 
@horario = '9:00 AM - 6:00 PM', 
@telefono = 123456789;
GO

SELECT TOP 3 * FROM gestion_tienda.Sucursal;
GO

--Inserción con error
EXEC datos_tienda.insertar_sucursal
@nombre = 'Sucursal Centralaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 
@ciudad = 'Buenos Aires', 
@direccion = 'Av. Siempre Viva 123', 
@horario = '9:00 AM - 6:00 PM', 
@telefono = 123456789;
GO
--Error esperado: "Nombre demasiado largo. Longitud maxima de 30 caracteres"

--Inserción con error
EXEC datos_tienda.insertar_sucursal
@nombre = '', 
@ciudad = 'Buenos Aires', 
@direccion = 'Av. Siempre Viva 123', 
@horario = '9:00 AM - 6:00 PM', 
@telefono = 123456789;
GO
--Error esperado: "ERROR: El nombre de la sucursal no puede ser vacio."

--Inserción con error
EXEC datos_tienda.insertar_sucursal
@nombre = null, 
@ciudad = 'Buenos Aires', 
@direccion = 'Av. Siempre Viva 123', 
@horario = '9:00 AM - 6:00 PM', 
@telefono = 123456789;
GO
--Error esperado: "ERROR: El nombre de la sucursal no puede ser vacio."

--Inserción con error
EXEC datos_tienda.insertar_sucursal
@nombre = 'Sucursal Devoto', 
@ciudad = '', 
@direccion = 'Av. Siempre Viva 12233', 
@horario = '9:00 AM - 6:00 PM', 
@telefono = 122456789;
GO
--Error esperado: "ERROR: La ciudad de la sucursal no puede ser vacio"

--Inserción con error
EXEC datos_tienda.insertar_sucursal
@nombre = 'Sucursal Devoto', 
-- sin ciudad
@direccion = 'Av. Siempre Viva 12233', 
@horario = '9:00 AM - 6:00 PM', 
@telefono = 122456789;
GO
--Error esperado: "ERROR: La ciudad de la sucursal no puede ser vacio"

----------------------------------------------------------------------
--Prueba unitaria actualización de datos de sucursal
----------------------------------------------------------------------

--Actualización exitosa
EXEC datos_tienda.actualizar_sucursal
@ID_sucursal = 1,
@nombre = 'Nuevo nombre',
@telefono = 123;
GO

SELECT TOP 3 * FROM gestion_tienda.Sucursal;
GO

--Actualizacion con error
EXEC datos_tienda.actualizar_sucursal
@ID_sucursal = 1,
@nombre = '',
@telefono = 123;
GO
--Error esperado: "ERROR: El nombre de la sucursal no puede ser vacio."
SELECT TOP 3 * FROM gestion_tienda.Sucursal;
GO

----------------------------------------------------------------------
--Prueba unitaria borrado logico de sucursal
----------------------------------------------------------------------

--Borrado exitoso
EXEC datos_tienda.borrar_sucursal
@ID_sucursal = 1;
GO

SELECT TOP 3 * FROM gestion_tienda.Sucursal;
GO

--Reactivacion exitosa
EXEC datos_tienda.reactivar_sucursal
@ID_sucursal = 1;
GO

SELECT TOP 3 * FROM gestion_tienda.Sucursal;
GO

EXEC datos_tienda.borrar_sucursal
@ID_sucursal = -13213;
GO
--Error esperado: "La sucursal -13213 no existe"


EXEC datos_tienda.reactivar_sucursal
@ID_sucursal = -13213;
GO
--Error esperado: "La sucursal -13213 no existe"



-------------------------------------------------------------------------------------------------------------
--					PRUEBAS UNITARIAS DE LA TABLA PUNTO DE VENTA
-------------------------------------------------------------------------------------------------------------

--Inserción con error
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
GO --Error esperado: "El punto de venta no existe"


EXEC datos_tienda.actualizar_puntoDeVenta
@ID_punto_venta = 1,
@nro_caja = -1,
@ID_sucursal = 1;
GO --Error esperado: "La caja debe ser mayor a 0"


EXEC datos_tienda.actualizar_puntoDeVenta
@ID_punto_venta = 1,
@nro_caja = 3,
@ID_sucursal = 5;
GO --Error esperado: "La sucursal no es valida"


--Actualizacion exitosa
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

--Borrado y reactivacion exitosos si existe el punto de venta con ID=2
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


-------------------------------------------------------------------------------------------------------------
--					PRUEBAS UNITARIAS DE LA TABLA EMPLEADO
-------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla empleado
----------------------------------------------------------------------

--Inserción correcta
exec datos_tienda.insertar_empleado
@legajo = '958396',
@nombre = 'Pedrito',
@apellido = 'Perez',
@num_documento = '34957207',
@tipo_documento = 'DU',
@direccion = 'Florencio Varela 986',
@email_empresarial = 'p.perez@empresa.org',
@CUIL = '15-34957207-7';
GO

SELECT TOP 3 * FROM gestion_tienda.Empleado
GO

--Error tipo de documento no válido (mandando algo incorrecto)
exec datos_tienda.insertar_empleado
@legajo = '958396',
@nombre = 'Pedrito',
@apellido = 'Perez',
@num_documento = '34957207',
@tipo_documento = 'JJ',
@direccion = 'Florencio Varela 986',
@email_empresarial = 'p.perez@empresa.org',
@CUIL = '15-34957207-7';
GO

--Error tipo de documento no válido (mandando vacío)
exec datos_tienda.insertar_empleado
@legajo = '958396',
@nombre = 'Pedrito',
@apellido = 'Perez',
@num_documento = '34957207',
@tipo_documento = '',
@direccion = 'Florencio Varela 986',
@email_empresarial = 'p.perez@empresa.org',
@CUIL = '15-34957207-7';
GO

--Error numero de documento invalido (no mandar numero de documento)
exec datos_tienda.insertar_empleado
@legajo = '958396',
@nombre = 'Pedrito',
@apellido = 'Perez',
@tipo_documento = 'DU',
@direccion = 'Florencio Varela 986',
@email_empresarial = 'p.perez@empresa.org',
@CUIL = '15-34957207-7';
GO

----------------------------------------------------------------------
--Prueba unitaria modificación de datos en tabla empleado
----------------------------------------------------------------------

--Modificación exitosa de nombre
exec datos_tienda.modificar_empleado
@ID_empleado = 2,
@nombre = 'Jorge'
GO

SELECT TOP 3 * FROM gestion_tienda.Empleado
GO

--Error esperado ID de empleado inexistente
exec datos_tienda.modificar_empleado
@ID_empleado = 854,
@nombre = 'Jorge'
GO

--Error número de documento no es valido
exec datos_tienda.modificar_empleado
@ID_empleado = 854,
@num_documento = 'Jorge'
GO

----------------------------------------------------------------------
--Prueba unitaria borrado de datos en tabla empleado
----------------------------------------------------------------------

--Borrado lógico exitoso
exec datos_tienda.borrar_empleado
@ID_empleado = 2
GO

SELECT TOP 3 * FROM gestion_tienda.Empleado
GO

--Error ID de empleado inexistente
exec datos_tienda.borrar_empleado
@ID_empleado = 854
GO

--Reactivasión exitosa
exec datos_tienda.reactivar_empleado
@ID_empleado = 2
GO

SELECT TOP 3 * FROM gestion_tienda.Empleado
GO

--Error ID de empleado inexistente
exec datos_tienda.reactivar_empleado
@ID_empleado = 854
GO


-------------------------------------------------------------------------------------------------------------
--					PRUEBAS UNITARIAS DE LA TABLA COTIZACION_USD
-------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------
--Prueba unitaria insercion de cotizacion
----------------------------------------------------------------------
Select top 10 * from gestion_tienda.Cotizacion_USD;
GO

EXEC datos_tienda.insertar_Cotizacion_USD
@valor = 1000;
GO
Select top 10 * from gestion_tienda.Cotizacion_USD;
GO


----------------------------------------------------------------------
--Prueba unitaria modificacion de cotizacion
----------------------------------------------------------------------

EXEC datos_tienda.modificar_Cotizacion_USD
@ID_cotizacion = 1,
@valor = 1100;
GO
Select top 10 * from gestion_tienda.Cotizacion_USD;
GO

----------------------------------------------------------------------
--Prueba unitaria borrado de cotizacion
----------------------------------------------------------------------

EXEC datos_tienda.eliminar_Cotizacion_USD
@ID_cotizacion = 1
GO
Select top 10 * from gestion_tienda.Cotizacion_USD;
GO