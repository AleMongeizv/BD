--1)Escribe una funci�n para la base de datos tienda que devuelva el n�mero total de productos que hay en la 
--tabla productos.
CREATE FUNCTION FN_TOTAL_PRODUCTOS()
RETURNS INT
AS
BEGIN
    DECLARE @total_productos INT;

    SELECT @total_productos = COUNT(*)
    FROM producto;

    RETURN @total_productos;
END;

-- Llamada a la funci�n para obtener el n�mero total de productos
DECLARE @total_productos INT;
SET @total_productos = DBO.FN_TOTAL_PRODUCTOS();
PRINT 'El n�mero total de productos es: ' + CAST(@total_productos AS VARCHAR);


--2)Escribe una funci�n para la base de datos tienda que devuelva el valor medio del precio de los productos de un 
--determinado fabricante que se recibir� como par�metro de entrada. El par�metro de entrada ser� el nombre del fabricante.
CREATE FUNCTION FN_VALOR_MEDIO(@nombre_fabricante VARCHAR(100))
RETURNS DECIMAL(10, 2) -- Ajusta la precisi�n y la escala seg�n tus necesidades
AS
BEGIN
    DECLARE @valor_medio DECIMAL(10, 2);

  
    SELECT @valor_medio = AVG(precio)
    FROM producto
    WHERE fabricante = @nombre_fabricante;

    RETURN @valor_medio;
END;
--
DECLARE @fabricante VARCHAR(100) = 'NombreDelFabricante';
DECLARE @valor_medio_precio DECIMAL(10, 2);
SET @valor_medio_precio = DBO.FN_VALOR_MEDIO('ASUS');
PRINT 'El valor medio del precio de los productos del fabricante ' + @fabricante + ' es: ' + CAST(@valor_medio_precio AS VARCHAR);



--3) Escribe una funci�n para la base de datos tienda que devuelva el valor m�ximo del precio de los productos de un determinado 
--fabricante que se recibir� como par�metro de entrada. El par�metro de entrada ser� el nombre del fabricante.
CREATE FUNCTION FN_VALOR_MAXIMO(@nombre_fabricante VARCHAR(100))
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @valor_maximo DECIMAL(10, 2);
    SELECT @valor_maximo = MAX(precio)
    FROM producto
    WHERE nombre = @nombre_fabricante;

    RETURN @valor_maximo;
END;
-- Llamada a la funci�n para obtener el valor m�ximo del precio de los productos de un fabricante
DECLARE @fabricante NVARCHAR(100) = 'NombreDelFabricante';
DECLARE @valor_maximo_precio DECIMAL(10, 2);
SET @valor_maximo_precio = dbo.obtener_valor_maximo_precio_por_fabricante(@fabricante);
PRINT 'El valor m�ximo del precio de los productos del fabricante ' + @fabricante + ' es: ' + CAST(@valor_maximo_precio AS VARCHAR);




--4. Escribe una funci�n para la base de datos tienda que devuelva el valor m�nimo del precio de los productos de un determinado 
--fabricante que se recibir� como par�metro de entrada. El par�metro de entrada ser� el nombre del fabricante.
CREATE FUNCTION obtener_valor_minimo_precio_por_fabricante(@nombre_fabricante NVARCHAR(100))
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @valor_minimo DECIMAL(10, 2);

    -- Obtener el valor m�nimo del precio de los productos del fabricante especificado
    SELECT @valor_minimo = MIN(precio)
    FROM tienda.productos
    WHERE fabricante = @nombre_fabricante;

    RETURN @valor_minimo;
END;
--
DECLARE @fabricante NVARCHAR(100) = 'NombreDelFabricante';
DECLARE @valor_minimo DECIMAL(10, 2);
SET @valor_minimo = dbo.obtener_valor_minimo_precio_por_fabricante(@fabricante);
PRINT 'El valor m�nimo del precio de los productos del fabricante ' + @fabricante + ' es: ' + CAST(@valor_minimo AS VARCHAR);