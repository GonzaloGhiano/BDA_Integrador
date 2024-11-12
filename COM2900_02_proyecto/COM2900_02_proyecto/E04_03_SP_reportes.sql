USE Com2900G02;
GO

CREATE or ALTER PROCEDURE reportes.reporte_ventas
AS
BEGIN
	SELECT 
		cv.ID_factura AS "ID Factura",
		cv.tipo_factura AS "Tipo de Factura",
		s.ciudad AS "Ciudad",
		c.tipo_cliente AS "Tipo de Cliente",
		c.genero AS "Género",
		lp.linea_prod AS "Línea de Producto",
		p.nombre_Prod AS "Producto",
		p.precio AS "Precio Unitario",
		dv.cantidad AS "Cantidad",
		cv.fecha AS "Fecha",
		cv.hora AS "Hora",
		mp.nombre_ES AS "Medio de Pago",
		e.legajo AS "Empleado",
		s.nombre_sucursal AS "Sucursal"
	FROM 
		gestion_ventas.Comprobante_venta cv
JOIN 
    gestion_tienda.punto_de_venta pv ON cv.ID_punto_venta = pv.ID_punto_venta
JOIN 
    gestion_tienda.Sucursal s ON pv.ID_sucursal = s.ID_sucursal
JOIN 
    gestion_clientes.Cliente c ON cv.ID_cliente = c.ID_cliente
JOIN 
    gestion_ventas.Detalle_venta dv ON cv.ID_venta = dv.ID_venta
JOIN 
    gestion_productos.Producto p ON dv.ID_prod = p.ID_prod
JOIN 
    gestion_productos.Linea_Producto lp ON p.cod_linea_prod = lp.ID_lineaprod
JOIN 
    gestion_ventas.Medio_de_Pago mp ON cv.id_medio_pago = mp.ID_MP
JOIN 
    gestion_tienda.Empleado e ON cv.ID_empleado = e.ID_empleado
ORDER BY 
    cv.fecha, cv.hora;
END