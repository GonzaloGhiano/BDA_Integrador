USE Com2900G02
GO


CREATE FUNCTION gestion_tienda.validar_num_documento (@num_documento char(8))
RETURNS INT
AS
BEGIN
    DECLARE @resultado INT;
	SET @resultado = 1;

    -- Validar si el n�mero de documento est� vac�o o es NULL
    IF(ISNULL(@num_documento, '') = '')
        SET @resultado = 0;
    -- Validar que el n�mero de documento tenga exactamente 8 d�gitos num�ricos
    ELSE IF(@num_documento NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
        SET @resultado = 0;;

    RETURN @resultado;
END
GO

CREATE FUNCTION gestion_tienda.validar_tipo_documento (@tipo_documento char(8))
RETURNS INT
AS
BEGIN
    DECLARE @resultado INT;
	SET @resultado = 1;

    -- Validar si el n�mero de documento est� vac�o o es NULL
    IF(ISNULL(@tipo_documento, '') = '')
        SET @resultado = 0;
    -- Validar que el n�mero de documento tenga exactamente 8 d�gitos num�ricos
    ELSE IF(@tipo_documento NOT IN('DU','LE','LC','CI'))
        SET @resultado = 0;;

    RETURN @resultado;
END
GO