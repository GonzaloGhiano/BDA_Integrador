/*
	Entrega 4. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agust�n 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisi�n: 01-2900
	Fecha de entrega: 12/11/2024

	Script a la creacion de SPs para realizar los reportes de ventas.
*/

USE Com2900G02;
GO

--Reporte futuro
--Error, tenemos cargados a los clientes como ID_Cliente = NULL, no puedo traer datos, dejo comentado datos cliente para probar consulta
CREATE or ALTER PROCEDURE reportes.reporte_ventas
AS
BEGIN
	SELECT 
		f.ID_factura AS [ID_Factura],
		f.tipo_factura AS [Tipo_de_Factura],
		su.ciudad AS [Ciudad],
		c.tipo_cliente AS [Tipo de cliente],
		c.genero AS [Genero],
		lp.linea_prod AS [Linea_de_producto],
		p.nombre_Prod AS [Producto],
		p.precio AS [Precio_Unitario],
		dv.cantidad AS [Cantidad],
		FORMAT(f.fecha_hora_emision, 'dd/MM/yyyy') AS [Fecha],
		FORMAT(f.fecha_hora_emision, 'HH:mm') AS [Hora],
		mp.nombre_ES AS [Medio_de_Pago],
		e.legajo AS [Empleado],
		su.nombre_sucursal AS [Sucursal]
	FROM 
		gestion_ventas.Factura f
	JOIN 
		gestion_ventas.Venta v ON f.ID_factura = v.ID_factura
	JOIN 
		gestion_tienda.punto_de_venta pv ON v.ID_punto_venta = pv.ID_punto_venta
	JOIN 
		gestion_tienda.Sucursal su ON pv.ID_sucursal = su.ID_sucursal
	LEFT JOIN 
		gestion_clientes.Cliente c ON v.ID_cliente = c.ID_cliente
	JOIN 
		gestion_ventas.Detalle_venta dv ON v.ID_venta = dv.ID_venta
	JOIN 
		gestion_productos.Producto p ON dv.ID_prod = p.ID_prod
	JOIN 
		gestion_productos.Linea_Producto lp ON p.cod_linea_prod = lp.ID_lineaprod
	JOIN 
		gestion_ventas.Medio_de_Pago mp ON v.id_medio_pago = mp.ID_MP
	JOIN 
		gestion_tienda.Empleado e ON v.ID_empleado = e.ID_empleado
END;
GO


--Mensual
CREATE or ALTER PROCEDURE reportes.reporte_ventas_mensual
    @Mes int,    --ingreso parametro mes
    @Anio int    --ingreso parametro a�o
AS
BEGIN
	SET Language 'Spanish';

    SELECT 
        DATENAME(WEEKDAY, f.fecha_hora_emision) AS [D�a_de_la_Semana], --nombre del d�a
        SUM(f.total_neto_sinIVA + f.IVA) AS [Total_Facturado]         --sumo las ventas junto al IVA
    FROM 
        gestion_ventas.Factura f
    WHERE 
        MONTH(f.fecha_hora_emision) = @Mes   --filtro por el mes
        AND YEAR(f.fecha_hora_emision) = @Anio --filtro por el a�o
    GROUP BY 
        DATENAME(WEEKDAY, f.fecha_hora_emision) --agrupo por d�as de la semana
    ORDER BY 
        CASE DATENAME(WEEKDAY, f.fecha_hora_emision) --ordeno de lunes a domingo
            WHEN 'Lunes' THEN 1
            WHEN 'Martes' THEN 2
            WHEN 'Mi�rcoles' THEN 3
            WHEN 'Jueves' THEN 4
            WHEN 'Viernes' THEN 5
            WHEN 'S�bado' THEN 6
            WHEN 'Domingo' THEN 7
        END
    FOR XML AUTO, ELEMENTS;
END;
GO

