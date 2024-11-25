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

--Funcion de validar el formato de DNI
CREATE OR ALTER FUNCTION gestion_tienda.validar_num_documento (@num_documento INT)
RETURNS INT
AS
BEGIN
    DECLARE @resultado INT;
    SET @resultado = 1;

    -- Validar si el número de documento está vacío, es NULL o negativo
    IF(ISNULL(@num_documento, 0) = 0 OR @num_documento < 0)
        SET @resultado = 0;

    RETURN @resultado;
END
GO

--Funcion de validar el tipo documento
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


--Funcion para la conversion de USD a ARS
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

CREATE OR ALTER FUNCTION gestion_tienda.obtener_precioARS (@ID_prod int)
RETURNS DECIMAL(10,2)
AS
BEGIN
	DECLARE @resultado DECIMAL(10,2),
			@precioUnitario DECIMAL(10,2) = 0;

	--Si no existe el producto, devuelvo 0
	IF(NOT EXISTS(SELECT 1 FROM gestion_productos.Producto p 
					where p.ID_prod = @ID_prod))
		SET @precioUnitario = 0;
	ELSE SET @precioUnitario = (select precio from gestion_productos.Producto p where p.ID_prod = @ID_prod)

	--Si no hay cotizacion, no haga nada
	IF(NOT EXISTS(SELECT 1 FROM gestion_tienda.Cotizacion_USD))
		SET @resultado = @precioUnitario
	ELSE
	BEGIN
		--Si esta en dolares, lo paso a pesos
		IF(EXISTS(SELECT 1 FROM gestion_productos.Producto p 
					where p.ID_prod = @ID_prod AND p.moneda = 'USD'))
		BEGIN
			SET @resultado = @precioUnitario * (
			SELECT TOP 1 valor_dolar
			FROM gestion_tienda.Cotizacion_USD
			ORDER BY fecha DESC
			);
		END
		ELSE --Si no estaba en dolares, lo dejo en pesos
			SET @resultado = @precioUnitario
	END

	RETURN @resultado;
END
GO



CREATE OR ALTER FUNCTION gestion_tienda.obtenerCUIL (
    @ID_cliente INT -- Se define un nombre para el parámetro
)
RETURNS CHAR(13) -- Se especifica el tipo de dato de retorno
AS
BEGIN
    DECLARE @CUIL CHAR(13);

	 IF @ID_cliente IS NULL
    BEGIN
        RETURN '20-22222222-3'; -- Devolver NULL si el parámetro es nulo
    END;

	IF(NOT EXISTS(SELECT 1 FROM gestion_clientes.Cliente cli
    WHERE ID_cliente = @ID_cliente))
	BEGIN
        RETURN '20-22222222-3'; -- Devolver NULL si el parámetro es nulo
    END;

    -- Aquí iría la lógica para obtener el CUIL, por ejemplo:
    SELECT @CUIL = cli.CUIL
    FROM gestion_clientes.Cliente cli
    WHERE ID_cliente = @ID_cliente;

    RETURN @CUIL; -- Se devuelve el valor calculado
END;
GO
