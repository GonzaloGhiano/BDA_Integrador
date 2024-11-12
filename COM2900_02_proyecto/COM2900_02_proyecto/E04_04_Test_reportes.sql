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

SELECT TOP 100 * from gestion_ventas.Detalle_venta;
SELECT TOP 100 * from gestion_ventas.Comprobante_venta;
GO	

Exec reportes.reporte_ventas;
GO