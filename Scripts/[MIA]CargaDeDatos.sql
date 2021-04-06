USE Practica1;

/*
    PARA PODER LEER EL ARCHIVO DESDE MYSQL EN CONSOLA
    SET GLOBAL local_infile=1;
    quit
    mysql --local-infile=1 -u root -p 
*/


/*TABLA TEMPORAL PARA TODOS LOS DATOS DEL CSV*/
CREATE TEMPORARY TABLE Temporal(
	nombre_victima VARCHAR(25),
    apellido_victima VARCHAR(25),
    direccion_victima VARCHAR(150),
    fecha_primera_sospecha DATETIME NULL,
    fecha_confirmacion DATETIME NULL,
    fecha_muerte DATETIME NULL,
    estado_victima VARCHAR(40),
    nombre_asociado VARCHAR(25),
    apellido_asociado VARCHAR(25),
    fecha_conocio DATETIME,
    contacto_fisico VARCHAR(20),
    fecha_inicio_contacto DATETIME,
    fecha_fin_contacto DATETIME,
    nombre_hospital VARCHAR(75),
    direccion_hospital VARCHAR(150),
    ubicacion_victima VARCHAR(150),
    fecha_llegada DATETIME,
    fecha_retiro DATETIME,
    tratamiento VARCHAR(25),
    efectividad INT,
    fecha_inicio_tratamiento DATETIME,
    fecha_fin_tratamiento DATETIME,
    efectividad_en_victima INT
);

/*TABLA TEMPORAL PARA COLOCAR LAS DIRECCIONES*/
CREATE TEMPORARY TABLE Temp_Direcciones(
	direccion VARCHAR(150)
);

/*CARGA DEL ARCHIVO CSV A LA TABLA TEMPORAL*/
LOAD DATA LOCAL INFILE '/home/jorasofra/Escritorio/[MIA]Practica1/Scripts/data.csv'
	INTO TABLE Temporal
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES;
    
/*INSERT DE LAS DIRECCIONES DE LAS VICTIMAS A LA TEMPORAL DE DIRECCIONES*/
INSERT INTO Temp_Direcciones (direccion)
    SELECT DISTINCT direccion_victima FROM Temporal 
    WHERE direccion_victima != '' 
    ORDER BY direccion_victima;

/*INSERT DE LAS DIRECCIONES DE LOS HOSPITALES A LA TEMPORAL DE DIRECCIONES*/
INSERT INTO Temp_Direcciones (direccion)
    SELECT DISTINCT direccion_hospital FROM Temporal 
    WHERE direccion_hospital != '' 
    ORDER BY direccion_hospital;

/*INSERT DE LAS DIRECCIONES DE LAS UBICACIONES A LA TEMPORAL DE DIRECCIONES*/    
INSERT INTO Temp_Direcciones (direccion)
    SELECT DISTINCT ubicacion_victima FROM Temporal 
    WHERE ubicacion_victima != '' 
    ORDER BY ubicacion_victima;    
    
/*INSERT DE TODAS LAS DIRECCIONES Y UBICACIONES EN LA TABLA DE DIRECCIONES*/
INSERT INTO Direccion (direccion) 
	SELECT DISTINCT * FROM Temp_Direcciones;
    
/*INSERT DE LOS HOSPITALES Y SUS DIRECCIONES*/
INSERT INTO Hospital (nombreHospital, codDireccion)
	SELECT DISTINCT t.nombre_hospital, d.codDireccion FROM Temporal AS t 
    INNER JOIN Direccion AS d 
    ON t.direccion_hospital = d.direccion 
    ORDER BY t.nombre_hospital;
    
/*INSERT DE LOS ESTADOS DE LAS VICTIMAS*/
INSERT INTO Estado (estado)
	SELECT DISTINCT estado_victima FROM Temporal
    WHERE estado_victima != ''
    ORDER BY estado_victima;
    
