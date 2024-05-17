--1. Realice los siguientes procedimientos y funciones sobre la base de datos jardineria.
--a.
--� Funci�n: calcular_precio_total_pedido
--� Descripci�n: Dado un c�digo de pedido la funci�n debe calcular la suma total del
--pedido. Tenga en cuenta que un pedido puede contener varios productos diferentes y
--varias cantidades de cada producto.
--� Par�metros de entrada: codigo_pedido (INT)
--� Par�metros de salida: El precio total del pedido (FLOAT)
DROP FUNCTION FN_calcular_precio_total_pedido;
CREATE FUNCTION FN_calcular_precio_total_pedido(@codigo_pedido INT)
RETURNS FLOAT
AS
BEGIN
--SELECT  SUM(PRECIO_UNIDAD *CANTIDAD) AS SUMA_TOTAL
    DECLARE @precio_total FLOAT;
    SELECT @precio_total = SUM(D.precio_unidad* D.cantidad )
    FROM detalle_pedido D
    WHERE codigo_pedido = @codigo_pedido;

    RETURN @precio_total;
END;
DECLARE @precio_total_pedido FLOAT;
SET @precio_total_pedido = DBO.FN_calcular_precio_total_pedido(1);

--b.
--� Funci�n: calcular_suma_pedidos_cliente
--� Descripci�n: Dado un c�digo de cliente la funci�n debe calcular la suma total de todos
--los pedidos realizados por el cliente. Deber� hacer uso de la funci�n
--calcular_precio_total_pedido que ha desarrollado en el apartado anterior.
--� Par�metros de entrada: codigo_cliente (INT)
--� Par�metros de salida: La suma total de todos los pedidos del cliente (FLOAT)
IF OBJECT_ID('FN_calcular_suma_pedidos_cliente') IS NOT NULL
BEGIN
	DROP FUNCTION FN_calcular_suma_pedidos_cliente
END 
GO

