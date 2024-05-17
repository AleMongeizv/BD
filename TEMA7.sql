--ACTIVIDAD 4
--1. Crear un script que busque si existen empleados con el apellido2 ‘Carrasco’. En caso afirmativo, debe mostrar su nombre completo. Si no, debe aparecer un mensaje: “No hay ningún empleado con el apellido2= Carrasco”
USE jardineria
GO
DECLARE @apellido2 VARCHAR(50) = 'Carrasco'

IF EXISTS (SELECT nombre, apellido1, apellido2
			FROM EMPLEADO E
			WHERE apellido2 = @apellido2)
BEGIN
			SELECT nombre, apellido1, apellido2
			FROM EMPLEADO E
			WHERE apellido2 = @apellido2
END 
ELSE 
	PRINT 'No hay ningun empleado con apellido2 = Carrasco'

--2 Se necesita implementar un código de programación que permita mostrar una condición de acuerdo al total de productos por tipo de unidad. Si la cantidad es menor a 10, mostrar el mensaje “Condición: iniciar reporte”; en caso contrario, mostrar el mensaje
--“Condición: conforme”. El resultado se debe mostrar de la siguiente forma:
USE BDVENTAS
GO
DECLARE @unidad VARCHAR (3) = 'UNI', @TOTAL INT
SELECT @TOTAL = COUNT(*) FROM PRODUCTO
	GROUP BY UNI_PRO
	HAVING  UNI_PRO = @UNIDAD
PRINT  'EL TIPO DE UNIDAD' + @UNIDAD
PRINT 'TIENE UN TOTAL DE ' +CAST  (@TOTAL AS VARCHAR(5)) + 'PRODUCTOS'
IF @TOTAL > 0 AND @TOTAL < 10
				PRINT 'CONDICION :INICIAR DEPORTE'
			ELSE
				PRINT 'CONDICION : CONFORME'

--ACTIVIDAD 5
--1) Crear una variable @dia que contendrá un valor numérico del 1 al 7 con los días de la semana. El valor 1 corresponde a lunes, el valor 2 a martes, etc. Imprime por pantalla el día en texto, correspondiente a cada número. Si el número no corresponde con ningún día de la semana, imprimir un error “El número de día no es correcto”
DECLARE @dia INT = 3; -- Por ejemplo, para el martes

SELECT CASE 
    WHEN @dia = 1 THEN 'Lunes'
    WHEN @dia = 2 THEN 'Martes'
    WHEN @dia = 3 THEN 'Miércoles'
    WHEN @dia = 4 THEN 'Jueves'
    WHEN @dia = 5 THEN 'Viernes'
    WHEN @dia = 6 THEN 'Sábado'
    WHEN @dia = 7 THEN 'Domingo'
    ELSE 'El número de día no es correcto'
END AS Dia;

--ACTIVIDAD 6
USE BDVENTAS
GO
--1) Se necesita listar el código, nombre del vendedor, sueldo, fecha de fin y fecha de fin en letras con el formato: DD MES_EN_LETRA AAAA




--ACTIVIDAD 7
--1)Recorrer los números del 1 al 20 y mostrar los que son pares con el mensaje: “El número x es par”
DECLARE @CONT INT = 1

WHILE (@CONT <= 20)
BEGIN 
		IF @CONT % 2 = 0
		PRINT 'EL NUMERO ' + CAST(@CONT AS VARCHAR(2)) + ' ES PAR';
		SET @CONT +=1;
END

--2) Implementar un Script que permita aumentar en 10% el coste de las tarifas solo si el promedio de estas no supera los 200, cuando se termine de actualizar dichos valores mostrar el mensaje “YA NO HAY MÁS QUE ACTUALIZAR”.
USE jardineria
GO

DECLARE @CONT INT = 1

WHILE (SELECT AVG(PRECIO_UNIDAD) FROM detalle_pedido) < 200
BEGIN
--Actualizar el precio de cada detalle_pedido
UPDATE detalle_pedido SET precio_unidad = precio_unidad*1.1

END 
PRINT 'Ya no hay mas que actualizar'

ROLLBACK 

--ACTIVIDAD 8
USE jardineria
GO
--1)  Modificar la tabla gama_producto, añadiendo el código_gama como se indica:
--aromáticas --> ARO01
--frutales --> FRU02
--herbaceas --> HER03
--ornamentales --> ORN04
--otros –> 00
--Utilizar la estructura condicional múltiple CASE
ALTER TABLE Gama_producto ADD Codigo_gama VARCHAR(10);

UPDATE gama_producto SET Codigo_gama = 
CASE
	WHEN gama = 'Aromaticas' THEN 'ARO1'
	WHEN gama = 'Frutales' THEN 'FRU02'
	WHEN gama = 'Herbaceas' THEN 'HER03'
	WHEN gama = 'Ornamentales' THEN 'ORN04'
	ELSE '00'
