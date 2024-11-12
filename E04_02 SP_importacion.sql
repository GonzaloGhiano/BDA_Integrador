USE Com2900G02;
GO

exec inserts.insertar_catalogo @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_archivos\Productos\catalogo.csv'
GO

exec inserts.insertar_clasificacion @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO

exec inserts.insertar_electronic @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
GO

exec inserts.insertar_importado @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
GO

exec inserts.insertar_sucursal @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO

exec inserts.insertar_empleado @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO

exec inserts.insertar_venta @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\Ventas_registradas.xlsx'
GO

