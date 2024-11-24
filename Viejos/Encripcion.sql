/*
	Entrega 5. Grupo 02.

	Alumnos: 
	43448036 Ghiano Gonzalo Agustín 
	40853807 Felipe Morales 
	38621360 Javier Bastante

	Materia: BASE DE DATOS APLICADAS (3641)
	Comisión: 01-2900
	Fecha de entrega: 12/11/2024

	
*/
--drop database Com2900G02;

USE Com2900G02;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'encripcion')
    exec('CREATE SCHEMA encripcion');
GO

--CREAMOS LA TABLA PARA ALMACENAR EL HASH DE LA PASSWORD DE EMPLEADO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'encripcion.datos_empleado') 
AND type in (N'U'))
BEGIN
		CREATE TABLE encripcion.datos_empleado(
		clave_set bit default 0,
		hash_pass varbinary(64));

END
GO

if((select 1 from encripcion.datos_empleado) is null)
	insert encripcion.datos_empleado default values
GO

--Seteo inicial de clave
CREATE OR ALTER PROCEDURE encripcion.setear_claveEmp
@clave nvarchar(128)
AS
BEGIN
	
	DECLARE @error varchar(max) = '';

	IF( (select top 1 clave_Set from encripcion.datos_empleado) = 0)
		BEGIN

			update encripcion.datos_empleado
			set clave_set = 1,
				hash_pass = HASHBYTES('SHA2_256', @clave);

		END
	ELSE
		BEGIN

			set @error = @error + 'ERROR: la clave ya estaba seteada previamente.';
			RAISERROR (@error, 16, 1);

		END

END
GO

--SP para cambiar la clave
CREATE OR ALTER PROCEDURE encripcion.cambiar_claveEmp
@claveVieja nvarchar(128),
@claveNueva nvarchar(128)
AS
BEGIN
	
	DECLARE @error varchar(max) = '';

	IF( ((select top 1 clave_Set from encripcion.datos_empleado) = 1) and 
		(HASHBYTES('SHA2_256', @claveVieja) = (select hash_pass from encripcion.datos_empleado)) )
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

			update encripcion.datos_empleado
			set hash_pass = HASHBYTES('SHA2_256', @claveNueva);

		END
	ELSE
		BEGIN

			set @error = @error + 'ERROR: la clave no estaba seteada o es incorrecta.';
			RAISERROR (@error, 16, 1);

		END

END

select * from encripcion.datos_empleado
GO

exec encripcion.setear_claveEmp @clave = 'ClaveSegura';

exec encripcion.cambiar_claveEMP @claveVieja = 'ClaveSegura', @ClaveNueva = 'AhoraSiEsSegura';


/*
CREATE OR ALTER PROCEDURE encripcion.encriptar_empleados
@clave nvarchar(128)
AS
BEGIN

	DECLARE @error varchar(max) = '';
	DECLARE @hash varbinary(64);

	if((select top 1 encriptado from encripcion.datos_empleado) = 0)
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

			update encripcion.datos_empleado
			set encriptado = 1

			set @hash = HASHBYTES('SHA2_256', @clave);

			update encripcion.datos_empleado
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
CREATE OR ALTER PROCEDURE encripcion.mostrar_empleadoDesencriptado
@clave nvarchar(128)
AS
BEGIN

	DECLARE @error varchar(max) = '';

	if( (HASHBYTES('SHA2_256', @clave) = (select hash_pass from encripcion.datos_empleado)) and ((select clave_set from encripcion.datos_empleado) = 1) )
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

exec encripcion.mostrar_empleadoDesencriptado @clave = 'ClaveSegura'

exec encripcion.mostrar_empleadoDesencriptado @clave = 'AhoraSiEsSegura'

