/*
	Entrega 5. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 26/11/2024

	
*/
--drop database Com2900G02;

USE Com2900G02;
GO



--CREAMOS LA TABLA PARA ALMACENAR EL HASH DE LA PASSWORD DE EMPLEADO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'encriptacion.Credenciales') 
AND type in (N'U'))
BEGIN
		CREATE TABLE encriptacion.Credenciales(
		hash_pass varbinary(64));
END
GO

--Seteo inicial de clave
CREATE OR ALTER PROCEDURE encriptacion.configuracion_encriptacion
@clave nvarchar(128)
AS
BEGIN
	DECLARE @error varchar(max) = '';

	IF(NOT EXISTS(SELECT 1 FROM encriptacion.Credenciales))
		BEGIN
			INSERT INTO encriptacion.Credenciales(hash_pass)
			VALUES (HASHBYTES('SHA2_256', @clave));

			alter table gestion_tienda.Empleado drop constraint UNIQUE_TipoDoc_NumDoc;
			alter table gestion_tienda.Empleado alter column num_documento varbinary(256);
			alter table gestion_tienda.Empleado add CONSTRAINT UNIQUE_TipoDoc_NumDoc UNIQUE (tipo_documento, num_documento);

			alter table gestion_tienda.Empleado alter column direccion nvarchar(256);
			alter table gestion_tienda.Empleado alter column email_personal nvarchar(256);

			--alter table gestion_tienda.Empleado drop constraint CHECK_CUIL;

			alter table gestion_tienda.Empleado alter column CUIL nvarchar(256);
		END
	ELSE
		BEGIN
			set @error = @error + 'ERROR: la clave ya estaba seteada previamente.';
			RAISERROR (@error, 16, 1);
		END
END
GO

--SP para cambiar la clave
CREATE OR ALTER PROCEDURE encriptacion.cambiar_claveEmp
@claveVieja nvarchar(128),
@claveNueva nvarchar(128)
AS
BEGIN
	DECLARE @error varchar(max) = '';

	IF((EXISTS(SELECT 1 FROM encriptacion.Credenciales)) AND 
		(HASHBYTES('SHA2_256', @claveVieja) = (select top 1 hash_pass from encriptacion.Credenciales)) )
		BEGIN
			update gestion_tienda.Empleado
				set num_documento = decryptByPassPhrase(@claveVieja
					, cast(num_documento as varbinary(256)), 1, CONVERT(varbinary, ID_empleado)),
					direccion = decryptByPassPhrase(@claveVieja
					, direccion, 1, CONVERT(varbinary, ID_empleado)),
					email_personal = decryptByPassPhrase(@claveVieja
					, email_personal, 1, CONVERT(varbinary, ID_empleado)),
					CUIL = decryptByPassPhrase(@claveVieja
					, CUIL, 1, CONVERT(varbinary, ID_empleado))
			
			update gestion_tienda.Empleado
			set num_documento =	EncryptByPassPhrase(@claveNueva
					, cast(num_documento as varbinary(256)), 1, CONVERT(varbinary, ID_empleado)),
			direccion =	EncryptByPassPhrase(@claveNueva
					, direccion, 1, CONVERT(varbinary, ID_empleado)),
			email_personal =	EncryptByPassPhrase(@claveNueva
					, email_personal, 1, CONVERT(varbinary, ID_empleado)),
			CUIL =	EncryptByPassPhrase(@claveNueva
					, CUIL, 1, CONVERT(varbinary, ID_empleado))

			update encriptacion.Credenciales
			set hash_pass = HASHBYTES('SHA2_256', @claveNueva);
		END
	ELSE
		BEGIN
			set @error = @error + 'ERROR: la clave no estaba seteada o es incorrecta.';
			RAISERROR (@error, 16, 1);
		END
END
GO

--select * from encriptacion.Credenciales


--exec encriptacion.setear_claveEmp @clave = 'ClaveSegura';

