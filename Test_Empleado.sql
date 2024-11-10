USE Com2900G02;
GO

----------------------------------------------------------------------
--Prueba unitaria inserci�n de datos en tabla empleado
----------------------------------------------------------------------

--Inserci�n correcta
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

--Error tipo de documento no v�lido (mandando algo incorrecto)
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

--Error tipo de documento no v�lido (mandando vac�o)
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
--Prueba unitaria modificaci�n de datos en tabla empleado
----------------------------------------------------------------------

--Modificaci�n exitosa de nombre
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

--Error n�mero de documento no es valido
exec datos_tienda.modificar_empleado
@ID_empleado = 854,
@num_documento = 'Jorge'
GO

----------------------------------------------------------------------
--Prueba unitaria borrado de datos en tabla empleado
----------------------------------------------------------------------

--Borrado l�gico exitoso
exec datos_tienda.borrar_empleado
@ID_empleado = 2
GO

SELECT TOP 3 * FROM gestion_tienda.Empleado
GO

--Error ID de empleado inexistente
exec datos_tienda.borrar_empleado
@ID_empleado = 854
GO

--Reactivasi�n exitosa
exec datos_tienda.reactivar_empleado
@ID_empleado = 2
GO

SELECT TOP 3 * FROM gestion_tienda.Empleado
GO

--Error ID de empleado inexistente
exec datos_tienda.reactivar_empleado
@ID_empleado = 854
GO