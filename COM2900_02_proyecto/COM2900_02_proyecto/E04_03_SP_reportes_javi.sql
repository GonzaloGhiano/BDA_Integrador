/*
	Entrega 4. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
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
		f.ID_factura AS [ID Factura],
		f.tipo_factura AS [Tipo de Factura],
		su.ciudad AS [Ciudad],
		--c.tipo_cliente AS [Tipo de cliente],
		--c.genero AS [Genero],
		lp.linea_prod AS [Linea de producto],
		p.nombre_Prod AS [Producto],
		p.precio AS [Precio Unitario],
		dv.cantidad AS [Cantidad],
		FORMAT(f.fecha_hora_emision, 'dd/MM/yyyy') AS [Fecha],
		FORMAT(f.fecha_hora_emision, 'HH:mm') AS [Hora],
		mp.nombre_ES AS [Medio de Pago],
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
	JOIN 
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
    @Anio int    --ingreso parametro año
AS
BEGIN
	SET Language 'Spanish';

    SELECT 
        DATENAME(WEEKDAY, f.fecha_hora_emision) AS [Día de la Semana], --nombre del día
        SUM(f.total_neto_sinIVA + f.IVA) AS [Total Facturado]         --sumo las ventas junto al IVA
    FROM 
        gestion_ventas.Factura f
    WHERE 
        MONTH(f.fecha_hora_emision) = @Mes   --filtro por el mes
        AND YEAR(f.fecha_hora_emision) = @Anio --filtro por el año
    GROUP BY 
        DATENAME(WEEKDAY, f.fecha_hora_emision) --agrupo por días de la semana
    ORDER BY 
        CASE DATENAME(WEEKDAY, f.fecha_hora_emision) --ordeno de lunes a domingo
            WHEN 'Lunes' THEN 1
            WHEN 'Martes' THEN 2
            WHEN 'Miércoles' THEN 3
            WHEN 'Jueves' THEN 4
            WHEN 'Viernes' THEN 5
            WHEN 'Sábado' THEN 6
            WHEN 'Domingo' THEN 7
        END;
END;
GO

--Trimestral
CREATE or ALTER PROCEDURE reportes.reporte_ventas_trimestral
AS
BEGIN
    SELECT 
        e.turno AS [Turno de Trabajo],
		cast(month(f.fecha_hora_emision) as INT) AS [Mes],
        SUM(f.total_neto_sinIVA + f.IVA) AS [Total Facturado]
    FROM 
        gestion_ventas.Factura f
        INNER JOIN gestion_ventas.Venta v ON f.ID_factura = v.ID_factura
        INNER JOIN gestion_tienda.Empleado e ON v.ID_empleado = e.ID_empleado
    GROUP BY 
        e.turno, 
		cast(month(f.fecha_hora_emision) as INT)
    ORDER BY 
        e.turno;
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
        SUM(dv.cantidad) AS [Cantidad Vendida]
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
        [Cantidad Vendida] DESC;
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
        SUM(dv.cantidad) AS [Cantidad Vendida]
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
        [Cantidad Vendida] DESC;
END;
GO


--5 productos mas vendidos en un mes por semana
CREATE or ALTER PROCEDURE reportes.reporte_top_5_productos_mes_semana
    @Mes INT  -- Parámetro para el mes
AS
BEGIN
    SET Language 'Spanish';

	SELECT TOP 5
        p.nombre_Prod AS [Producto],
        DATEDIFF(WEEK, DATEFROMPARTS(YEAR(f.fecha_hora_emision), MONTH(f.fecha_hora_emision), 1), f.fecha_hora_emision) + 1 AS [Semana],
        SUM(dv.cantidad) AS [Cantidad Vendida]
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
        [Cantidad Vendida] DESC;
END;
GO


--5 productos menos vendidos del mes por semana
CREATE or ALTER PROCEDURE reportes.reporte_5_productos_menos_vendidos_por_mes
    @Mes int
AS
BEGIN
    SELECT TOP 5
        p.nombre_Prod AS [Producto],
        SUM(dv.cantidad) AS [Cantidad Vendida]
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
        [Cantidad Vendida] ASC;
END;
GO

--Total acumulado de ventas con detalle para una fecha y sucursal
CREATE or ALTER PROCEDURE reportes.reporte_acumulado_ventas_sucursal
    @Fecha date,
    @nombre_sucursal varchar(30)
AS
BEGIN
    SELECT
        s.nombre_sucursal AS [Sucursal],
        FORMAT(v.fecha, 'dd/MM/yyyy') AS [Fecha],
        SUM(dv.cantidad) AS [Cantidad Vendida], --Total de productos vendidos
        SUM(dv.cantidad * p.precio) AS [Total Subtotal], --Subtotal sin IVA
        SUM((dv.cantidad * p.precio) + ((dv.cantidad * p.precio) * (f.IVA / 100))) AS [Total Acumulado] --Acumulado general con IVA
    FROM 
        gestion_ventas.Venta v
        INNER JOIN gestion_ventas.Detalle_venta dv ON v.ID_venta = dv.ID_venta
        INNER JOIN gestion_ventas.Factura f ON v.ID_factura = f.ID_factura
        INNER JOIN gestion_tienda.Sucursal s ON v.ID_punto_venta = s.ID_sucursal
        INNER JOIN gestion_productos.Producto p ON dv.ID_prod = p.ID_prod
    WHERE 
        v.fecha = @Fecha
        AND s.nombre_sucursal = @nombre_sucursal
    GROUP BY 
        s.nombre_sucursal, 
        v.fecha
END;
GO
