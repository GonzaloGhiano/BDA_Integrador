USE Com2900G02;
GO


EXEC datos_tienda.insertar_sucursal
@nombre = 'Ramos',
@ciudad = 'La Matanza',
@direccion = 'Amancio Alcorta 33',
@horario = '9AM - 11AM',
@telefono = 1111;

SELECT TOP 1 * from gestion_tienda.Sucursal;
GO

EXEC datos_tienda.insertar_puntoDeVenta
@nro_caja = 1,
@ID_sucursal = 1;
SELECT TOP 1 * from gestion_tienda.punto_de_venta;
GO

EXEC datos_productos.insertar_lineaProducto
@linea_prod = 'Prueba LP';
GO
SELECT TOP 3 * from gestion_productos.Linea_Producto;
GO


EXEC datos_productos.insertar_producto
@nombre_Prod = 'Lapiz triple',
@categoria = 'Libreria prueba',
@precio = 100.99,
@cod_linea_prod = 1
GO
SELECT TOP 5 * from gestion_productos.Producto;
GO

EXEC datos_productos.insertar_producto
@nombre_Prod = 'Boligoma especial',
@categoria = 'Libreria prueba',
@precio = 200.50,
@cod_linea_prod = 1
GO
SELECT TOP 5 * from gestion_productos.Producto;
GO

EXEC datos_tienda.insertar_empleado
@legajo = '000001',
@nombre = 'Felipe',
@apellido = 'Probando',
@num_documento = '43440000',
@tipo_documento = 'DU',
@direccion = 'Su casa 123',
@email_personal = 'felipe.com',
@email_empresarial = 'felipe.org',
@CUIL = '23-43440000-7',
@sucursal_id = 1,
@turno = 'TM';
GO
SELECT TOP 5 * from gestion_tienda.Empleado;
GO

EXEC datos_ventas.insertar_medioDePago
@nombre_ES = 'Billuta',
@nombre_EN = 'Cash';
GO
SELECT TOP 3 * from gestion_ventas.Medio_de_Pago;
GO

EXEC datos_ventas.iniciar_comprobanteDeVenta
@ID_punto_venta = 1,
@ID_cliente = null,
@ID_empleado = 1;
GO

select top 3 * from Factura_tmp;

EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 1,
@cantidad = 2;
GO

EXEC datos_ventas.agregarProducto
@ID_punto_venta = 1,
@ID_prod = 2,
@cantidad = 3;
GO

select top 3 * from Detalle_tmp;
GO

EXEC datos_ventas.cerrarVenta
@ID_punto_venta = 1,
@ID_factura = 'ZZB-ACC-AAA',
@tipo_factura = 'A',
@id_medio_pago = 1,
@identificador_pago = '11111';
GO

SELECT TOP 5 * FROM gestion_ventas.Comprobante_venta;
SELECT TOP 20 * FROM gestion_ventas.Detalle_venta;
