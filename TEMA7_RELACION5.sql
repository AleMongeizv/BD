--1) Escribe un procedimiento que reciba el nombre de un pa�s como par�metro de entrada y realice una consulta sobre
--la tabla cliente para obtener todos los clientes que existen en la tabla de ese pa�s.
IF OBJECT_ID ('CONSULTA_PAIS') IS NOT NULL
BEGIN
	DROP PROCEDURE CONSULTA_PAIS
END 
GO

CREATE PROCEDURE CONSULTA_PAIS(@PAIS VARCHAR(30))
AS
SELECT * FROM cliente WHERE pais = @PAIS
GO

EXEC CONSULTA_PAIS('')
--2) Escribe un procedimiento que reciba como par�metro de entrada una forma de pago, que ser� una cadena de caracteres
--(Ejemplo: PayPal, Transferencia, etc). Y devuelva como salida el pago de m�ximo valor realizado para esa forma de pago. 
IF OBJECT_ID ('PAGO_MAXIMO') IS NOT NULL
BEGIN
	DROP PROCEDURE PAGO_MAXIMO
END 
GO

CREATE PROCEDURE PAGO_MAXIMO(@FORMA_PAGO VARCHAR(20))
AS
SELECT MAX (p.total) AS MAXIMO_PAGO
FROM pago p
WHERE P.forma_pago = @FORMA_PAGO 

EXEC PAGO_MAXIMO @FORMA_PAGO = 'PayPal'

--3) Escribe un procedimiento que reciba como par�metro de entrada una forma de pago, que ser� una cadena de caracteres
--(Ejemplo: PayPal, Transferencia, etc). Y devuelva como salida los siguientes valores teniendo en cuenta la forma de pago seleccionada
--como par�metro de entrada:
--� el pago de m�ximo valor,
--� el pago de m�nimo valor,
--� el valor medio de los pagos realizados,
--� la suma de todos los pagos,
--� el n�mero de pagos realizados para esa forma de pago.
IF OBJECT_ID ('DATOS_PAGO') IS NOT NULL
BEGIN
	DROP PROCEDURE DATOS_PAGO
END 
GO

CREATE PROCEDURE DATOS_PAGO(@FORMA_PAGO VARCHAR(30))
AS
SELECT MAX (p.total) AS MAXIMO_PAGO, MIN(P.total) AS PAGO_MINIMO, AVG(P.total) AS MEDIA_PAGO, SUM(P.total) AS SUMA_PAGOS, COUNT(P.total) AS NUM_PAGOS
FROM pago p
WHERE P.forma_pago = @FORMA_PAGO 

EXEC DATOS_PAGO @FORMA_PAGO = 'PayPal'

--Crea una base de datos llamada cine que contenga dos tablas con las siguientes columnas.
--Tabla cuentas:
--� id_cuenta: entero sin signo (clave primaria).
--� saldo: real sin signo.

--Tabla entradas:
--� id_butaca: entero sin signo (clave primaria).
--� nif: cadena de 9 caracteres.

--Una vez creada la base de datos y las tablas deber� crear un procedimiento llamado comprar_entrada con las siguientes
--caracter�sticas. El procedimiento recibe 3 par�metros de entrada (nif, id_cuenta, id_butaca)
-- y devolver� como salida un par�metro llamado error que tendr� un valor igual a 0 si la compra de la entrada se ha
--podido realizar con �xito y un valor igual a 1 en caso contrario. El procedimiento de compra realiza los siguientes pasos:
--� Inicia una transacci�n.
--� Actualiza la columna saldo de la tabla cuentas cobrando 5 euros a la cuenta con el
--id_cuenta adecuado.
--� Inserta una una fila en la tabla entradas indicando la butaca (id_butaca) que acaba
--de comprar el usuario (nif).
--� Comprueba si ha ocurrido alg�n error en las operaciones anteriores. Si no ocurre
--ning�n error entonces aplica un COMMIT a la transacci�n y si ha ocurrido alg�n error aplica un ROLLBACK.