--Trimestral
CREATE or ALTER PROCEDURE reportes.reporte_ventas_trimestral
AS
BEGIN
    SELECT 
        e.turno AS [Turno_de_Trabajo],
		cast(month(f.fecha_hora_emision) as INT) AS [Mes],
        SUM(f.total_neto_sinIVA + f.IVA) AS [Total_Facturado]
    FROM 
        gestion_ventas.Factura f
        INNER JOIN gestion_ventas.Venta v ON f.ID_factura = v.ID_factura
        INNER JOIN gestion_tienda.Empleado e ON v.ID_empleado = e.ID_empleado
    GROUP BY 
        e.turno, 
		cast(month(f.fecha_hora_emision) as INT)
    ORDER BY 
        e.turno
    FOR XML AUTO, ELEMENTS;
END;
GO

CREATE OR ALTER PROCEDURE reportes.reporte_ventas_trimestral
AS
BEGIN
    SELECT 
        e.turno AS [Turno_de_Trabajo],
        DATEPART(QUARTER, f.fecha_hora_emision) AS [TRIMESTRE], --Dividimos por trimestre y lo mostramos
        YEAR(f.fecha_hora_emision) AS [Anio],
        SUM(f.total_neto_sinIVA + f.IVA) AS [Total_Facturado]
    FROM 
        gestion_ventas.Factura f
        INNER JOIN gestion_ventas.Venta v ON f.ID_factura = v.ID_factura
        INNER JOIN gestion_tienda.Empleado e ON v.ID_empleado = e.ID_empleado
    GROUP BY 
        e.turno,
        DATEPART(QUARTER, f.fecha_hora_emision), -- Agrupa por trimestre
        YEAR(f.fecha_hora_emision) -- Agrupa tambi�n por a�o para evitar mezclar datos de diferentes a�os
    ORDER BY 
        YEAR(f.fecha_hora_emision),
        [TRIMESTRE],
        e.turno
    FOR XML AUTO, ELEMENTS;
END;
GO

--Rango de fechas
CREATE or ALTER PROCEDURE reportes.reporte_ventas_por_rango_de_fechas
    @FechaInicio date,-- Fecha inicio
    @FechaFin date-- Fecha fin
AS
BEGIN
    SELECT 
        p.nombre_Prod AS [Producto],
        SUM(dv.cantidad) AS [Cantidad_Vendida]
    FROM 
        gestion_ventas.Detalle_venta dv
        INNER JOIN gestion_productos.Producto p ON dv.ID_prod = p.ID_prod
        INNER JOIN gestion_ventas.Venta v ON dv.ID_venta = v.ID_venta
        INNER JOIN gestion_ventas.Factura f ON v.ID_factura = f.ID_factura
    WHERE 
        f.fecha_hora_emision BETWEEN @FechaInicio AND @FechaFin
    GROUP BY 
        p.nombre_Prod
    ORDER BY 
        [Cantidad_Vendida] DESC
    FOR XML AUTO, ELEMENTS;
END;
GO

--Rango de fechas y sucursal
CREATE or ALTER PROCEDURE reportes.reporte_productos_vendidos_rango_sucursal
    @FechaInicio date,--fecha inicio
    @FechaFin date--fecha fin
AS
BEGIN
    SELECT 
        s.nombre_sucursal AS [Sucursal],
        SUM(dv.cantidad) AS [Cantidad_Vendida]
    FROM 
        gestion_ventas.Detalle_venta dv
        INNER JOIN gestion_ventas.Venta v ON dv.ID_venta = v.ID_venta
        INNER JOIN gestion_tienda.punto_de_venta pv ON v.ID_punto_venta = pv.ID_punto_venta
        INNER JOIN gestion_tienda.Sucursal s ON pv.ID_sucursal = s.ID_sucursal
        INNER JOIN gestion_ventas.Factura f ON v.ID_factura = f.ID_factura
    WHERE 
        f.fecha_hora_emision BETWEEN @FechaInicio AND @FechaFin
    GROUP BY 
        s.nombre_sucursal
    ORDER BY 
        [Cantidad_Vendida] DESC
    FOR XML AUTO, ELEMENTS;
