/*
	Entrega 5. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a la creacion de los Store Procedure utilizados para los respaldos FULL y
	DIFERENCIAL de la base de datos.
*/


USE Com2900G02;
GO

-----------------------------------------------------------------------------------
-- Creacion del backup FULL de la base
-----------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE CrearRespaldoCompleto
@ruta varchar(max)
AS
BEGIN
    BEGIN TRY
        -- Declarar la consulta dinámica
        DECLARE @sql NVARCHAR(MAX);
        
        -- Construir la consulta dinámica de respaldo
        SET @sql = N'BACKUP DATABASE Com2900G02 ' +
                   N'TO DISK = ''' + @ruta + '\\Com2900G02_Full.bak'' ' +
                   N'WITH FORMAT, INIT, NAME = ''Respaldo Completo'', SKIP, NOREWIND, NOUNLOAD, STATS = 10;';
        
        -- Ejecutar la consulta dinámica
        EXEC sp_executesql @sql;

        PRINT 'Respaldo completo realizado correctamente.';
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        PRINT 'Error al realizar el respaldo completo.';
        THROW;
    END CATCH
END;
GO


-----------------------------------------------------------------------------------
-- Creacion del backup DIFERENCIAL de la base
-----------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE CrearRespaldoDiferencial
@ruta varchar(max)
AS
BEGIN
    BEGIN TRY
        -- Declarar la consulta dinámica
        DECLARE @sql NVARCHAR(MAX);
        
        -- Construir la consulta dinámica de respaldo diferencial
        SET @sql = N'BACKUP DATABASE Com2900G02 ' +
                   N'TO DISK = ''' + @ruta + '\\Com2900G02_Differential.bak'' ' +
                   N'WITH DIFFERENTIAL, INIT, NAME = ''Respaldo Diferencial'', SKIP, NOREWIND, NOUNLOAD, STATS = 10;';
        
        -- Ejecutar la consulta dinámica
        EXEC sp_executesql @sql;

        PRINT 'Respaldo diferencial realizado correctamente.';
    END TRY
    BEGIN CATCH
        -- Manejo de errores
        PRINT 'Error al realizar el respaldo diferencial.';
        THROW;
    END CATCH
END;
GO



/*
No es posible realizar de esta forma el respaldo del log de transacciones
ya que la sesion que lo ejecuta esta utilizando la base de datos
*/
