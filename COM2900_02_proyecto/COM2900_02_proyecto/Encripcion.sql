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
		encriptado bit default 0,
		hash_pass varbinary(64));

END
GO

if((select 1 from encripcion.datos_empleado) is null)
	insert encripcion.datos_empleado default values
GO

select * from encripcion.datos_empleado
GO

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

CREATE OR ALTER PROCEDURE encripcion.desencriptar_empleados
@clave nvarchar(128)
AS
BEGIN

	DECLARE @error varchar(max) = '';

	if( (HASHBYTES('SHA2_256', @clave) = (select hash_pass from encripcion.datos_empleado)) and ((select encriptado from encripcion.datos_empleado) = 1) )
		BEGIN
			update gestion_tienda.Empleado
			set num_documento =	decryptByPassPhrase(@Clave
					, cast(num_documento as varbinary(256)), 1, CONVERT(varbinary, ID_empleado)),
				direccion =	decryptByPassPhrase(@Clave
					, direccion, 1, CONVERT(varbinary, ID_empleado)),
				email_personal =	decryptByPassPhrase(@Clave
					, email_personal, 1, CONVERT(varbinary, ID_empleado)),
				CUIL =	decryptByPassPhrase(@Clave
					, CUIL, 1, CONVERT(varbinary, ID_empleado))


			alter table gestion_tienda.Empleado drop constraint UNIQUE_TipoDoc_NumDoc;
			alter table gestion_tienda.Empleado alter column num_documento int;
			alter table gestion_tienda.Empleado add CONSTRAINT UNIQUE_TipoDoc_NumDoc UNIQUE (tipo_documento, num_documento);

			alter table gestion_tienda.Empleado alter column direccion varchar(100);
			alter table gestion_tienda.Empleado alter column email_personal varchar(80);

			alter table gestion_tienda.Empleado alter column CUIL varchar(13);
			alter table gestion_tienda.Empleado add CONSTRAINT CHECK_CUIL CHECK(
					CUIL like '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]')

			update encripcion.datos_empleado
			set encriptado = 0

			update encripcion.datos_empleado
			set hash_pass = NULL

		END
	ELSE
		BEGIN

			set @error = @error + 'ERROR: la clave es incorrecta o la tabla no esta encriptada';
			RAISERROR (@error, 16, 1);

		END

END
GO

			update gestion_tienda.Empleado
			set num_documento = 15101010
			where ID_empleado = 15

select *
from gestion_tienda.Empleado

exec encripcion.encriptar_empleados @Clave = 'ClaveSegura'

select *
from gestion_tienda.Empleado

exec encripcion.desencriptar_empleados @Clave = 'ClaveSegura'

select *
from gestion_tienda.Empleado