CREATE FUNCTION FN_calcular_suma_pedidos_cliente(@codigo_cliente INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @suma_pedidos_cliente FLOAT;
    RETURN (SELECT SUM(DBO.FN_calcular_precio_total_pedido(codigo_pedido))
    FROM pedido
    WHERE codigo_cliente = @codigo_cliente)

END;

--LLAMADA A LA FUNCION
SELECT DISTINCT	codigo_cliente,DBO.FN_calcular_suma_pedidos_cliente(CODIGO_PEDIDO) FROM pedido

--c.
--� Funci�n: calcular_suma_pagos_cliente
--� Descripci�n: Dado un c�digo de cliente la funci�n debe calcular la suma total de los
--pagos realizados por ese cliente.
--� Par�metros de entrada: codigo_cliente (INT)
--� Par�metros de salida: La suma total de todos los pagos del cliente (FLOAT)
IF OBJECT_ID('FN_calcular_suma_pagos_cliente') IS NOT NULL
BEGIN
	DROP FUNCTION FN_calcular_suma_pagos_cliente
END 
GO

CREATE FUNCTION FN_calcular_suma_pagos_cliente(@codigo_cliente INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @suma_pagos_cliente FLOAT;
    SELECT @suma_pagos_cliente = SUM(p.total)
    FROM pago p
    WHERE codigo_cliente = @codigo_cliente;

    RETURN @suma_pagos_cliente;
END;

--Llamada 
DECLARE @suma_pagos_cliente FLOAT;

SET @suma_pagos_cliente = DBO.FN_calcular_suma_pagos_cliente(@codigo_cliente);
PRINT 'La suma total de los pagos del cliente ' + CAST(@suma_pagos_cliente AS VARCHAR);

--d.
--� Procedimiento: calcular_pagos_pendientes
--� Descripci�n: Deber� calcular los pagos pendientes de todos los clientes. Para saber si
--un cliente tiene alg�n pago pendiente deberemos calcular cu�l es la cantidad de todos
--los pedidos y los pagos que ha realizado. Si la cantidad de los pedidos es mayor que
--la de los pagos entonces ese cliente tiene pagos pendientes.
IF OBJECT_ID('calcular_pagos_pendientes') IS NOT NULL
BEGIN
	DROP PROCEDURE calcular_pagos_pendientes
END 
GO

CREATE TABLE clientes_calcular_pagos_pendientes (
id_cliente VARCHAR(10),
suma_total_pedidos FLOAT,
suma_total_pagos FLOAT,
pendiente_pago FLOAT
)

CREATE PROCEDURE calcular_pagos_pendientes
AS
BEGIN
	DELETE FROM clientes_calcular_pagos_pendientes
	INSERT INTO clientes_calcular_pagos_pendientes SELECT codigo_cliente, DBO.FN_calcular_suma_pedidos_cliente(codigo_cliente),
	DBO.FN_calcular_suma_pagos_cliente(codigo_cliente),DBO.FN_calcular_suma_pedidos_cliente(codigo_cliente) - DBO.FN_calcular_suma_pagos_cliente(codigo_cliente)
	FROM pedido
END
GO

EXEC calcular_pagos_pendientes
SELECT * FROM clientes_calcular_pagos_pendientes

--2
IF OBJECT_ID('FN_obtener_numero_empleados') IS NOT NULL
BEGIN
	DROP PROCEDURE FN_obtener_numero_empleados
END 
GO

CREATE PROCEDURE FN_obtener_numero_empleados
    @codigo_oficina VARCHAR(10)
AS
BEGIN
    SELECT E.numero_ = COUNT(*)
    FROM empleado E
    WHERE codigo_oficina = @codigo_oficina;

END;

--Llamada
EXEC DBO.FN_obtener_numero_empleados 'BCN-ES';


--3
IF OBJECT_ID('FN_cantidad_total_de_productos_vendidos') IS NOT NULL
BEGIN
	DROP PROCEDURE FN_cantidad_total_de_productos_vendidos
END 
GO

CREATE FUNCTION FN_cantidad_total_de_productos_vendidos
    (@codigo_producto INT)
RETURNS INT
AS
BEGIN
    RETURN(SELECT SUM(cantidad)
    FROM detalle_pedido
    WHERE codigo_producto = @codigo_producto)
END;

--Llamada
SELECT DBO.FN_cantidad_total_de_productos_vendidos('OR-141') AS cantidad_vendida;

--1. Crea una base de datos llamada cine que contenga dos tablas con las siguientes columnas.
--Tabla cuentas:
--� id_cuenta: entero sin signo (clave primaria).
--� saldo: real sin signo.
--Tabla entradas:
--� id_butaca: entero sin signo (clave primaria).
--� nif: cadena de 9 caracteres.
--Una vez creada la base de datos y las tablas deber� crear un procedimiento llamado comprar_entrada con las siguientes caracter�sticas
--El procedimiento recibe 3 par�metros de entrada (nif, id_cuenta, id_butaca) y devolver� como salida un
--par�metro llamado error que tendr� un valor igual a 0 si la compra de la entrada se ha podido realizar con �xito 
--y un valor igual a 1 en caso contrario.
--El procedimiento de compra realiza los siguientes pasos:
--� Inicia una transacci�n.
--� Actualiza la columna saldo de la tabla cuentas cobrando 5 euros a la cuenta con el
--id_cuenta adecuado.
--� Inserta una una fila en la tabla entradas indicando la butaca (id_butaca) que acaba
--de comprar el usuario (nif).
--� Comprueba si ha ocurrido alg�n error en las operaciones anteriores. Si no ocurre
--ning�n error entonces aplica un COMMIT a la transacci�n y si ha ocurrido alg�n error aplica un ROLLBACK.

--FUNCIONES
--Base de datos: Jardiner�a
--1. Escriba una funci�n llamada contar_productos que reciba como entrada el nombre de la gama y devuelva el n�mero 
--de productos que existen dentro de esa gama.
IF OBJECT_ID('FN_contar_productos') IS NOT NULL
BEGIN
	DROP FUNCTION FN_contar_productos
END
GO

CREATE FUNCTION FN_contar_productos(@nombre_gama VARCHAR(20))
RETURNS INT
AS
BEGIN
	RETURN (SELECT COUNT(*) FROM producto WHERE gama = @nombre_gama)
END

--Llamada
SELECT gama, DBO.FN_contar_productos(gama) as NUMERO_PRODUCTOS FROM gama_producto

--2. Escribe un procedimiento que se llame calcular_max_min_media, que reciba como par�metro de entrada el nombre de la 
--gama de un producto y devuelva como salida tres par�metros
--El precio m�ximo, el precio m�nimo y la media de los productos que existen en esa gama.
CREATE PROCEDURE calcular_max_min_media(@gama varchar(20))
SELECT MAX(precio_venta) as maximo, min(precio_venta) as minimo, avg(precio_venta) as media from producto where producto.gama = @gama)























