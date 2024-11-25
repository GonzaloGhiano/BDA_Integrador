USE Com2900G02;
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


--ARCHIVO CATALOGO


CREATE OR ALTER PROCEDURE inserts.insertar_catalogo
@ruta varchar(200)
AS
BEGIN

	IF OBJECT_ID('tempdb..#Catalogo_temp') IS NULL
	BEGIN
		CREATE TABLE #Catalogo_temp(
		id varchar(4),
		categoria varchar(50),
		nombre varchar(100),
		precio varchar(80),
		precio_referencia varchar(40),
		referencia_unidad varchar(20),
		fecha varchar(80)
		);
	END

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

	--Eliminamos los datos que tenian comas intermedias en los nombres, verificando en cuales quedaron caracteres no numericos en la columna precio
	Delete from #Catalogo_temp
	where TRY_CAST(precio as decimal(10,2)) is null;

	--Eliminamos duplicados
	with CTE(categoria,nombre,ocurrencias) as(
	select categoria,nombre, 
	ROW_NUMBER() over (partition by categoria,nombre order by categoria,nombre) as ocurrencias
	from #Catalogo_temp)
	delete from CTE
	where ocurrencias > 1;

	INSERT INTO gestion_productos.Producto (nombre_Prod, categoria, precio, referencia_precio, referencia_unidad)
	SELECT nombre, categoria, precio, precio_referencia, referencia_unidad
	FROM #Catalogo_temp ct
	WHERE ct.nombre COLLATE Modern_Spanish_CI_AI NOT IN 
    (SELECT nombre_prod FROM gestion_productos.Producto);

	drop table #Catalogo_temp;

END
GO

exec inserts.insertar_catalogo @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_archivos\Productos\catalogo.csv'
GO



-- ARCHIVO INFORMACION COMPLEMENTARIA: CLASIFICACION PRODUCTOS



CREATE OR ALTER PROCEDURE inserts.insertar_clasificacion
@ruta varchar(200)
AS
BEGIN

	IF OBJECT_ID('tempdb..#Clasificacion_temp') IS NULL
	BEGIN
		CREATE TABLE #Clasificacion_temp(
		linea varchar(20),
		producto varchar(80),
		);
	END

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Clasificacion_temp (linea,producto)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [Clasificacion productos$]''
			)';

	exec sp_executesql @cadenaSQL;

	insert gestion_productos.Linea_Producto (linea_prod)
	select linea
	from #Clasificacion_temp ct
	WHERE ct.linea COLLATE Modern_Spanish_CI_AI NOT IN 
    (SELECT linea_prod FROM gestion_productos.Linea_Producto);


	--Eliminamos duplicados
	with CTE(linea_prod,ocurrencias) as(
	select linea_prod, 
	ROW_NUMBER() over (partition by linea_prod order by linea_prod) as ocurrencias
	from gestion_productos.Linea_Producto)
	delete from CTE
	where ocurrencias > 1;


	update p
	set p.cod_linea_prod = l.ID_lineaprod
	from #Clasificacion_temp c join gestion_productos.Producto p on c.producto = p.categoria collate Modern_Spanish_CI_AI
		join gestion_productos.Linea_Producto l on c.linea = l.linea_prod collate Modern_Spanish_CI_AI
	where p.cod_linea_prod is NULL;

	drop table #Clasificacion_temp;

END
GO


exec inserts.insertar_clasificacion @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO


--Medios pago

CREATE OR ALTER PROCEDURE inserts.insertar_medioPago
@ruta varchar(200)
AS
BEGIN

	IF OBJECT_ID('tempdb..#Medio_pago_temp') IS NULL
	BEGIN
		CREATE TABLE #Medio_pago_temp(
		extra varchar(40),
		nombre_ES varchar(21),
		nombre_EN varchar(80),
		);
	END

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Medio_pago_temp (extra,nombre_EN,nombre_ES)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=NO;Database=' + @ruta + ''',
			''select * from [medios de pago$]''
			)';

	exec sp_executesql @cadenaSQL;

	alter table #Medio_pago_temp
	drop column extra

	delete #Medio_pago_temp
	where nombre_ES is null

	update #Medio_pago_temp    --ACORDARSE AGREGARLE UN CHAR MAS A NOMBRE_ES EN LA TABLA
	set nombre_ES = 'Billetera Electronic'
	where nombre_ES = 'Billetera Electronica'

	insert gestion_ventas.Medio_de_Pago (nombre_ES,nombre_EN)
	select nombre_ES,nombre_EN
	from #Medio_pago_temp mp
	WHERE mp.nombre_ES COLLATE Modern_Spanish_CI_AI NOT IN 
    (SELECT nombre_ES FROM gestion_ventas.Medio_de_Pago);


