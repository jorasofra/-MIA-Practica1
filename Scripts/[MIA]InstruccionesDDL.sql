CREATE DATABASE Practica1;
USE Practica1;

CREATE TABLE Direccion(
	codDireccion INT AUTO_INCREMENT,
    direccion VARCHAR(150),
    CONSTRAINT PK_Direccion PRIMARY KEY (codDireccion)
);

CREATE TABLE Hospital(
	codHospital INT AUTO_INCREMENT,
    nombreHospital VARCHAR(75),
    codDireccion INT,
    CONSTRAINT PK_Hospital PRIMARY KEY (codHospital),
    CONSTRAINT FK_Dir_Hospital FOREIGN KEY (codDireccion) REFERENCES Direccion(codDireccion)
);

CREATE TABLE Estado(
	codEstado INT AUTO_INCREMENT,
    estado VARCHAR(40),
    CONSTRAINT PK_Estado PRIMARY KEY (codEstado)
);

CREATE TABLE Victima(
	codVictima INT AUTO_INCREMENT,
    nombre VARCHAR(25),
    apellido VARCHAR(25),
    codDireccion INT,
    fechaPrimeraSospecha DATETIME,
    fechaConfirmacion DATETIME,
    fechaMuerte DATETIME NULL,
    codEstado INT,
    CONSTRAINT PK_Victima PRIMARY KEY (codVictima),
    CONSTRAINT FK_Dir_Victima FOREIGN KEY (codDireccion) REFERENCES Direccion(codDireccion),
    CONSTRAINT FK_Est_Victima FOREIGN KEY (codEstado) REFERENCES Estado(codEstado)
);

CREATE TABLE Asociado(
	codAsociado INT AUTO_INCREMENT,
    nombre VARCHAR(25),
    apellido VARCHAR(25),
    CONSTRAINT PK_Asociado PRIMARY KEY (codAsociado)
);

CREATE TABLE TipoContacto(
	codTipoContacto INT AUTO_INCREMENT,
    tipoContacto VARCHAR(20),
    CONSTRAINT PK_Tipo_Contacto PRIMARY KEY (codTipoContacto)
);

CREATE TABLE Contacto(
	codAsociado INT,
    codVictima INT,
    codTipoContacto INT, 
    inicioContacto DATETIME,
    finContacto DATETIME,
    fechaConocio DATETIME,
    CONSTRAINT PK_Contacto PRIMARY KEY (codAsociado, codVictima, inicioContacto),
    CONSTRAINT FK_Asoc_Contacto FOREIGN KEY (codAsociado) REFERENCES Asociado(codAsociado),
    CONSTRAINT FK_Vic_Contacto FOREIGN KEY (codVictima) REFERENCES Victima(codVictima),
    CONSTRAINT FK_TipConta_Contacto FOREIGN KEY (codTipoContacto) REFERENCES TipoContacto(codTipoContacto)
);

CREATE TABLE Ubicacion(
	codVictima INT,
    codDireccion INT,
    fechaLlegada DATETIME,
    fechaRetiro DATETIME,
    CONSTRAINT PK_Ubicacion PRIMARY KEY (codVictima, codDireccion, fechaLlegada),
    CONSTRAINT FK_Victima FOREIGN KEY (codVictima) REFERENCES Victima(codVictima),
    CONSTRAINT FK_Direccion FOREIGN KEY (codDireccion) REFERENCES Direccion(codDireccion)
);

CREATE TABLE Tratamiento(
	codTratamiento INT AUTO_INCREMENT,
    tratamiento VARCHAR(25),
    efectividad INT, 
    CONSTRAINT PK_Tratamiento PRIMARY KEY (codTratamiento)
);

CREATE TABLE TratamientoVictima(
	codVictima INT,
    codTratamiento INT,
    fechaInicio DATETIME,
    fechaFin DATETIME,
    efectividadVictima INT,
    CONSTRAINT PK_Tratamiento_Victima PRIMARY KEY (codVictima, codTratamiento, fechaInicio),
    CONSTRAINT FK_Vic_Tratamiento_Victima FOREIGN KEY (codVictima) REFERENCES Victima(codVictima),
    CONSTRAINT FK_Trat_Tratamiento_Victima FOREIGN KEY (codTratamiento) REFERENCES Tratamiento(codTratamiento)
);

CREATE TABLE VictimaHospital(
	codHospital INT, 
    codVictima INT,
    CONSTRAINT PK_Victima_Hospital PRIMARY KEY (codHospital, codVictima),
    CONSTRAINT FK_Vic_Victima_Hospital FOREIGN KEY (codVictima) REFERENCES Victima(codVictima),
    CONSTRAINT FK_Hos_Victima_Hospital FOREIGN KEY (codHospital) REFERENCES Hospital(codHospital)
);
