/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a las pruebas unitarias de las tablas del esquema CLIENTES.
*/


USE Com2900G02
GO


-------------------------------------------------------------------------------------------------------------
--					PRUEBAS UNITARIAS DE LA TABLA cliente
-------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------
--Prueba unitaria inserción de datos en tabla cliente
----------------------------------------------------------------------

--Inserción exitosa
exec datos_clientes.insertar_cliente
@num_documento = '46782096',
@tipo_documento = 'DU',
@tipo_cliente = 'normal',
@genero = 'male'
GO

SELECT TOP 3 * FROM gestion_clientes.Cliente;
GO

--Error numero de documento inválido
exec datos_clientes.insertar_cliente
@num_documento = 'LKJ42096',
@tipo_documento = 'DU',
@tipo_cliente = 'normal',
@genero = 'male'
GO

----------------------------------------------------------------------
--Prueba unitaria modificacion de datos en tabla cliente
----------------------------------------------------------------------

--Modificacion exitosa
exec datos_clientes.modificar_cliente
@ID_cliente = 1,
@tipo_documento = 'LE'
GO

SELECT TOP 3 * FROM gestion_clientes.Cliente;
GO

--Error tipo de documento invalido
exec datos_clientes.modificar_cliente
@ID_cliente = 1,
@tipo_documento = 'FF'
GO

----------------------------------------------------------------------
--Prueba unitaria borrado de datos en tabla cliente
----------------------------------------------------------------------

--Borrado exitoso
exec datos_clientes.borrar_cliente
@ID_cliente = 1
GO

SELECT TOP 3 * FROM gestion_clientes.Cliente;
GO

--Error ID inexistente
exec datos_clientes.borrar_cliente
@ID_cliente = 10000
GO

--Reactivar exitoso
exec datos_clientes.reactivar_cliente
@ID_cliente = 1
GO

SELECT TOP 3 * FROM gestion_clientes.Cliente;
GO

--Error ID inexistente
exec datos_clientes.reactivar_cliente
@ID_cliente = 10000
GO