END
GO

exec inserts.insertar_medioPago @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO


-- ARCHIVO ELECTRONICS




CREATE OR ALTER PROCEDURE inserts.insertar_electronic
@ruta varchar(200)
AS
BEGIN

	IF OBJECT_ID('tempdb..#Electronic_temp') IS NULL
	BEGIN
		CREATE TABLE #Electronic_temp(
		producto varchar(50),
		precio_dolares varchar(20),
		);
	END

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Electronic_temp (producto,precio_dolares)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [Sheet1$]''
			)';

	exec sp_executesql @cadenaSQL;

	--Eliminamos duplicados
	with CTE(producto,ocurrencias) as(
	select producto, 
	ROW_NUMBER() over (partition by producto order by producto) as ocurrencias
	from #Electronic_temp)
	delete from CTE
	where ocurrencias > 1;


	INSERT INTO gestion_productos.Producto (nombre_Prod, categoria, precio)
	SELECT producto, 'Electronico' as categoria, precio_dolares
	FROM #Electronic_temp et
	WHERE et.producto COLLATE Modern_Spanish_CI_AI NOT IN 
    (SELECT nombre_prod FROM gestion_productos.Producto);

END
GO

exec inserts.insertar_electronic @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\Productos\Electronic accessories.xlsx'
GO


-- ARCHIVO IMPORTADOS



CREATE OR ALTER PROCEDURE inserts.insertar_importado
@ruta varchar(200)
AS
BEGIN

	IF OBJECT_ID('tempdb..#Importado_temp') IS NULL
	BEGIN
		CREATE TABLE #Importado_temp(
		ID_producto varchar(2),
		nombre_producto varchar(40),
		proveedor varchar(40),
		categoria varchar(20),
		cantidad_unidad varchar(40),
		precio_unidad varchar(40)
		);
	END

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Importado_temp (ID_producto, nombre_producto,proveedor,categoria,cantidad_unidad,precio_unidad)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [Listado de Productos$]''
			)';

	exec sp_executesql @cadenaSQL;


	insert gestion_productos.Producto (nombre_Prod,categoria, precio)
	select nombre_producto,categoria, precio_unidad
	from #Importado_temp it
	where it.nombre_producto COLLATE Modern_Spanish_CI_AI NOT IN 
    (select nombre_prod from gestion_productos.Producto);

	--Agregamos la linea de producto
	update p
	set p.cod_linea_prod = l.ID_lineaprod
	from gestion_productos.Producto p join gestion_productos.Linea_Producto l on p.categoria = l.linea_prod COLLATE Modern_Spanish_CI_AI
	where p.cod_linea_prod is NULL;

	drop table #Importado_temp

END
GO

exec inserts.insertar_importado @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\Productos\Productos_importados.xlsx'
GO


-- ARCHIVO INFORMACION COMPLEMENTARIA: SUCURSAL



CREATE OR ALTER PROCEDURE inserts.insertar_sucursal
@ruta varchar(200)
AS
BEGIN
	
	IF OBJECT_ID('tempdb..#Sucursal_temp') IS NULL
	BEGIN
		CREATE TABLE #Sucursal_temp(
		ciudad varchar(20),
		reemplazo varchar(20),
		direccion varchar(100),
		horario varchar(60),
		telefono varchar(20),
		telefono_int int
		);
	END


	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'insert into #Sucursal_temp (ciudad,reemplazo,direccion,horario,telefono)
		select * from OPENROWSET(
			''Microsoft.ACE.OLEDB.16.0'',
			''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
			''select * from [sucursal$]''
			)';

	exec sp_executesql @cadenaSQL

	--le sacamos el guion al telefono
	update #Sucursal_temp
	set telefono = replace(telefono,'-','');

	--convertimos el telefono a entero
	update #Sucursal_temp
	set telefono_int = cast(telefono as int);

	insert gestion_tienda.Sucursal (nombre_sucursal,ciudad,direccion,horario,telefono)
	select ciudad,reemplazo,direccion,horario,telefono_int
	from #Sucursal_temp st
	where st.direccion COLLATE Modern_Spanish_CI_AI NOT IN 
    (select direccion from gestion_tienda.Sucursal);

	drop table #Sucursal_temp

