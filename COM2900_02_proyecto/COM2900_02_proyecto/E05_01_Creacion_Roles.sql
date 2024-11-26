/*
	Entrega 5. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente creacion roles que se utilizaran en el sistema
*/

USE Com2900G02;
GO

-- Crear rol cajeros solo si no existe
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'cajeros' AND type = 'R')
BEGIN
    CREATE ROLE cajeros;
END
GO

GRANT EXECUTE ON SCHEMA::datos_ventas TO cajeros;
GO
GRANT EXECUTE ON SCHEMA::datos_clientes TO cajeros;
GO

-- Crear rol supervisores solo si no existe
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'supervisores' AND type = 'R')
BEGIN
    CREATE ROLE supervisores;
END
GO

GRANT EXECUTE ON SCHEMA::datos_tienda TO supervisores;
GO
GRANT EXECUTE ON SCHEMA::datos_productos TO supervisores;
GO
GRANT EXECUTE ON SCHEMA::datos_ventas TO supervisores;
GO
GRANT EXECUTE ON SCHEMA::datos_clientes TO supervisores;
GO
GRANT EXECUTE ON SCHEMA::reportes TO supervisores;
GO
GRANT EXECUTE ON SCHEMA::datos_notas_credito TO supervisores;
GO


/*
gestion_tienda
datos_tienda
gestion_productos
datos_productos
gestion_ventas
datos_ventas
gestion_clientes
datos_clientes
reportes
*/

