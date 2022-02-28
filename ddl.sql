CREATE PROCEDURE TR1
	@firstname nvarchar(max), 
	@lastname nvarchar(max), 
	@email nvarchar(max), 
	@password nvarchar(max), 
	@credits int
AS
BEGIN 
	SET NOCOUNT ON;
	BEGIN TRAN
		BEGIN TRY	
			IF @email = (SELECT [Email] FROM [BD2].[practica1].[Usuarios] WHERE [Email] = @email)
				BEGIN
					-- el correo ya se registro
					INSERT INTO [BD2].[practica1].[HistoryLog] (Date, Description) VALUES (GETDATE(), 'CORREO YA REGISTRADO')
				END
			ELSE
				BEGIN
					DECLARE @idUsuario uniqueidentifier = NEWID()
					DECLARE @idUsuarioRole uniqueidentifier = (SELECT [Id] FROM [BD2].[practica1].[Roles] WHERE [RoleName] = 'Student')
				
					-- INSERTAMOS USUARIO
					INSERT INTO [BD2].[practica1].[Usuarios]
						   ([Id]
						   ,[Firstname]
						   ,[Lastname]
						   ,[Email]
						   ,[DateOfBirth]
						   ,[Password]
						   ,[LastChanges]
						   ,[EmailConfirmed])
					 VALUES
						   (@idUsuario
						   ,@firstname
						   ,@lastname
						   ,@email
						   ,GETDATE()
						   ,@password
						   ,GETDATE()
						   ,0)

					-- INSERTAMOS EN UsuarioRole
					INSERT INTO [BD2].[practica1].[UsuarioRole]
						([RoleId]
						,[UserId]
						,[IsLatestVersion])
					VALUES
						(@idUsuarioRole
						,@idUsuario
						,1)

					-- INSERTAMOS EN ProfileStudent
					INSERT INTO [BD2].[practica1].[ProfileStudent]
						 ([UserId]
						,[Credits])
					VALUES
						(@idUsuario
						,@credits)

					-- INSERTAMOS EN TFA
					INSERT INTO [BD2].[practica1].[TFA]
						   ([UserId]
						   ,[Status]
						   ,[LastUpdate])
					 VALUES
						   (@idUsuario
						   ,0
						   ,GETDATE())

					-- INSERTAR EN Notification
					INSERT INTO [practica1].[Notification]
						   ([UserId]
						   ,[Message]
						   ,[Date])
					 VALUES
						   (@idUsuario
						   ,'Usuario creado con exito'
						   ,GETDATE())

					-- INSERTAMOS EN HistoryLog
					INSERT INTO [BD2].[practica1].[HistoryLog] (Date, Description) VALUES (GETDATE(), 'Usuario creado con éxito')
				END
			
			COMMIT TRANSACTION;
		END TRY
		BEGIN CATCH

			declare @error int, @message varchar(4000), @xstate int;
			select @error = ERROR_NUMBER(), @message = ERROR_MESSAGE(), @xstate = XACT_STATE();
			INSERT INTO [BD2].[practica1].[HistoryLog]
				([Date]
				 ,[Description])
			VALUES
				(GETDATE()
				,@message)
			rollback transaction TR1;
			raiserror ('usp_my_procedure_name: %d: %s', 16, 1, @error, @message) ;
				
		END CATCH
END

EXEC TR1 @firstname = 'g', @lastname = 'g', @email = 'Gg', @password = 'g', @credits = 33;
