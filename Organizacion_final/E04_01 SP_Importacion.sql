USE Com2900G02;
GO


DECLARE @ruta_comp varchar(max) = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\informacion_complementaria.xlsx',
	@ruta_catalogo varchar(max) = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_archivos\Productos\catalogo.csv',
	@ruta_electronicos varchar(max) = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\Productos\Electronic accessories.xlsx',
	@ruta_importados varchar(max) = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\Productos\Productos_importados.xlsx',
	@ruta_ventas varchar(max) ='D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\Ventas_registradas.xlsx'
GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'inserts')
    exec('CREATE SCHEMA inserts');
GO

--Habilitaciones para importar XLSX

sp_configure 'show advanced options', 1;
reconfigure;
GO
sp_configure 'Ad Hoc Distributed Queries', 1; --Habilita las consultas Ad Hoc
reconfigure;
GO

EXEC sp_MSSet_OLEDB_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1; --Habilita el proveedor OLE DB para ejecutarse en el mismo proceso que SQL server, sin esto algunas operaciones podrian verse restringidas por ejecutarse como proceso externo
GO
EXEC sp_MSSet_OLEDB_prop N'Microsoft.ACE.OLEDB.16.0', N'DynamicParameters', 1; --Permite que el proveedor OLE DB acepte parámetros dinámicos en las consultas
GO


-- ARCHIVO INFORMACION COMPLEMENTARIA: CLASIFICACION PRODUCTOS


CREATE TABLE #Clasificacion_temp(
linea varchar(20),
producto varchar(80),
);
GO

CREATE OR ALTER PROCEDURE inserts.insertar_clasificacion
@ruta varchar(200)
AS
BEGIN

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Clasificacion_temp (linea,producto)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [Clasificacion productos$]''
			)';

	exec sp_executesql @cadenaSQL


END
GO


exec inserts.insertar_clasificacion @ruta = @ruta_comp
GO

select * from #Clasificacion_temp


CREATE OR ALTER PROCEDURE inserts.procesar_clasificacion
AS
BEGIN
	
	insert 



END
GO



--ARCHIVO CATALOGO

--Creamos una tabla temporal para procesar los datos
CREATE TABLE #Catalogo_temp(
id varchar(4),
categoria varchar(50),
nombre varchar(100),
precio varchar(80),
precio_referencia varchar(40),
referencia_unidad varchar(20),
fecha varchar(80)
);
GO


CREATE OR ALTER PROCEDURE inserts.insertar_catalogo
@ruta varchar(200)
AS
BEGIN

	declare @cadenaSQL nvarchar(max)	--Utilizamos SQL dinamico para poder recibir la ruta del archivo por parametro
	set @cadenaSQL =

		N'bulk insert #Catalogo_temp
		from ''' + @ruta + '''
		with
		(
			FIELDTERMINATOR = '','',
			ROWTERMINATOR = ''0x0a'',
			DATAFILETYPE = ''char'',
			CODEPAGE = ''65001'',
			FIRSTROW = 2
		)'

	EXEC sp_executesql @CadenaSQL

END
GO

exec inserts.insertar_catalogo @ruta = @ruta_catalogo
GO

truncate table #Catalogo_temp
GO

select *
from #Catalogo_temp
GO

CREATE OR ALTER PROCEDURE inserts.procesar_catalogo
AS
BEGIN
	
	--Eliminamos los datos que tenian comas intermedias en los nombres, verificando en cuales quedaron caracteres no numericos en la columna precio
	Delete from #Catalogo_temp
	where TRY_CAST(precio as decimal(10,2)) is null

	--Eliminamos duplicados
	with CTE(categoria,nombre,ocurrencias) as(
	select categoria,nombre, 
	ROW_NUMBER() over (partition by categoria,nombre order by categoria,nombre) as ocurrencias
	from #Catalogo_temp)
	delete from CTE
	where ocurrencias > 1



END
GO

-- ARCHIVO ELECTRONICS

CREATE TABLE #Electronic_temp(
producto varchar(50),
precio_dolares varchar(20),
);
GO


CREATE OR ALTER PROCEDURE inserts.insertar_electronic
@ruta varchar(200)
AS
BEGIN

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Electronic_temp (producto,precio_dolares)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [Sheet1$]''
			)';

	exec sp_executesql @cadenaSQL


END
GO

