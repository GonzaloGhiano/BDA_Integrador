/*
	Entrega 5. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agust�n 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisi�n: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a las pruebas de encriptaci�n de los datos de los empleados
*/

USE Com2900G02;
GO


-------------------------------------------------------------------------------------------------
--	Prueba unitaria de inserci�n masiva con encriptaci�n de los empleados
-------------------------------------------------------------------------------------------------

exec inserts.insertar_empleado_encriptado @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO

SELECT TOP 30 * FROM gestion_tienda.Empleado;
GO

EXEC gestion_tienda.mostrarEmpleados_desencriptados
GO

-------------------------------------------------------------------------------------------------
--	Prueba unitaria de inserci�n de un empleado con datos encriptados
-------------------------------------------------------------------------------------------------

EXEC datos_tienda.insertar_empleado_encriptado
@legajo = 9999,
@nombre = 'Gonzalo',
@apellido = 'Gonzalez',
@num_documento = 12345678,
@tipo_documento = 'DU',
@direccion = 'Avenida Rivadavia 123',
@email_personal = 'gonzalogonzalez@hotmail.com',
@email_empresarial  = 'gonzalogonzalez@empresa.com',
@CUIL = '22-44312312-2',
@cargo = 1,
@sucursal_id = 1,
@turno = 'NA';

SELECT TOP 30 * FROM gestion_tienda.Empleado;
GO

EXEC gestion_tienda.mostrarEmpleados_desencriptados
GO