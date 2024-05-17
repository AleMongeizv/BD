--Ejercicio 1
--Crear bd y alumnos
CREATE DATABASE test;

USE test;

CREATE TABLE alumnos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(255),
    apellido1 NVARCHAR(255),
    apellido2 NVARCHAR(255),
    nota FLOAT
);

--trigger 1
CREATE TRIGGER triggerchecknotabeforeinsert
ON alumnos
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO alumnos (nombre, apellido1, apellido2, nota)
    SELECT 
        nombre, 
        apellido1, 
        apellido2, 
        CASE 
            WHEN nota < 0 THEN 0 
            WHEN nota > 10 THEN 10 
            ELSE nota 
        END
    FROM inserted;
END;

--trigger 2
CREATE TRIGGER triggerchecknotabeforeupdate
ON alumnos
INSTEAD OF UPDATE
AS
BEGIN
    UPDATE alumnos
    SET 
        nombre = inserted.nombre,
        apellido1 = inserted.apellido1,
        apellido2 = inserted.apellido2,
        nota = CASE 
                  WHEN inserted.nota < 0 THEN 0 
                  WHEN inserted.nota > 10 THEN 10 
                  ELSE inserted.nota 
               END
    FROM alumnos
    INNER JOIN inserted ON alumnos.id = inserted.id;
END;

-- Intento de inserción con una nota negativa (se ajustará a 0)
INSERT INTO alumnos (nombre, apellido1, apellido2, nota) VALUES ('Juan', 'Perez', 'Gomez', -5);

-- Intento de inserción con una nota mayor a 10 (se ajustará a 10)
INSERT INTO alumnos (nombre, apellido1, apellido2, nota) VALUES ('Maria', 'Lopez', 'Sanchez', 12);

-- Inserción con una nota dentro del rango permitido (se mantendrá igual)
INSERT INTO alumnos (nombre, apellido1, apellido2, nota) VALUES ('Luis', 'Garcia', 'Martinez', 7);

-- Actualizar la nota de un alumno a un valor negativo (se ajustará a 0)
UPDATE alumnos SET nota = -3 WHERE id = 3;

-- Actualizar la nota de un alumno a un valor mayor a 10 (se ajustará a 10)
UPDATE alumnos SET nota = 15 WHERE id = 1;

-- Actualizar la nota de un alumno a un valor dentro del rango permitido (se mantendrá igual)
UPDATE alumnos SET nota = 8 WHERE id = 2;

SELECT * FROM alumnos;


--Ejercicio 2
CREATE DATABASE test2;

USE test2;

CREATE TABLE alumnos (
    id INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(255),
    apellido1 NVARCHAR(255),
    apellido2 NVARCHAR(255),
    email NVARCHAR(255)
);

CREATE PROCEDURE crearemail
    @nombre NVARCHAR(255),
    @apellido1 NVARCHAR(255),
    @apellido2 NVARCHAR(255),
    @dominio NVARCHAR(255),
    @email NVARCHAR(255) OUTPUT
AS
BEGIN
    SET @email = 
        LOWER(LEFT(@nombre, 1) + 
              LEFT(@apellido1, 3) + 
              LEFT(@apellido2, 3) + 
              '@' + 
              @dominio);
END;

CREATE TRIGGER triggercrearemailbeforeinsert
ON alumnos
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @nombre NVARCHAR(255);
    DECLARE @apellido1 NVARCHAR(255);
    DECLARE @apellido2 NVARCHAR(255);
    DECLARE @dominio NVARCHAR(255) = 'example.com';  
    DECLARE @email NVARCHAR(255);

    DECLARE inserted_cursor CURSOR FOR 
    SELECT nombre, apellido1, apellido2, email 
    FROM inserted;

    OPEN inserted_cursor;

    FETCH NEXT FROM  inserted_cursor INTO @nombre, @apellido1, @apellido2, @email;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @email IS NULL
        BEGIN
            EXEC crearemail @nombre, @apellido1, @apellido2, @dominio, @email OUTPUT;
        END

        INSERT INTO alumnos (nombre, apellido1, apellido2, email)
        VALUES (@nombre, @apellido1, @apellido2, @email);

        FETCH NEXT FROM inserted_cursor INTO @nombre, @apellido1, @apellido2, @email;
    END;

    CLOSE inserted_cursor;
    DEALLOCATE inserted_cursor;
END;

-- Inserción con el email proporcionado (se mantendrá igual)
INSERT INTO alumnos (nombre, apellido1, apellido2, email) VALUES ('Juan', 'Perez', 'Gomez', 'jpezgom@example.com');

-- Inserción sin email (se generará automáticamente)
INSERT INTO alumnos (nombre, apellido1, apellido2, email) VALUES ('Maria', 'Lopez', 'Sanchez', NULL);

-- Inserción sin email (se generará automáticamente)
INSERT INTO alumnos (nombre, apellido1, apellido2, email) VALUES ('Luis', 'Garcia', 'Martinez', NULL);

SELECT * FROM alumnos;
