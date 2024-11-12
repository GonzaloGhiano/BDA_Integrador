/*
	Entrega 3. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script correspondiente a la creación de las funciones utilizadas en los store procedures del sistema.
*/


USE Com2900G02
GO


CREATE OR ALTER FUNCTION gestion_tienda.validar_num_documento (@num_documento char(8))
RETURNS INT
AS
BEGIN
    DECLARE @resultado INT;
	SET @resultado = 1;

    -- Validar si el número de documento está vacío o es NULL
    IF(ISNULL(@num_documento, '') = '')
        SET @resultado = 0;
    -- Validar que el número de documento tenga exactamente 8 dígitos numéricos
    ELSE IF(@num_documento NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
        SET @resultado = 0;;

    RETURN @resultado;
END
GO

CREATE OR ALTER FUNCTION gestion_tienda.validar_tipo_documento (@tipo_documento char(8))
RETURNS INT
AS
BEGIN
    DECLARE @resultado INT;
	SET @resultado = 1;

    -- Validar si el número de documento está vacío o es NULL
    IF(ISNULL(@tipo_documento, '') = '')
        SET @resultado = 0;
    -- Validar que el número de documento tenga exactamente 8 dígitos numéricos
    ELSE IF(@tipo_documento NOT IN('DU','LE','LC','CI'))
        SET @resultado = 0;;

    RETURN @resultado;
END
GO


CREATE OR ALTER FUNCTION gestion_tienda.conversion_USD_a_ARS (@precio DECIMAL(10,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @resultado DECIMAL(10,2);

	IF(NOT EXISTS(SELECT 1 FROM gestion_tienda.Cotizacion_USD))
		SET @resultado = @precio
	ELSE
		SET @resultado = @precio * (
			SELECT TOP 1 valor_dolar
			FROM gestion_tienda.Cotizacion_USD
			ORDER BY fecha DESC
    );

    RETURN @resultado;
END
GO
