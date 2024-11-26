/*
	Entrega 5. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a la creación de usuarios de prueba para los distintos roles de la base de datos
*/



-------------------------------------------------------------------------------------------
-- Prueba de creación de cajero "Felipe"
-------------------------------------------------------------------------------------------

-- Crear login Felipe solo si no existe
USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Felipe')
BEGIN
    CREATE LOGIN Felipe
    WITH PASSWORD = 'MyPassword', DEFAULT_DATABASE = Com2900G02,
    CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
    PRINT 'Login Felipe creado.';
END
GO


USE Com2900G02;
GO
-- Crear usuario Felipe solo si no existe
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Felipe' AND type = 'S')
BEGIN
    CREATE USER Felipe FOR LOGIN Felipe;
    PRINT 'Usuario Felipe creado.';
END
GO

-- Agregar a Felipe al rol cajeros solo si no es miembro
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals u ON drm.member_principal_id = u.principal_id
    WHERE r.name = 'cajeros' AND u.name = 'Felipe'
)
BEGIN
    ALTER ROLE cajeros ADD MEMBER Felipe;
    PRINT 'Usuario Felipe añadido al rol cajeros.';
END
GO

-------------------------------------------------------------------------------------------
-- Prueba de creación de supervisor "Gonzalo"
-------------------------------------------------------------------------------------------

USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Gonzalo')
BEGIN
    CREATE LOGIN Gonzalo
    WITH PASSWORD = 'MyPassword', DEFAULT_DATABASE = Com2900G02,
    CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
    PRINT 'Login Gonzalo creado.';
END
GO


USE Com2900G02;
GO
-- Crear usuario Gonzalo solo si no existe
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Gonzalo' AND type = 'S')
BEGIN
    CREATE USER Gonzalo FOR LOGIN Gonzalo;
    PRINT 'Usuario Gonzalo creado.';
END
GO

-- Agregar usuario Gonzalo al rol supervisores solo si no es miembro
IF NOT EXISTS (
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals u ON drm.member_principal_id = u.principal_id
    WHERE r.name = 'supervisores' AND u.name = 'Gonzalo'
)
BEGIN
    ALTER ROLE supervisores ADD MEMBER Gonzalo;
    PRINT 'Usuario Gonzalo añadido al rol supervisores.';
END
GO


-------------------------------------------------------------------------------------------
-- Usuario SYSADMIN encargado de la importación de archivos
-------------------------------------------------------------------------------------------

SELECT sp.name AS LoginName, spr.name AS RoleName
FROM sys.server_principals sp
JOIN sys.server_role_members srm ON sp.principal_id = srm.member_principal_id
JOIN sys.server_principals spr ON spr.principal_id = srm.role_principal_id
WHERE spr.name = 'sysadmin';