END;
GO


--5 productos mas vendidos en un mes por semana
CREATE or ALTER PROCEDURE reportes.reporte_top_5_productos_mes_semana
    @Mes INT  -- Par�metro para el mes
AS
BEGIN
    SET Language 'Spanish';

	SELECT TOP 5
        p.nombre_Prod AS [Producto],
        DATEDIFF(WEEK, DATEFROMPARTS(YEAR(f.fecha_hora_emision), MONTH(f.fecha_hora_emision), 1), f.fecha_hora_emision) + 1 AS [Semana],
        SUM(dv.cantidad) AS [Cantidad_Vendida]
    FROM 
        gestion_ventas.Detalle_venta dv
        INNER JOIN gestion_productos.Producto p ON dv.ID_prod = p.ID_prod
        INNER JOIN gestion_ventas.Venta v ON dv.ID_venta = v.ID_venta
        INNER JOIN gestion_ventas.Factura f ON v.ID_factura = f.ID_factura
    WHERE 
        MONTH(f.fecha_hora_emision) = @Mes
    GROUP BY 
        p.nombre_Prod, 
        DATEDIFF(WEEK, DATEFROMPARTS(YEAR(f.fecha_hora_emision), MONTH(f.fecha_hora_emision), 1), f.fecha_hora_emision) + 1
    ORDER BY 
        [Cantidad_Vendida] DESC
    FOR XML AUTO, ELEMENTS;
END;
GO


--5 productos menos vendidos del mes por semana
CREATE or ALTER PROCEDURE reportes.reporte_5_productos_menos_vendidos_por_mes
    @Mes int
AS
BEGIN
    SELECT TOP 5
        p.nombre_Prod AS [Producto],
        SUM(dv.cantidad) AS [Cantidad_Vendida]
    FROM 
        gestion_ventas.Detalle_venta dv
        INNER JOIN gestion_productos.Producto p ON dv.ID_prod = p.ID_prod
        INNER JOIN gestion_ventas.Venta v ON dv.ID_venta = v.ID_venta
        INNER JOIN gestion_ventas.Factura f ON v.ID_factura = f.ID_factura
    WHERE 
        MONTH(f.fecha_hora_emision) = @Mes
    GROUP BY 
        p.nombre_Prod
    ORDER BY 
        [Cantidad_Vendida] ASC
    FOR XML AUTO, ELEMENTS;
END;
GO

--Total acumulado de ventas con detalle para una fecha y sucursal
CREATE OR ALTER PROCEDURE reportes.reporte_acumulado_ventas_sucursal
    @Fecha DATE,
    @nombre_sucursal VARCHAR(30)
AS
BEGIN
    SELECT
        s.nombre_sucursal AS [Sucursal],
        FORMAT(v.fecha, 'dd/MM/yyyy') AS [Fecha],
        f.total_neto_sinIVA + f.IVA AS [Total], -- Total de la fila con IVA
        SUM(f.total_neto_sinIVA + f.IVA) 
            OVER (PARTITION BY s.ID_sucursal, v.fecha ORDER BY v.ID_venta) AS [Total_Acumulado] -- Total acumulado
    FROM 
        gestion_ventas.Venta v
        INNER JOIN gestion_ventas.Detalle_venta dv ON v.ID_venta = dv.ID_venta
        INNER JOIN gestion_ventas.Factura f ON v.ID_factura = f.ID_factura
        INNER JOIN gestion_tienda.Sucursal s ON v.ID_punto_venta = s.ID_sucursal
        INNER JOIN gestion_productos.Producto p ON dv.ID_prod = p.ID_prod
    WHERE 
        v.fecha = @Fecha
        AND s.nombre_sucursal = @nombre_sucursal
    ORDER BY 
        [Total_Acumulado] desc -- Ordenar por venta y detalle
    FOR XML AUTO, ELEMENTS;
END;
GO
