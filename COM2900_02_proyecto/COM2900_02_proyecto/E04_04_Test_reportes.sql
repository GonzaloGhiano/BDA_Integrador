USE Com2900G02;
GO

SELECT TOP 100 * from gestion_ventas.Detalle_venta;
SELECT TOP 100 * from gestion_ventas.Comprobante_venta;
GO	

Exec reportes.reporte_ventas;
GO