USE Com2900G02
GO

create procedure gestion_sistema.InsertarSucursal
@nombre varchar(30),
@ciudad varchar(30),
@direccion varchar(70),
@horario varchar(40),
@telefono int = NULL
as
begin

	insert into gestion_sistema.Sucursal (nombre_sucursal,ciudad,direccion,horario,telefono)
	values (@nombre,@ciudad,@direccion,@horario,@telefono)

end
GO

create procedure gestion_sistema.ModificarSucursal
@ID_sucursal int,
@nombre varchar(30) = NULL,
@ciudad varchar(30) = NULL,
@direccion varchar(70) = NULL,
@horario varchar(40) = NULL,
@telefono int = NULL
as
begin

	update gestion_sistema.Sucursal
	set	nombre_sucursal = coalesce(@nombre,nombre_sucursal),
		ciudad = coalesce(@ciudad,ciudad),
		direccion = coalesce(@direccion,direccion),
		horario = coalesce(@horario, horario),
		telefono = coalesce(@telefono, telefono)
	where ID_sucursal = @ID_sucursal

end
GO

create procedure gestion_sistema.BorrarSucursal
@ID_sucursal int
as
begin

	delete from gestion_sistema.Sucursal
	where ID_sucursal = @ID_sucursal

end
GO


create procedure gestion_empleados.InsertarCargo
@cargo varchar(25)
as
begin

	insert into gestion_empleados.Cargo (cargo)
	values (@cargo)

end
GO

create procedure gestion_empleados.ModificarCargo
@cargo varchar(25)
as
begin

	update gestion_empleados.Cargo
	set	cargo = @cargo
	where cargo = @cargo

end
GO

create procedure gestion_empleados.BorrarCargo
@cargo varchar(25)
as
begin

	delete from gestion_empleados.Cargo
	where cargo = @cargo

end
GO


create procedure gestion_empleados.InsertarEmpleado
@legajo int,
@nombre varchar(40),
@apellido varchar(30),
@DNI int,
@direccion varchar(70),
@email_personal varchar(70) = NULL,
@email_empresarial varchar(70),
@CUIL int,
@cargo varchar(25),
@sucursal_ID int,
@turno char(2) = 'NA'
as
begin

	insert into gestion_empleados.Empleado(legajo,nombre,apellido,DNI,direccion,email_personal,email_empresarial,CUIL,cargo,sucursal_ID,turno)
	values (@legajo,@nombre,@apellido,@DNI,@direccion,@email_personal,@email_empresarial,@CUIL,@cargo,@sucursal_ID,@turno)

end
GO

create procedure gestion_empleados.ModificarEmpleado
@legajo int,
@nombre varchar(40) = NULL,
@apellido varchar(30) = NULL,
@DNI int = NULL,
@direccion varchar(70) = NULL,
@email_personal varchar(70) = NULL,
@email_empresarial varchar(70) = NULL,
@CUIL int = NULL,
@cargo varchar(25) = NULL,
@sucursal_ID int = NULL,
@turno char(2) = 'NA'
as
begin

	update gestion_empleados.Empleado
	set	nombre = coalesce(@nombre,nombre),
		apellido = coalesce(@apellido,apellido),
		DNI = coalesce(@DNI,DNI),
		direccion = coalesce(@direccion,direccion),
		email_personal = coalesce(@email_personal,email_personal),
		email_empresarial = coalesce(@email_empresarial,email_empresarial),
		CUIL = coalesce(@CUIL,CUIL),
		cargo = coalesce(@cargo,cargo),
		sucursal_ID = coalesce(@sucursal_ID,sucursal_ID),
		turno = coalesce(@turno,turno)
	where legajo = @legajo

end
GO

create procedure gestion_empleados.BorrarEmpleado
@legajo int
as
begin

	delete from gestion_empleados.Empleado
	where legajo = @legajo

end
GO