END

--2)Para los pagos realizados en el año 2008 con PayPal, aumentar el total un 10%
BEGIN TRAN
DECLARE @TABLA TABLE (total INT, fecha_pago DATE, forma_pago VARCHAR(40))
INSERT INTO @TABLA (total, fecha_pago, forma_pago) SELECT total, fecha_pago, forma_pago FROM pago WHERE YEAR(fecha_pago) = 2008 AND  forma_pago= 'PayPal';
DECLARE @COUNT INT = (SELECT COUNT(*) FROM @TABLA)
WHILE @COUNT > 0
BEGIN

	DECLARE @total INT = (SELECT TOP(1) total FROM @Tabla ORDER BY total)
	DECLARE @fecha_pago DATE = (SELECT TOP(1) fecha_pago FROM @Tabla ORDER BY fecha_pago)
	DECLARE @forma_pago VARCHAR(40) = (SELECT TOP(1) forma_pago FROM @Tabla ORDER BY forma_pago)

--Actualizar la tabla pago con el nuevo total
	UPDATE pago SET total = total * 1.1  

--Se borra el registro que temporal
	DELETE FROM @Tabla WHERE total =@total
	SET @COUNT = (SELECT COUNT(*) FROM @TABLA)
	COMMIT
 END


 --ACTIVIDAD 10
USE BDVENTAS
--1. Realizar una función para mostrar el nombre del distrito a partir del código del mismo.
-- Realizar una llamada a la función para el código del distrito D01
CREATE FUNCTION FN_MOSTRARDISTRITO(@CODIGO CHAR(5))
RETURNS CHAR(5)
BEGIN
	RETURN(SELECT NOM_DIS FROM DISTRITO  WHERE @CODIGO = COD_DIS)
	END

SELECT DBO.MOSTRARDISTRITO ('D01') AS NOMBRE_DISTRITO

SELECT COD_CLI, CON_CLI
-- Realizar una llamada a la función para mostrar los campos código, cliente, distrito y RUC
--2. Realizar una función que muestre la fecha de facturación en letras







--TRIGGERS
--ACTIVIDAD 12
--1) Implemente un trigger que permita controlar la eliminación de un registro de la tabla CLIENTE, en la cual si 
--dicho cliente tiene facturas registradas no permita su eliminación mostrando un mensaje caso contrario mostrar
--el mensaje de eliminación correcta.
CREATE TRIGGER TX_ELIMIA_REGISTRO
ON CLIENTE 
INSTEAD OF DELETE
AS
IF (SELECT COUNT(*) FROM deleted D INNER JOIN FACTURA F ON D.codigo_cliente = F.COD_CLI
	WHERE D.codigo_cliente = F.COD_CLI)>0
	BEGIN
	PRINT 'NO SE PUEDE ELIMINAR EL REGISTRO PORQUE EL CLIENTE TIENE FACTURAS ASOCIADAS'
	END;
ELSE 
BEGIN
	DELETE FROM cliente WHERE codigo_cliente = (SELECT codigo_cliente FROM deleted)	
	PRINT 'REGISTRO ELIMINADO'
END;

BEGIN TRAN
DELETE cliente WHERE codigo_cliente='C002'
ROLLBACK


--2) Implemente un trigger que permita controlar el registro de un detalle de factura en la cual se evalué la cantidad registrada para que no se
--registre un valor inferior a cero en la columna cantidad de venta.
ECLARE @DISTRITO VARCHAR(30),@COD CHAR(5)
SELECT @DISTRITO=NOM_DIS FROM INSERTED
ROLLBACK
SELECT @COD=COD_DIS FROM DISTRITO
WHERE DISTRITO.NOM_DIS=@DISTRITO
PRINT 'NOMBRE DE DISTRITO YA REGISTRADO EN LA TABLA'
PRINT 'EL DISTRITO '+@DISTRITO+
 ' SE ENCUENTRA REGISTRADO CON EL CODIGO: '+@COD
END
ELSE
PRINT 'DISTRITO REGISTRADO CORRECTAMENTE'

--3)Implemente un trigger que permita crear una replica de los registros insertados en la tabla PROVEEDOR para dicho proceso debe
--implementar una nueva tabla llamada PROVEEDOR_BAK con las mismas columnas que la tabla PROVEEDOR.
-- Crear la tabla PROVEEDOR_BAK si no existe
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PROVEEDOR_BAK')
BEGIN
    CREATE TABLE PROVEEDOR_BAK (
        Id INT PRIMARY KEY,
        Nombre NVARCHAR(100),
        Direccion NVARCHAR(200),
        -- Agrega aquí las mismas columnas que tiene la tabla PROVEEDOR
        -- Asegúrate de que coincidan en tipo y longitud
    );
END
GO

