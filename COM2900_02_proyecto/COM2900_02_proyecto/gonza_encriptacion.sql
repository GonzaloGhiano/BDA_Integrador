USE Com2900G02;
GO


IF NOT EXISTS (SELECT * FROM sys.certificates WHERE name = 'Certificado_Empleados')
BEGIN
    -- Creamos el certificado que va a proteger la clave simétrica
	CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Clave_Maestra';

    CREATE CERTIFICATE Certificado_Empleados
    WITH SUBJECT = 'Certificado para encriptar los datos personales de los empleados';

    PRINT 'Certificado creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = 'Empleados_ClaveSimetrica')
BEGIN
    -- Creamos la clave simétrica que vamos a usar para encriptar la tabla de empleados
    CREATE SYMMETRIC KEY Empleados_ClaveSimetrica
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE Certificado_Empleados;

    PRINT 'Clave simétrica creada';
END
GO

CREATE OR ALTER PROCEDURE encriptacion.configuracion_encriptacion
AS
BEGIN
    -- Agregar nuevas columnas para datos encriptados
    ALTER TABLE gestion_tienda.Empleado ADD nombre_vb VARBINARY(8000);
    ALTER TABLE gestion_tienda.Empleado ADD apellido_vb VARBINARY(8000);
    ALTER TABLE gestion_tienda.Empleado ADD num_documento_vb VARBINARY(8000);
	ALTER TABLE gestion_tienda.Empleado ADD direccion_vb VARBINARY(8000);
	ALTER TABLE gestion_tienda.Empleado ADD email_personal_vb VARBINARY(8000);
	ALTER TABLE gestion_tienda.Empleado ADD email_empresarial_vb VARBINARY(8000);
	ALTER TABLE gestion_tienda.Empleado ADD CUIL_vb VARBINARY(8000);

	ALTER TABLE gestion_tienda.Empleado DROP CONSTRAINT UNIQUE_TipoDoc_NumDoc;
	ALTER TABLE gestion_tienda.Empleado DROP CONSTRAINT CHECK_CUIL;

    -- Eliminar las columnas originales
    ALTER TABLE gestion_tienda.Empleado DROP COLUMN nombre;
    ALTER TABLE gestion_tienda.Empleado DROP COLUMN apellido;
    ALTER TABLE gestion_tienda.Empleado DROP COLUMN num_documento;
	ALTER TABLE gestion_tienda.Empleado DROP COLUMN direccion;
    ALTER TABLE gestion_tienda.Empleado DROP COLUMN email_personal;
    ALTER TABLE gestion_tienda.Empleado DROP COLUMN email_empresarial;
	ALTER TABLE gestion_tienda.Empleado DROP COLUMN CUIL;


    -- Renombrar las columnas encriptadas a los nombres originales
    EXEC sp_rename 'gestion_tienda.Empleado.nombre_vb', 'nombre', 'COLUMN';
    EXEC sp_rename 'gestion_tienda.Empleado.apellido_vb', 'apellido', 'COLUMN';
    EXEC sp_rename 'gestion_tienda.Empleado.num_documento_vb', 'num_documento', 'COLUMN';
	EXEC sp_rename 'gestion_tienda.Empleado.direccion_vb', 'direccion', 'COLUMN';
	EXEC sp_rename 'gestion_tienda.Empleado.email_personal_vb', 'email_personal', 'COLUMN';
	EXEC sp_rename 'gestion_tienda.Empleado.email_empresarial_vb', 'email_empresarial', 'COLUMN';
	EXEC sp_rename 'gestion_tienda.Empleado.CUIL_vb', 'CUIL', 'COLUMN';
END
GO



CREATE OR ALTER PROCEDURE inserts.insertar_empleado_encriptado
@ruta varchar(200)
AS
BEGIN

	IF OBJECT_ID('tempdb..#Empleado_temp') IS NULL
	BEGIN
		CREATE TABLE #Empleado_temp(
		legajo varchar(MAX),
		nombre varchar(MAX),
		apellido varchar(MAX),
		dni varchar(MAX),
		dni_inicial float,
		direccion varchar(MAX),
		email_personal varchar(MAX),
		email_empresa varchar(MAX),
		CUIL varchar(MAX),
		cargo varchar(MAX),
		sucursal varchar(MAX),
		turno varchar(MAX)
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

	OPEN SYMMETRIC KEY Empleados_ClaveSimetrica
	DECRYPTION BY CERTIFICATE Certificado_Empleados;

	insert gestion_tienda.Empleado 
	(legajo, nombre, apellido, num_documento, tipo_documento, direccion, email_personal, email_empresarial, CUIL, turno)
	select cast(legajo as int),
		ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), nombre),
		ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), apellido),
		ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), dni),
		'DU' as tipo_documento,
		ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), direccion),
		ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), email_personal),
		ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), email_empresa),
		ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), '20-22222222-3'),
		turno
	from #Empleado_temp et
	where et.legajo COLLATE Modern_Spanish_CI_AI NOT IN 
    (select legajo from gestion_tienda.Empleado);

	--Incluimos la sucursal
	update e
	set e.sucursal_id = s.ID_sucursal
	from #Empleado_temp et join gestion_tienda.Empleado e on e.legajo = cast(et.legajo as int)
		join gestion_tienda.Sucursal s on et.sucursal = s.nombre_sucursal COLLATE Modern_Spanish_CI_AI
	where e.sucursal_id is NULL;

	--Incluimos el cargo
	update e
	set e.cargo = c.id_cargo
	from #Empleado_temp et join gestion_tienda.Empleado e on e.legajo = cast(et.legajo as int)
		join gestion_tienda.Cargo c on c.cargo = et.cargo COLLATE Modern_Spanish_CI_AI
	where e.cargo is NULL;

	CLOSE SYMMETRIC KEY Empleados_ClaveSimetrica;

	drop table #Empleado_temp