exec inserts.insertar_electronic @ruta = @ruta_electronicos
GO

select * from #Electronic_temp

CREATE OR ALTER PROCEDURE inserts.procesar_electronic
AS
BEGIN

	--Eliminamos duplicados
	with CTE(producto,ocurrencias) as(
	select producto, 
	ROW_NUMBER() over (partition by producto order by producto) as ocurrencias
	from #Electronic_temp)
	delete from CTE
	where ocurrencias > 1


END
GO

-- ARCHIVO IMPORTADOS

CREATE TABLE #Importado_temp(
ID_producto varchar(2),
nombre_producto varchar(40),
proveedor varchar(40),
categoria varchar(20),
cantidad_unidad varchar(40),
precio_unidad varchar(40)
);
GO

CREATE OR ALTER PROCEDURE inserts.insertar_importado
@ruta varchar(200)
AS
BEGIN

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Importado_temp (ID_producto, nombre_producto,proveedor,categoria,cantidad_unidad,precio_unidad)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [Listado de Productos$]''
			)';

	exec sp_executesql @cadenaSQL


END
GO

exec inserts.insertar_importado @ruta = @ruta_importados
GO

select * from #Importado_temp

CREATE OR ALTER PROCEDURE inserts.procesar_importado
AS
BEGIN

	--Eliminamos duplicados
	with CTE(nombre_producto,proveedor,ocurrencias) as(
	select nombre_producto,proveedor,
	ROW_NUMBER() over (partition by nombre_producto,proveedor order by nombre_producto,proveedor) as ocurrencias
	from #Importado_temp)
	delete from CTE
	where ocurrencias > 1


END
GO

-- ARCHIVO INFORMACION COMPLEMENTARIA: EMPLEADOS

CREATE TABLE #Empleado_temp(
legajo varchar(6),
nombre varchar(40),
apellido varchar(40),
dni varchar(8),
dni_inicial float,
direccion varchar(100),
email_personal varchar(80),
email_empresa varchar(80),
CUIL varchar(10),
cargo varchar(20),
sucursal varchar(30),
turno varchar(20)
);
GO

CREATE OR ALTER PROCEDURE inserts.insertar_empleado
@ruta varchar(200)
AS
BEGIN

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Empleado_temp (legajo,nombre,apellido,dni_inicial,direccion,email_personal,email_empresa,CUIL,cargo,sucursal,turno)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [Empleados$]''
			)';

	exec sp_executesql @cadenaSQL


END
GO

exec inserts.insertar_empleado @ruta = @ruta_comp
GO

select * from #Empleado_temp

update #Empleado_temp
set dni = cast((convert(int,dni_inicial)) as varchar(8))


-- ARCHIVO INFORMACION COMPLEMENTARIA: SUCURSAL


CREATE TABLE #Sucursal_temp(
ciudad varchar(20),
reemplazo varchar(20),
direccion varchar(100),
horario varchar(60),
telefono varchar(20)
);
GO


CREATE OR ALTER PROCEDURE inserts.insertar_sucursal
@ruta varchar(200)
AS
BEGIN

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Sucursal_temp (ciudad,reemplazo,direccion,horario,telefono)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [sucursal$]''
			)';

	exec sp_executesql @cadenaSQL


END
GO


exec inserts.insertar_sucursal @ruta = @ruta_comp
GO

select * from #Sucursal_temp
GO


-- ARCHIVO VENTAS

drop table #Venta_temp

CREATE TABLE #Venta_temp(
ID_factura varchar(15),
tipo_factura varchar(1),
ciudad varchar(20),
tipo_cliente varchar(6),
genero varchar(6),
producto varchar(100),
precio varchar(20),
cantidad varchar(5),
fecha varchar(20),
hora varchar(10),
medio_pago varchar(20),
empleado varchar(6),
id_pago varchar(40)
);
GO

CREATE OR ALTER PROCEDURE inserts.insertar_venta
@ruta varchar(200)
AS
BEGIN

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Venta_temp (ID_factura,tipo_factura,ciudad,tipo_cliente,genero,producto,precio,cantidad,fecha,hora,medio_pago,empleado,id_pago)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [Ventas_registradas$]''
			)';

	exec sp_executesql @cadenaSQL


END
GO


exec inserts.insertar_venta @ruta = @ruta_ventas
GO

select * from #Venta_temp
GO