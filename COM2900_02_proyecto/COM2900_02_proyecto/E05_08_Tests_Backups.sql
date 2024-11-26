/*
	Entrega 5. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a la prueba de los Store Procedure utilizados para los respaldos FULL y
	DIFERENCIAL de la base de datos.
*/

USE Com2900G02;
GO

--Ejecutamos un respaldo FULL de la base
EXEC CrearRespaldoCompleto
@ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final'
GO

--Ejecutamos un respaldo DIFENCIAL de la base
EXEC CrearRespaldoDiferencial
@ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final'
GO

