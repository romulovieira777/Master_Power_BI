		-------------------------------
		--CRIANDO A DIMENS�O TEMPO--
		-------------------------------
		
		CREATE TABLE DIM_TEMPO( 
			IDSK INT PRIMARY KEY IDENTITY, 
			DATA DATE, 
			DIA CHAR(2), 
			DIASEMANA VARCHAR(10), 
			MES CHAR(2), 
			NOMEMES VARCHAR(10), 
			QUARTO TINYINT, 
			NOMEQUARTO VARCHAR(10), 
			ANO CHAR(4), 
			ESTACAOANO VARCHAR(20),
			FIMSEMANA CHAR(3),
			DATACOMPLETA VARCHAR(10)
		) 
		GO 		
		
		-------------------------------
		--CARREGANDO A DIMENS�O TEMPO--
		-------------------------------

		--EXIBINDO A DATA ATUAL

		PRINT CONVERT(VARCHAR,GETDATE(),113) 

		--ALTERANDO O INCREMENTO PARA IN�CIO EM 5000
		--PARA A POSSIBILIDADE DE DATAS ANTERIORES

		DBCC CHECKIDENT (DIM_TEMPO, RESEED, 50000) 

		--INSER��O DE DADOS NA DIMENS�O

		DECLARE    @DATAINICIO DATETIME 
				 , @DATAFIM DATETIME 
				 , @DATA DATETIME
		 		  
		PRINT GETDATE() 

				SELECT @DATAINICIO = '1/1/1950' 
					, @DATAFIM = '1/1/2050'

				SELECT @DATA = @DATAINICIO 

		WHILE @DATA < @DATAFIM 
		 BEGIN 
	
			INSERT INTO DIM_TEMPO 
			( 
				  DATA, 
				  DIA,
				  DIASEMANA, 
				  MES,
				  NOMEMES, 
				  QUARTO,
				  NOMEQUARTO, 
				  ANO 
		
			) 
			SELECT @DATA AS DATA, DATEPART(DAY,@DATA) AS DIA, 

				 CASE DATEPART(DW, @DATA) 
            
					WHEN 1 THEN 'Domingo'
					WHEN 2 THEN 'Segunda' 
					WHEN 3 THEN 'Ter�a' 
					WHEN 4 THEN 'Quarta' 
					WHEN 5 THEN 'Quinta' 
					WHEN 6 THEN 'Sexta' 
					WHEN 7 THEN 'S�bado' 
             
				END AS DIASEMANA,

				 DATEPART(MONTH,@DATA) AS MES, 

				 CASE DATENAME(MONTH,@DATA) 
			
					WHEN 'January' THEN 'Janeiro'
					WHEN 'February' THEN 'Fevereiro'
					WHEN 'March' THEN 'Mar�o'
					WHEN 'April' THEN 'Abril'
					WHEN 'May' THEN 'Maio'
					WHEN 'June' THEN 'Junho'
					WHEN 'July' THEN 'Julho'
					WHEN 'August' THEN 'Agosto'
					WHEN 'September' THEN 'Setembro'
					WHEN 'October' THEN 'Outubro'
					WHEN 'November' THEN 'Novembro'
					WHEN 'December' THEN 'Dezembro'
		
				END AS NOMEMES,
		 
				 DATEPART(qq,@DATA) QUARTO, 

				 CASE DATEPART(qq,@DATA) 
					WHEN 1 THEN 'Primeiro' 
					WHEN 2 THEN 'Segundo' 
					WHEN 3 THEN 'Terceiro' 
					WHEN 4 THEN 'Quarto' 
				END AS NOMEQUARTO 
				, DATEPART(YEAR,@DATA) ANO
	
			SELECT @DATA = DATEADD(dd,1,@DATA)
		END

		UPDATE DIM_TEMPO 
		SET DIA = '0' + DIA 
		WHERE LEN(DIA) = 1 

		UPDATE DIM_TEMPO 
		SET MES = '0' + MES 
		WHERE LEN(MES) = 1 

		UPDATE DIM_TEMPO 
		SET DATACOMPLETA = ANO + MES + DIA 
		GO

		select * from DIM_TEMPO

		----------------------------------------------
		----------FINS DE SEMANA E ESTA��ES-----------
		----------------------------------------------

		DECLARE C_TEMPO CURSOR FOR	
			SELECT IDSK, DATACOMPLETA, DIASEMANA, ANO FROM DIM_TEMPO
		DECLARE			
					@ID INT,
					@DATA varchar(10),
					@DIASEMANA VARCHAR(20),
					@ANO CHAR(4),
					@FIMSEMANA CHAR(3),
					@ESTACAO VARCHAR(15)
					
		OPEN C_TEMPO
			FETCH NEXT FROM C_TEMPO
			INTO @ID, @DATA, @DIASEMANA, @ANO
		WHILE @@FETCH_STATUS = 0
		BEGIN
			
					 IF @DIASEMANA in ('Domingo','S�bado') 
						SET @FIMSEMANA = 'Sim'
					 ELSE 
						SET @FIMSEMANA = 'N�o'

					--ATUALIZANDO ESTACOES

					IF @DATA BETWEEN CONVERT(CHAR(4),@ano)+'0923' 
					AND CONVERT(CHAR(4),@ANO)+'1220'
						SET @ESTACAO = 'Primavera'

					ELSE IF @DATA BETWEEN CONVERT(CHAR(4),@ano)+'0321' 
					AND CONVERT(CHAR(4),@ANO)+'0620'
						SET @ESTACAO = 'Outono'

					ELSE IF @DATA BETWEEN CONVERT(CHAR(4),@ano)+'0621' 
					AND CONVERT(CHAR(4),@ANO)+'0922'
						SET @ESTACAO = 'Inverno'

					ELSE -- @data between 21/12 e 20/03
						SET @ESTACAO = 'Ver�o'

					--ATUALIZANDO FINS DE SEMANA
	
					UPDATE DIM_TEMPO SET FIMSEMANA = @FIMSEMANA
					WHERE IDSK = @ID

					--ATUALIZANDO

					UPDATE DIM_TEMPO SET ESTACAOANO = @ESTACAO
					WHERE IDSK = @ID
		
			FETCH NEXT FROM C_TEMPO
			INTO @ID, @DATA, @DIASEMANA, @ANO	
		END
		CLOSE C_TEMPO
		DEALLOCATE C_TEMPO
		GO