END
GO


exec inserts.insertar_sucursal @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO


-- ARCHIVO INFORMACION COMPLEMENTARIA: EMPLEADOS

CREATE OR ALTER PROCEDURE inserts.insertar_empleado
@ruta varchar(200),
@claveEncripcion nvarchar(128)
AS
BEGIN
	
	DECLARE @error varchar(max) = '';

	--Comprobamos que la clave de encripcion sea correcta antes de empezar
	IF(EXISTS(SELECT 1 FROM encriptacion.Credenciales) and 
		HASHBYTES('SHA2_256', @claveEncripcion) = (select hash_pass from encriptacion.Credenciales) )
		BEGIN
			IF OBJECT_ID('tempdb..#Empleado_temp') IS NULL
			BEGIN
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
			END

			declare @cadenaSQL nvarchar(max)
			set @cadenaSQL =

				N'insert into #Empleado_temp (legajo,nombre,apellido,dni_inicial,direccion,email_personal,email_empresa,CUIL,cargo,sucursal,turno)
				select * from OPENROWSET(
					''Microsoft.ACE.OLEDB.16.0'',
					''Excel 12.0;HDR=YES;Database=' + @ruta + ''',
					''select * from [Empleados$]''
					)';

			exec sp_executesql @cadenaSQL;

			delete from #Empleado_temp
			where legajo is null

			--Convertimos el dni a varchar
			update #Empleado_temp
			set dni = cast((convert(int,dni_inicial)) as varchar(8));

			--Cambiamos jornada completa por JC
			update #Empleado_temp
			set turno = 'JC'
			where turno = 'Jornada Completa';


			insert gestion_tienda.Empleado (legajo, nombre, apellido, num_documento, tipo_documento, direccion, email_personal, email_empresarial, CUIL, turno)
			select legajo,nombre,apellido,dni, 'DU' as tipo_documento,direccion,email_personal,email_empresa, '11-11111111-1' as CUIL,turno
			from #Empleado_temp et
			where et.legajo COLLATE Modern_Spanish_CI_AI NOT IN 
			(select legajo from gestion_tienda.Empleado);

			--Incluimos la sucursal
			update e
			set e.sucursal_id = s.ID_sucursal
			from #Empleado_temp et join gestion_tienda.Empleado e on e.legajo = et.legajo COLLATE Modern_Spanish_CI_AI
				join gestion_tienda.Sucursal s on et.sucursal = s.nombre_sucursal COLLATE Modern_Spanish_CI_AI
			where e.sucursal_id is NULL;

			--Incluimos el cargo
			update e
			set e.cargo = c.id_cargo
			from #Empleado_temp et join gestion_tienda.Empleado e on e.legajo = et.legajo COLLATE Modern_Spanish_CI_AI
				join gestion_tienda.Cargo c on c.cargo = et.cargo COLLATE Modern_Spanish_CI_AI
			where e.cargo is NULL;

			--Encriptamos los datos
			update gestion_tienda.Empleado
			set num_documento =	EncryptByPassPhrase(@claveEncripcion
					, cast(num_documento as varbinary(256)), 1, CONVERT(varbinary, ID_empleado)),
			direccion =	EncryptByPassPhrase(@claveEncripcion
					, direccion, 1, CONVERT(varbinary, ID_empleado)),
			email_personal =	EncryptByPassPhrase(@claveEncripcion
					, email_personal, 1, CONVERT(varbinary, ID_empleado)),
			CUIL =	EncryptByPassPhrase(@claveEncripcion
					, CUIL, 1, CONVERT(varbinary, ID_empleado))

			drop table #Empleado_temp

		END --end del if
		ELSE
		BEGIN
			set @error = @error + 'ERROR: la clave no estaba seteada o es incorrecta.';
			RAISERROR (@error, 16, 1);
		END
END
GO

exec inserts.insertar_empleado @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO



-- ARCHIVO VENTAS