/*INSERT DE LOS TRATAMIENTOS Y SU EFECTIVIDAD*/
INSERT INTO Tratamiento (tratamiento, efectividad)
	SELECT DISTINCT tratamiento, efectividad FROM Temporal
    WHERE tratamiento != ''
    ORDER BY tratamiento;
    
/*INSERT DE LOS TIPOS DE CONTACTO FISICO*/
INSERT INTO TipoContacto (tipoContacto)
	SELECT DISTINCT contacto_fisico FROM Temporal
    WHERE contacto_fisico != ''
    ORDER BY contacto_fisico;
    
/*INSERT DE LOS ASOCIADOS*/
INSERT INTO Asociado (nombre, apellido)
	SELECT DISTINCT nombre_asociado, apellido_asociado FROM Temporal 
    WHERE apellido_asociado != ''
    ORDER BY nombre_asociado;
    
/*INSERT DE LAS VICTIMAS QUE NO HAN MUERTO*/
INSERT INTO Victima (nombre, apellido, codDireccion, fechaPrimeraSospecha, fechaConfirmacion, fechaMuerte, codEstado)
	SELECT DISTINCT t.nombre_victima, t.apellido_victima, d.codDireccion, 
		t.fecha_primera_sospecha, 
        t.fecha_confirmacion, 
        t.fecha_muerte, e.codEstado
	FROM Temporal AS t
    INNER JOIN Direccion AS d ON t.direccion_victima = d.direccion
    INNER JOIN Estado AS e ON t.estado_victima = e.estado
	WHERE t.nombre_victima != '' AND 
    t.apellido_victima != ''
    ORDER BY t.nombre_victima;

/*INSERT DE LOS TRATAMIENTOS DE LAS VÍCTIMAS*/
INSERT INTO TratamientoVictima (codVictima, codTratamiento, fechaInicio, fechaFin, efectividadVictima)
	SELECT DISTINCT v.codVictima, t.codTratamiento, tp.fecha_inicio_tratamiento, tp.fecha_fin_tratamiento, 
	tp.efectividad_en_victima 
	FROM Temporal AS tp 
    INNER JOIN Victima AS v ON v.nombre = tp.nombre_victima 
    INNER JOIN Tratamiento AS t ON t.tratamiento = tp.tratamiento 
    ORDER BY v.codVictima;
    
/*INSERT DE LAS UBICACIONES DE LA VICTIMA*/
INSERT INTO Ubicacion (codVictima, codDireccion, fechaLlegada, fechaRetiro)
	SELECT DISTINCT v.codVictima, d.codDireccion, t.fecha_llegada, t.fecha_retiro FROM Temporal AS t 
	INNER JOIN Victima AS v ON v.nombre = t.nombre_victima 
    INNER JOIN Direccion AS d ON d.direccion = t.ubicacion_victima 
    ORDER BY v.codVictima;

/*INSERT DE LOS CONTACTOS ENTRE ASOCIADOS Y VICTIMAS*/
INSERT INTO Contacto (codAsociado, codVictima, codTipoContacto, inicioContacto, finContacto, fechaConocio)
SELECT DISTINCT a.codAsociado, v.codVictima, tc.codTipoContacto, 
	tp.fecha_inicio_contacto, tp.fecha_fin_contacto, tp.fecha_conocio FROM Temporal AS tp
	INNER JOIN Asociado AS a ON a.nombre = tp.nombre_asociado
    INNER JOIN Victima AS v ON v.nombre = tp.nombre_victima
    INNER JOIN TipoContacto AS tc ON tc.tipoContacto = tp.contacto_fisico
    ORDER BY a.codAsociado;

/*INSERT DE LAS VICTIMAS EN HOSPITALES*/
INSERT INTO VictimaHospital (codHospital, codVictima)
	SELECT DISTINCT h.codHospital, v.codVictima FROM Temporal AS tp 
	INNER JOIN Victima AS v ON tp.nombre_victima = v.nombre 
    INNER JOIN Hospital AS h ON tp.nombre_hospital = h.nombreHospital 
    ORDER BY v.codVictima;
