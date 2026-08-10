CREATE DATABASE IF NOT EXISTS alumnos;
USE alumnos;

CREATE TABLE IF NOT EXISTS alumnos (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  fecha_nacimiento DATE NOT NULL
);

INSERT INTO alumnos (nombre, apellido, fecha_nacimiento) VALUES
  ('Juan', 'Perez', '2000-01-01'),
  ('Maria', 'Gomez', '1999-05-15'),
  ('Pedro', 'Lopez', '2001-10-20'),
  ('Ana', 'Martinez', '1998-03-08'),
  ('Luis', 'Rodriguez', '2002-07-12');