CREATE OR ALTER PROCEDURE inserts.insertar_venta
@ruta varchar(200)
AS
BEGIN


	IF OBJECT_ID('tempdb..#Venta_temp') IS NULL
	BEGIN
		CREATE TABLE #Venta_temp(
		ID_factura varchar(20),
		tipo_factura varchar(1),
		ciudad varchar(20),
		tipo_cliente varchar(6),
		genero varchar(6),
		producto varchar(100),
		precio varchar(20),
		cantidad varchar(5),
		fecha varchar(20),
		hora time,
		medio_pago varchar(20),
		empleado varchar(6),
		id_pago varchar(40)
		);
	END

	declare @cadenaSQL nvarchar(max)
	set @cadenaSQL =

		N'bulk insert #Venta_temp
		from ''' + @ruta + '''
		with
		(
			FIELDTERMINATOR = '';'',
			ROWTERMINATOR = ''0x0D0A'',
			DATAFILETYPE = ''char'',
			CODEPAGE = ''65001'',
			FIRSTROW = 2
		)'

	EXEC sp_executesql @CadenaSQL
	
	UPDATE #Venta_temp
	SET producto =  replace(replace(replace(replace(replace(replace(producto,'Ã¡','á'),'Ã©','é'),'Ã³','ó'),'Ãº','ú'),'Ã±','ñ'),'Ã','í')

	-- Insertar factura

	insert gestion_ventas.Factura (nro_factura,tipo_factura,estado_factura,total_neto_sinIVA,IVA,CUIT_supermercado,CUIL_cliente,fecha_hora_emision)
	select vt.ID_factura, vt.tipo_factura, 'PA',
		(cast(vt.precio as decimal(10,2)) * cast(vt.cantidad as decimal (10,2))) as total, 21,
	(select CUIT_supermercado
		from gestion_ventas.Configuracion_Supermercado),
	'111111111111', 
	(select cast(vt.fecha as datetime) + cast(vt.hora as datetime) as FechaHora)
	from #Venta_temp vt
	where vt.ID_factura COLLATE Modern_Spanish_CI_AI NOT IN 
    (select nro_factura from gestion_ventas.Factura);

	-- Insertar venta

	insert gestion_ventas.Venta (fecha,hora,ID_punto_venta,id_medio_pago,ID_empleado,identificador_pago,ID_factura)
	select convert(date,vt.fecha,101)as fecha,vt.hora,
	(select ID_punto_venta
		from gestion_tienda.Sucursal s join gestion_tienda.punto_de_venta pv on pv.ID_sucursal = s.ID_sucursal
		where vt.ciudad = s.ciudad COLLATE Modern_Spanish_CI_AI),
	(select ID_MP
		from gestion_ventas.Medio_de_Pago mp 
		where vt.medio_pago = mp.nombre_EN COLLATE Modern_Spanish_CI_AI),
	(select ID_empleado
		from gestion_tienda.Empleado e 
		where cast(vt.empleado as int) = e.legajo),
	vt.id_pago,
	(select f.ID_factura
		from gestion_ventas.Factura f
		where vt.ID_factura = f.nro_factura COLLATE Modern_Spanish_CI_AI)
	from #Venta_temp vt
	where vt.ID_factura COLLATE Modern_Spanish_CI_AI NOT IN 
    (select f.nro_factura from gestion_ventas.Venta v join gestion_ventas.Factura f on v.ID_factura = f.ID_factura) 

	--Insertar detalle de venta

	insert gestion_ventas.Detalle_venta(ID_venta, ID_prod, subtotal, cantidad)
	SELECT v.ID_venta, prod.ID_prod, vt.precio, 1
	FROM #Venta_temp vt 
	join gestion_ventas.Factura f on vt.ID_factura = f.nro_factura COLLATE Modern_Spanish_CI_AI
	join gestion_ventas.Venta v on v.ID_factura = f.ID_factura 
	join gestion_productos.Producto prod on prod.nombre_Prod = vt.producto COLLATE Modern_Spanish_CI_AI
	where v.ID_venta not in (select ID_venta from gestion_ventas.Detalle_venta)

END
GO


exec inserts.insertar_venta @ruta = 'D:\Universidad\BDD Aplicada\TP integrador archivos\TP_integrador_Archivos\Ventas_registradas.xlsx'
GO
