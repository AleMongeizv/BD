USE RENTCAR
--1) Función que devuelva la media del monto(precio) de alquiler de un determinado año.
IF OBJECT_ID('FN_MEDIA_AÑO') IS NOT NULL
BEGIN
	DROP FUNCTION FN_PRODUCTOS
END
GO 

CREATE FUNCTION FN_MEDIA_AÑO(@año DATE)
RETURNS @año
AS
BEGIN
    DECLARE @media DECIMAL(10, 2);

    SELECT @media = AVG(a.MON_ALQ)
    FROM ALQUILER A
    WHERE YEAR(FEC_ALQ) = @año;

    RETURN @media;
END;

--Realizar una llamada a la función para mostrar la media del precio el año 2012
DECLARE @media_2012 DECIMAL(10, 2);
SET @media_2012 = DBO.FN_MEDIA_AÑO(2012);
PRINT 'La media del precio de alquiler para el año 2012 es: ' + CAST(@media_2012 AS VARCHAR);


--Realizar una llamada a la función para mostrar los campos año alquiler y promedio por año
SELECT YEAR(A.FEC_ALQ) AS año_alquiler, DBO.FN_MEDIA_AÑO(YEAR(A.FEC_ALQ)) AS promedio_por_año
FROM ALQUILER A
GROUP BY YEAR(FEC_ALQ);



--2) Función que permita mostrar el menor monto(precio) de alquiler en un determinado año.
CREATE FUNCTION FN_MENOR_PRECIO(@año DATE)
RETURNS MONEY
AS
BEGIN
        RETURN (SELECT AVG(MON_ALQ) AS PROMEDIO FROM ALQUILER WHERE YEAR(FEC_ALQ) = @año);
END;

-- Realizar una llamada a la función para mostrar el precio mínimo en el año 2012
SELECT DISTINCT YEAR(FEC_ALQ);
SET @precio_minimo_2012 = DBO.FN_MENOR_PRECIO(2012);
PRINT 'El precio mínimo de alquiler en el año 2012 es: ' + CAST(@precio_minimo_2012 AS VARCHAR);


-- Realizar una llamada a la función para mostrar los campos año alquiler y precio mínimo por año
SELECT YEAR(FEC_ALQ) AS año_alquiler, DBO.FN_MENOR_PRECIO(YEAR(fec_alq)) AS precio_minimo_por_año
FROM ALQUILER



-- 3) Función que permita mostrar el total de automóviles de un determinado color.
CREATE FUNCTION FN_COCHE_COLOR(@color VARCHAR(50))
RETURNS INT
AS
BEGIN
    RETURN(
	SELECT @total_automoviles = COUNT(*)    FROM AUTOMOVIL    WHERE COL_AUT = @color
	)
END;

--Realizar una llamada a la función para mostrar el color del automóvil y el total

SET @total_automoviles = DBO.FN_COCHE_COLOR(@color_automovil);
PRINT 'El total de automóviles de color ' + @color_automovil + ' es: ' + CAST(@total_automoviles AS VARCHAR);


--4) Función que permita mostrar la diferencia de años entre la fecha de alquiler y  el año actual
IF OBJECT_ID('FN_AÑOS_ALQUILER') IS NOT NULL
BEGIN
	DROP FUNCTION FN_AÑOS_ALQUILER
END
GO 

CREATE FUNCTION	FN_AÑOS_ALQUILER(@fecha DATE)
RETURNS INT
AS
BEGIN
    DECLARE @year INT;

    SET @year = YEAR(GETDATE());

    RETURN @year - YEAR(@fecha);
END;

--Realizar una llamada a la función para mostrar el alquiler, precio, fecha alquiler y diferencia en años
SELECT a.MON_ALQ , FEC_ALQ, DBO.FN_AÑOS_ALQUILER(FEC_ALQ) AS diferencia_anios
FROM ALQUILER a;


--5) Función tabla en línea que permita mostrar todos los registros de los clientes.
IF OBJECT_ID('FN_MOSTRARCLIENTE') IS NOT NULL
BEGIN
	DROP FUNCTION FN_MOSTRARCLIENTE
END
GO 

CREATE FUNCTION FN_MOSTRARCLIENTE(@ID VARCHAR(5))
RETURNS TABLE
AS
RETURN
(
    SELECT C.IDE_CLI AS CODIGO, CONCAT(C.NOM_CLI,' ',C.APE_CLI) AS CLIENTE, C.DNI_CLI AS DNI, C.TEL_CLI AS TELEFONO, D.DES_DIS AS DISTRITO, C.COR_CLI AS CORREO
    FROM CLIENTE C
	INNER JOIN DISTRITO D ON  C.IDE_DIS = D.IDE_DIS
	WHERE C.IDE_DIS = @ID
);

--Realizar una llamada a la función para mostrar los clientes de un determinado distrito
SELECT *
FROM DBO.FN_MOSTRARCLIENTE('L06')



--6) Impemente una función multisentencia que permita mostrar todos los registros de los automóviles
IF OBJECT_ID('FN_MOSTRAR_AUTOMOVIL') IS NOT NULL
BEGIN
	DROP FUNCTION FN_MOSTRAR_AUTOMOVIL
END
GO 

CREATE FUNCTION FN_MOSTRAR_AUTOMOVIL(@ID VARCHAR(7))
RETURNS TABLE
(

--7) Implemente una función multisentencia que permita mostrar todos los registros de los detalles de alquileres, con el nombre del cliente y el modelo y color del automóvil.
CREATE FUNCTION FN_DETALLE_ALQUILER()
RETURNS 
AS
BEGIN
    SELECT C.IDE_CLI AS NUMERO ,CONCAT(c.NOM_CLI, ' ', C.APE_CLI) AS CLIENTE, A.MAT_AUT AS AUTOMOVIL, a.MOD_AUT AS MODELO, a.COL_AUT AS COLOR
    FROM DETALLEALQUILER da
    INNER JOIN CLIENTE c ON da.IDE_CLI = c.IDE_CLI
    INNER JOIN AUTOMOVIL a ON da.MAT_AUT = a.MAT_AUT;
END;