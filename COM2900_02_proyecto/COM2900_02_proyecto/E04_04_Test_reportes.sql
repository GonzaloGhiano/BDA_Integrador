/*
	Entrega 4. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	Script realizado para las pruebas de reportes generados.
*/


USE Com2900G02;
GO

SELECT TOP 100 * from gestion_ventas.Factura;
SELECT TOP 100 * from gestion_ventas.Detalle_venta;
SELECT TOP 100 * from gestion_ventas.venta;
GO	

SELECT * FROM gestion_ventas.Medio_de_Pago;

-------------------------------------------------------------------------------------
--				Reporte futuro de ventas
-------------------------------------------------------------------------------------
Exec reportes.reporte_ventas;
GO


-------------------------------------------------------------------------------------
--				Reporte Mensual
--ingresando un mes y año determinado mostrar el total facturado por días de
--la semana, incluyendo sábado y domingo.
-------------------------------------------------------------------------------------
Exec reportes.reporte_ventas_mensual @mes=1, @anio=2019;
GO

-------------------------------------------------------------------------------------
--				Reporte Trimestral
--mostrar el total facturado por turnos de trabajo por mes.
-------------------------------------------------------------------------------------
Exec reportes.reporte_ventas_trimestral
GO


-------------------------------------------------------------------------------------
--				Reporte por rango de fechas
-- ingresando un rango de fechas a demanda, debe poder mostrar
--la cantidad de productos vendidos en ese rango, ordenado de mayor a menor.
--			-> ingresar fechas en formato 'yyyy-mm-dd',
-------------------------------------------------------------------------------------
Exec reportes.reporte_ventas_por_rango_de_fechas '2019-01-01','2019-03-30';
GO

-------------------------------------------------------------------------------------
--			Reporte por rango de fechas y sucursal
--ingresando un rango de fechas a demanda, debe poder mostrar
--la cantidad de productos vendidos en ese rango por sucursal, ordenado de mayor a menor.
--				-> ingresar fechas en formato 'yyyy-mm-dd',
-------------------------------------------------------------------------------------
Exec reportes.reporte_productos_vendidos_rango_sucursal '2019-01-01','2019-03-30';
GO

-------------------------------------------------------------------------------------
--				Reporte por rango de fechas
--5 productos mas vendidos en un mes por semana
-------------------------------------------------------------------------------------
Exec reportes.reporte_top_5_productos_mes_semana @mes=2;
GO

-------------------------------------------------------------------------------------
--				Reporte por rango de fechas
--5 productos menos vendidos en un mes
-------------------------------------------------------------------------------------
Exec reportes.reporte_5_productos_menos_vendidos_por_mes @mes=3;
GO

-------------------------------------------------------------------------------------
--				Reporte por rango de fechas
--Total acumulado de ventas con detalle para una fecha y sucursal
-------------------------------------------------------------------------------------
Exec reportes.reporte_acumulado_ventas_sucursal @fecha='2019-03-16',@nombre_sucursal='Ramos mejía'
GO