-- Crear el trigger para insertar registros en PROVEEDOR_BAK
IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = 'InsertarProveedorBak')
BEGIN
    CREATE TRIGGER InsertarProveedorBak
    ON PROVEEDOR
    AFTER INSERT
    AS
    BEGIN
        SET NOCOUNT ON;
        
        -- Insertar los registros insertados en la tabla PROVEEDOR_BAK
        INSERT INTO PROVEEDOR_BAK (Id, Nombre, Direccion )
        SELECT Id, Nombre, Direccion 
        FROM inserted;
    END;
END
GO



--En la base de datos BDVENTAS:
-- Crear una nueva columna de 50 caracteres en la tabla vendedor que sea EMAIL
-- Recorrer los vendedores que hay en la tabla y actualizar este campo con el siguiente formato:
--• Primer carácter de la columna NOM_VENTA
--• Concatenar el valor de la columna APE_VEN
--• Añadir @miempresa.com
ALTER TABLE VENDEDOR ADD EMAIL VAR(50)
DECLARE @c1 CHAR (1), @c2 VARCHAR(20), @cod char(5)

DECLARE C_VENDEDOR CURSOR FOR
	SELECET LEFT (V.NOMBRE_VEN,1), V.APE_VEN, V.COD_vEN FROM VENDEDOR V

OPEN C_VENDEDOR
FETCH C_VENDEDOR INTO @c1,@c2@cod
WHILE @@FETCH_STATUS =0
BEGIN
		UPDATE VENDEDOR SET EMAIL = @c1,@c2+'@miempresa.com' WHERE COD_VEN = @COD
		FETCH C_VENDEDOR INTO @c1,c2,cod
END 
CLOSE C_VENDEDOR
DEALLOCATE C_VENDEDOR



--En la base de datos BDVENTAS:
--Obtener para cada vendedor, el listado de los clientes a los que les han vendido.
--El formato será:
--VENDEDOR: Nombre vendedor 1
--CODIGO CLIENTE DIRECCION TELEFONO
-----------------------------------------------------------
--…
--VENDEDOR: Nombre vendedor 2
--CODIGO CLIENTE DIRECCION TELEFONO
-----------------------------------------------------------
--…

DECLARE @N_VENDEDOR VARCHAR(50)
DECLARE @COD_CLI CHAR(5)
DECLARE @DIRECCION VARCHAR(100)
DECLARE @TELEFONO CHAR(9)

DECLARE C_VENDEDOR




























































































CREATE PROCEDURE ListadoClientesPorVendedor()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE vendedor_id INT;
    DECLARE vendedor_nombre VARCHAR(100);
    DECLARE cliente_id INT;
    DECLARE cliente_nombre VARCHAR(100);
    DECLARE cliente_direccion VARCHAR(100);
    DECLARE cliente_telefono VARCHAR(100);
    
    -- Declarar cursor para recorrer los vendedores
    DECLARE vendedores_cursor CURSOR FOR SELECT COD_VEN, NOM_VENTA FROM vendedor;
    -- Declarar handler para manejar el final del cursor
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Iniciar proceso de recorrido
    OPEN vendedores_cursor;
    
    -- Iniciar bucle para recorrer vendedores
    vendedores_loop: LOOP
        -- Obtener datos del vendedor actual
        FETCH vendedores_cursor INTO vendedor_id, vendedor_nombre;
        
        -- Si no hay más vendedores, salir del bucle
        IF done THEN
            LEAVE vendedores_loop;
        END IF;
        
        -- Mostrar encabezado del vendedor
        SELECT CONCAT('VENDEDOR: ', vendedor_nombre);
        
        -- Declarar cursor para obtener clientes del vendedor actual
        DECLARE clientes_cursor CURSOR FOR
            SELECT c.COD_CLI, c.NOM_CLI, c.DIRECCION, c.TELEFONO
            FROM cliente c
            WHERE c.COD_VEN = vendedor_id;
        
        -- Iniciar proceso de recorrido de clientes
        OPEN clientes_cursor;
        
        -- Iniciar bucle para recorrer clientes
        clientes_loop: LOOP
            -- Obtener datos del cliente actual
            FETCH clientes_cursor INTO cliente_id, cliente_nombre, cliente_direccion, cliente_telefono;
            
            -- Si no hay más clientes, salir del bucle
            IF done THEN
                LEAVE clientes_loop;
            END IF;
            
            -- Mostrar detalles del cliente
            SELECT CONCAT(cliente_id, ' ', cliente_nombre, ' ', cliente_direccion, ' ', cliente_telefono);
        END LOOP clientes_loop;
        
        -- Cerrar cursor de clientes
        CLOSE clientes_cursor;
        
        -- Mostrar separador entre vendedores
        SELECT '---------------------------------------------------------';
    END LOOP vendedores_loop;
    
    -- Cerrar cursor de vendedores
    CLOSE vendedores_cursor;
END$$

DELIMITER ;