END
GO


exec encriptacion.configuracion_encriptacion;

exec inserts.insertar_empleado_encriptado @ruta = 'C:\Users\Gonza\Desktop\BDA_Tp_Final\TP_integrador_Archivos\informacion_complementaria.xlsx'
GO

SELECT TOP 30 * FROM gestion_tienda.Empleado;
GO

CREATE OR ALTER PROCEDURE gestion_tienda.mostrarEmpleados_desencriptados
AS
BEGIN
	OPEN SYMMETRIC KEY Empleados_ClaveSimetrica
	DECRYPTION BY CERTIFICATE Certificado_Empleados;

	SELECT 
		ID_empleado,
		legajo,
		CONVERT(VARCHAR(40), DecryptByKey(nombre)) AS nombre,
		CONVERT(VARCHAR(40), DecryptByKey(apellido)) AS apellido,
		CONVERT(VARCHAR(8), DecryptByKey(num_documento)) AS num_documento,
		tipo_documento,
		CONVERT(VARCHAR(100), DecryptByKey(direccion)) AS direccion,
		CONVERT(VARCHAR(80), DecryptByKey(email_personal)) AS email_personal,
		CONVERT(VARCHAR(80), DecryptByKey(email_empresarial)) AS email_empresarial,
		CONVERT(VARCHAR(13), DecryptByKey(CUIL)) AS CUIL,
		cargo,
		sucursal_id,
		turno,
		habilitado
	FROM gestion_tienda.Empleado

	CLOSE SYMMETRIC KEY Empleados_ClaveSimetrica;
END
GO

EXEC gestion_tienda.mostrarEmpleados_desencriptados
GO


create or alter procedure datos_tienda.insertar_empleado_encriptado
@legajo int,
@nombre varchar(40),
@apellido varchar(30),
@num_documento int = NULL,
@tipo_documento char(2) = NULL,
@direccion varchar(80),
@email_personal varchar(80) = NULL,
@email_empresarial varchar(80),
@CUIL char(13),
@cargo int = NULL,
@sucursal_id int = NULL,
@turno char(2) = 'NA'
AS
BEGIN

	DECLARE @error varchar(max) = '';
	--Validar CUIL
	IF(ISNULL(@CUIL, '') = '')
		SET @error = @error + 'ERROR: El CUIL no puede ser vacio'
	
	--Validar num_Documento
	IF(gestion_tienda.validar_num_documento(@num_documento) = 0)
		SET @error = @error + 'ERROR: Numero de documento invalido';
	
	--Validar Tipo_Doc
	IF(gestion_tienda.validar_tipo_documento(@tipo_documento) = 0)
		SET @error = @error + 'ERROR: Tipo de documento invalido'

	-- Validar formato legajo
	IF(ISNULL(@legajo, 0) = 0)
		SET @error = @error + 'ERROR: El legajo no puede ser vacio'
	ELSE IF(@legajo <= 0)
		SET @error = @error + 'Formato de legajo incorrecto';
	

	IF(@error = '')
	BEGIN
		
		OPEN SYMMETRIC KEY Empleados_ClaveSimetrica
		DECRYPTION BY CERTIFICATE Certificado_Empleados;

		insert gestion_tienda.Empleado
		(legajo,nombre,apellido,num_documento,tipo_documento,direccion,email_personal,email_empresarial,
		CUIL,cargo,sucursal_id,turno)
		values 
		(
			@legajo,
			ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), @nombre),
			ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), @apellido),
			ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), cast(@num_documento as varchar(max))),
			@tipo_documento,
			ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), @direccion),
			ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), @email_personal),
			ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), @email_empresarial),
			ENCRYPTBYKEY(KEY_GUID('Empleados_ClaveSimetrica'), @CUIL),
			@cargo,
			@sucursal_id,
			@turno
		)

		CLOSE SYMMETRIC KEY Empleados_ClaveSimetrica;

	END
	ELSE
	BEGIN
		RAISERROR (@error, 16, 1);
	END
END
GO


EXEC datos_tienda.insertar_empleado_encriptado
@legajo = 9999,
@nombre = 'Gonzalo',
@apellido = 'Gonzalez',
@num_documento = 12345678,
@tipo_documento = 'DU',
@direccion = 'Avenida Rivadavia 123',
@email_personal = 'gonzalogonzalez@hotmail.com',
@email_empresarial  = 'gonzalogonzalez@empresa.com',
@CUIL = '22-44312312-2',
@cargo = 1,
@sucursal_id = 1,
@turno = 'NA';

SELECT TOP 30 * FROM gestion_tienda.Empleado;
GO

EXEC gestion_tienda.mostrarEmpleados_desencriptados
GO