--exec encriptacion.cambiar_claveEMP @claveVieja = 'ClaveSegura', @ClaveNueva = 'AhoraSiEsSegura';


/*
CREATE OR ALTER PROCEDURE encriptacion.encriptar_empleados
@clave nvarchar(128)
AS
BEGIN

	DECLARE @error varchar(max) = '';
	DECLARE @hash varbinary(64);

	if((select top 1 encriptado from encriptacion.Credenciales) = 0)
		BEGIN
			alter table gestion_tienda.Empleado drop constraint UNIQUE_TipoDoc_NumDoc;
			alter table gestion_tienda.Empleado alter column num_documento varbinary(256);
			alter table gestion_tienda.Empleado add CONSTRAINT UNIQUE_TipoDoc_NumDoc UNIQUE (tipo_documento, num_documento);

			alter table gestion_tienda.Empleado alter column direccion nvarchar(256);
			alter table gestion_tienda.Empleado alter column email_personal nvarchar(256);

			alter table gestion_tienda.Empleado drop constraint CHECK_CUIL;
			alter table gestion_tienda.Empleado alter column CUIL nvarchar(256);



			update gestion_tienda.Empleado
			set num_documento =	EncryptByPassPhrase(@Clave
					, cast(num_documento as varbinary(256)), 1, CONVERT(varbinary, ID_empleado)),
			direccion =	EncryptByPassPhrase(@Clave
					, direccion, 1, CONVERT(varbinary, ID_empleado)),
			email_personal =	EncryptByPassPhrase(@Clave
					, email_personal, 1, CONVERT(varbinary, ID_empleado)),
			CUIL =	EncryptByPassPhrase(@Clave
					, CUIL, 1, CONVERT(varbinary, ID_empleado))

			update encriptacion.Credenciales
			set encriptado = 1

			set @hash = HASHBYTES('SHA2_256', @clave);

			update encriptacion.Credenciales
			set hash_pass = @hash


		END
	ELSE
		BEGIN
			
			set @error = @error + 'ERROR: la tabla ya está encriptada';
			RAISERROR (@error, 16, 1);

		END	
END
GO
*/


--SP de prueba para verificar la integridad de los datos luego del cifrado
CREATE OR ALTER PROCEDURE gestion_tienda.mostrar_empleadoDesencriptado
@clave nvarchar(128)
AS
BEGIN
	DECLARE @error varchar(max) = '';

	if(EXISTS(SELECT 1 FROM encriptacion.Credenciales) AND (HASHBYTES('SHA2_256', @clave) = (select hash_pass from encriptacion.Credenciales)) )
		BEGIN
			select ID_empleado,legajo,nombre,apellido,
				cast(decryptByPassPhrase(@clave
					, cast(num_documento as varbinary(256)), 1, CONVERT(varbinary, ID_empleado)) as int) as num_documento,
				tipo_documento,
				cast(decryptByPassPhrase(@clave
					, direccion, 1, CONVERT(varbinary, ID_empleado)) as nvarchar(100)) as direccion,
				cast(decryptByPassPhrase(@clave
					, email_personal, 1, CONVERT(varbinary, ID_empleado)) as nvarchar(80)) as email_personal ,
				email_empresarial,
				cast(decryptByPassPhrase(@clave
					, CUIL, 1, CONVERT(varbinary, ID_empleado)) as nchar(13)) as CUIL,
				cargo,sucursal_id,turno,habilitado
			from gestion_tienda.Empleado
		END
	ELSE
		BEGIN
			set @error = @error + 'ERROR: la clave es incorrecta o no esta seteada';
			RAISERROR (@error, 16, 1);
		END
END
GO

--exec encriptacion.mostrar_empleadoDesencriptado @clave = 'ClaveSegura'

--exec encriptacion.mostrar_empleadoDesencriptado @clave = 'AhoraSiEsSegura'

USE Com2900G02;
GO

CREATE OR ALTER PROCEDURE inserts.insertar_empleado_encriptado
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