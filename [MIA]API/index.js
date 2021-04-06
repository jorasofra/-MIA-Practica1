//EXPRESS
const express = require('express')
const app = express()
//MYSQL
const mysql = require('mysql')
//CSV
const fs = require('fs')
const csv = require('fast-csv')
const { response } = require('express')


function importCsvData(filename) {
    let stream = fs.createReadStream(filename)
    let csvData = []
    let csvStream = csv
        .parse()
        .on("data", function(data) {
            csvData.push(data)
        })
        .on("end", function(){
            csvData.shift()
            conexion.connect((error) => {
            let query = "INSERT INTO Temporal ( \
                nombre_victima, apellido_victima, direccion_victima, fecha_primera_sospecha, \
                fecha_confirmacion, fecha_muerte, estado_victima, nombre_asociado, apellido_asociado, \
                fecha_conocio, contacto_fisico, fecha_inicio_contacto, fecha_fin_contacto, nombre_hospital, \
                direccion_hospital, ubicacion_victima, fecha_llegada, fecha_retiro, tratamiento, efectividad, \
                fecha_inicio_tratamiento, fecha_fin_tratamiento, efectividad_en_victima) VALUES ?";
            conexion.query(query, [csvData], (error, response) => {
                console.log(error || response);
                });
            });
        });
    stream.pipe(csvStream);
}

var conexion = mysql.createConnection({
    host:'localhost',
    user:'root',
    password:'Admin123@',
    database:'Practica1',
    port:3306
})

app.get('/', function(req, res) {
    res.send('Practica 1, Manejo e Implementacion de Archivo')
})

app.get('/consulta1', function(req, res) {
    var consulta = "SELECT h.nombreHospital, d.direccion, COUNT(v.codVictima) conteo FROM Hospital AS h \
    INNER JOIN VictimaHospital AS vh ON vh.codHospital = h.codHospital \
    INNER JOIN Victima AS v ON v.codVictima = vh.codVictima \
    INNER JOIN Direccion AS d ON d.codDireccion = h.codDireccion \
    WHERE v.codEstado = 11 \
    GROUP BY h.nombreHospital, d.direccion;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    });
})

app.get('/consulta2', function(req, res) {
    var consulta = "SELECT DISTINCT v.nombre, v.apellido FROM Victima AS v \
	    INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima \
        WHERE tv.efectividadVictima > 5 AND \
        tv.codTratamiento = 4 AND \
        v.codEstado = 5;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/consulta3', function(req, res) {
    var consulta = "SELECT v.nombre, v.apellido, d.direccion FROM Victima AS v \
	    INNER JOIN Direccion AS d ON d.codDireccion = v.codDireccion \
        INNER JOIN Contacto AS c ON v.codVictima = c.codVictima \
        WHERE v.codEstado = 11 \
        GROUP BY v.nombre, v.apellido, d.direccion \
    HAVING COUNT(codAsociado) > 3;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/consulta4', function(req, res) {
    var consulta = "SELECT v.nombre, v.apellido FROM Victima AS v \
	    INNER JOIN Contacto AS c ON v.codVictima = c.codVictima \
	    WHERE v.codEstado = 14 AND \
        c.codTipoContacto = 4 \
        GROUP BY v.nombre, v.apellido \
        HAVING COUNT(codAsociado) > 2;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/consulta5', function(req, res) {
    var consulta = "SELECT v.codVictima, v.nombre, v.apellido FROM Victima AS v \
	    INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima \
        WHERE tv.codTratamiento = 3 \
        GROUP BY codVictima \
        ORDER BY COUNT(tv.codTratamiento) DESC \
        LIMIT 5;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/consulta6', function(req, res) {
    var consulta = "SELECT DISTINCT v.nombre, v.apellido, v.fechaMuerte FROM Victima AS v \
	    INNER JOIN Ubicacion AS u ON u.codVictima = v.codVictima \
        INNER JOIN Direccion AS d ON d.codDireccion = u.codDireccion \
        INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima \
        WHERE tv.codTratamiento = 2 AND \
        d.direccion = '1987 Delphine Well' AND \
        v.fechaMuerte != '1790-01-02 00:00:00';";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/consulta7', function(req, res) {
    var consulta = "SELECT v.nombre, v.apellido, d.direccion FROM Victima AS v \
	    INNER JOIN Direccion AS d ON d.codDireccion = v.codDireccion \
        INNER JOIN Contacto AS c ON c.codVictima = v.codDireccion \
        INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima \
        INNER JOIN VictimaHospital AS vh ON vh.codVictima = v.codVictima \
        GROUP BY v.nombre, v.apellido, d.direccion \
        HAVING COUNT(c.codAsociado) <= 2 AND COUNT(tv.codTratamiento) <= 2;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/consulta8', function(req, res) {
    var consulta = "SELECT * FROM ( \
        SELECT MONTH(v.fechaPrimeraSospecha) AS 'mes', v.nombre, v.apellido FROM Victima AS v \
            INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima \
            GROUP BY MONTH(v.fechaPrimeraSospecha), v.nombre, v.apellido \
            ORDER BY COUNT(tv.codTratamiento) ASC \
            LIMIT 5 \
        ) t1 \
        UNION ALL \
        SELECT * FROM ( \
            SELECT MONTH(v.fechaPrimeraSospecha) AS 'mes', v.nombre, v.apellido FROM Victima AS v \
                INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima \
                GROUP BY MONTH(v.fechaPrimeraSospecha), v.nombre, v.apellido \
                ORDER BY COUNT(tv.codTratamiento) DESC \
                LIMIT 5 \
        ) t2;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/consulta9', function(req, res) {
    var consulta = "SELECT CONCAT(COUNT(codVictima)/(SELECT COUNT(codVictima) FROM VictimaHospital) * 100, '%') AS Porcentaje \
	    FROM VictimaHospital  \
	    GROUP BY codHospital;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/consulta10', function(req, res) {
    var consulta = "SELECT DISTINCT nombreHospital, MAX(promedio), tc.tipoContacto FROM ( \
            SELECT h.nombreHospital, tc.tipoContacto, COUNT(c.codVictima)/(SELECT COUNT(codVictima) FROM Contacto) * 100 promedio FROM Contacto AS c \
            INNER JOIN TipoContacto AS tc ON tc.codTipoContacto = c.codTipoContacto \
            INNER JOIN VictimaHospital AS vh ON vh.codVictima = c.codVictima \
            INNER JOIN Hospital AS h ON h.codHospital = vh.codHospital \
            GROUP BY h.nombreHospital, tc.tipoContacto \
            )t1 \
            INNER JOIN TipoContacto AS tc ON tc.tipoContacto = t1.tipoContacto \
            GROUP BY nombreHospital, tc.tipoContacto \
            HAVING MAX(promedio) \
            ORDER BY MAX(promedio) DESC;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/eliminarTemporal', function(req, res) {
    var consulta = "DROP TABLE Temporal;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/eliminarModelo', function(req, res) {
    var consulta = "DROP TABLE Ubicacion; \
        DROP TABLE TratamientoVictima; \
        DROP TABLE Contacto; \
        DROP TABLE VictimaHospital; \
        DROP TABLE Tratamiento; \
        DROP TABLE TipoContacto; \
        DROP TABLE Asociado; \
        DROP TABLE Victima; \
        DROP TABLE Hospital; \
        DROP TABLE Estado; \
        DROP TABLE Direccion;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err;
        res.send(result);
    })
})

app.get('/cargarTemporal', function(req, res) {

    var temporal = "CREATE TEMPORARY TABLE Temporal( \
        nombre_victima VARCHAR(25), \
        apellido_victima VARCHAR(25), \
        direccion_victima VARCHAR(150), \
        fecha_primera_sospecha DATETIME NULL, \
        fecha_confirmacion DATETIME NULL, \
        fecha_muerte DATETIME NULL, \
        estado_victima VARCHAR(40), \
        nombre_asociado VARCHAR(25), \
        apellido_asociado VARCHAR(25), \
        fecha_conocio DATETIME, \
        contacto_fisico VARCHAR(20), \
        fecha_inicio_contacto DATETIME, \
        fecha_fin_contacto DATETIME, \
        nombre_hospital VARCHAR(75), \
        direccion_hospital VARCHAR(150), \
        ubicacion_victima VARCHAR(150), \
        fecha_llegada DATETIME, \
        fecha_retiro DATETIME, \
        tratamiento VARCHAR(25), \
        efectividad INT, \
        fecha_inicio_tratamiento DATETIME, \
        fecha_fin_tratamiento DATETIME, \
        efectividad_en_victima INT \
    ); \n";

    conexion.query(temporal, function(err, result) {
        if (err) throw err;
        res.send(result);
    })

    //IMPORTAR DATOS DE CSV
    importCsvData('data.csv');
})

app.get('/cargarModelo', function(req, res) {
    var consulta = "/*INSERT DE LAS DIRECCIONES DE LAS VICTIMAS A LA TEMPORAL DE DIRECCIONES*/ \
    INSERT INTO Temp_Direcciones (direccion) \
        SELECT DISTINCT direccion_victima FROM Temporal \
        WHERE direccion_victima != '' \
        ORDER BY direccion_victima; \
    /*INSERT DE LAS DIRECCIONES DE LOS HOSPITALES A LA TEMPORAL DE DIRECCIONES*/ \
    INSERT INTO Temp_Direcciones (direccion) \
        SELECT DISTINCT direccion_hospital FROM Temporal  \
        WHERE direccion_hospital != ''  \
        ORDER BY direccion_hospital; \
    /*INSERT DE LAS DIRECCIONES DE LAS UBICACIONES A LA TEMPORAL DE DIRECCIONES*/    \
    INSERT INTO Temp_Direcciones (direccion) \
        SELECT DISTINCT ubicacion_victima FROM Temporal  \
        WHERE ubicacion_victima != '' \
        ORDER BY ubicacion_victima;     \
    /*INSERT DE TODAS LAS DIRECCIONES Y UBICACIONES EN LA TABLA DE DIRECCIONES*/ \
    INSERT INTO Direccion (direccion) \
        SELECT DISTINCT * FROM Temp_Direcciones; \
    /*INSERT DE LOS HOSPITALES Y SUS DIRECCIONES*/ \
    INSERT INTO Hospital (nombreHospital, codDireccion) \
        SELECT DISTINCT t.nombre_hospital, d.codDireccion FROM Temporal AS t \
        INNER JOIN Direccion AS d \
        ON t.direccion_hospital = d.direccion \
        ORDER BY t.nombre_hospital; \
    /*INSERT DE LOS ESTADOS DE LAS VICTIMAS*/ \
    INSERT INTO Estado (estado) \
        SELECT DISTINCT estado_victima FROM Temporal \
        WHERE estado_victima != ''\
        ORDER BY estado_victima; \
    /*INSERT DE LOS TRATAMIENTOS Y SU EFECTIVIDAD*/ \
    INSERT INTO Tratamiento (tratamiento, efectividad) \
        SELECT DISTINCT tratamiento, efectividad FROM Temporal \
        WHERE tratamiento != '' \
        ORDER BY tratamiento; \
    /*INSERT DE LOS TIPOS DE CONTACTO FISICO*/ \
    INSERT INTO TipoContacto (tipoContacto) \
        SELECT DISTINCT contacto_fisico FROM Temporal \
        WHERE contacto_fisico != '' \
        ORDER BY contacto_fisico; \
    /*INSERT DE LOS ASOCIADOS*/ \
    INSERT INTO Asociado (nombre, apellido) \
        SELECT DISTINCT nombre_asociado, apellido_asociado FROM Temporal \
        WHERE apellido_asociado != ''\
        ORDER BY nombre_asociado;\
    /*INSERT DE LAS VICTIMAS QUE NO HAN MUERTO*/ \
    INSERT INTO Victima (nombre, apellido, codDireccion, fechaPrimeraSospecha, fechaConfirmacion, fechaMuerte, codEstado) \
        SELECT DISTINCT t.nombre_victima, t.apellido_victima, d.codDireccion, \
            t.fecha_primera_sospecha, \
            t.fecha_confirmacion, \
            t.fecha_muerte, e.codEstado \
        FROM Temporal AS t \
        INNER JOIN Direccion AS d ON t.direccion_victima = d.direccion \
        INNER JOIN Estado AS e ON t.estado_victima = e.estado \
        WHERE t.nombre_victima != '' AND \
        t.apellido_victima != '' \
        ORDER BY t.nombre_victima; \
    /*INSERT DE LOS TRATAMIENTOS DE LAS VÍCTIMAS*/ \
    INSERT INTO TratamientoVictima (codVictima, codTratamiento, fechaInicio, fechaFin, efectividadVictima) \
        SELECT DISTINCT v.codVictima, t.codTratamiento, tp.fecha_inicio_tratamiento, tp.fecha_fin_tratamiento, \
        tp.efectividad_en_victima \
        FROM Temporal AS tp \
        INNER JOIN Victima AS v ON v.nombre = tp.nombre_victima \
        INNER JOIN Tratamiento AS t ON t.tratamiento = tp.tratamiento  \
        ORDER BY v.codVictima; \
    /*INSERT DE LAS UBICACIONES DE LA VICTIMA*/ \
    INSERT INTO Ubicacion (codVictima, codDireccion, fechaLlegada, fechaRetiro) \
        SELECT DISTINCT v.codVictima, d.codDireccion, t.fecha_llegada, t.fecha_retiro FROM Temporal AS t \
        INNER JOIN Victima AS v ON v.nombre = t.nombre_victima \
        INNER JOIN Direccion AS d ON d.direccion = t.ubicacion_victima \
        ORDER BY v.codVictima; \
    /*INSERT DE LOS CONTACTOS ENTRE ASOCIADOS Y VICTIMAS*/ \
    INSERT INTO Contacto (codAsociado, codVictima, codTipoContacto, inicioContacto, finContacto, fechaConocio) \
    SELECT DISTINCT a.codAsociado, v.codVictima, tc.codTipoContacto, \
        tp.fecha_inicio_contacto, tp.fecha_fin_contacto, tp.fecha_conocio FROM Temporal AS tp \
        INNER JOIN Asociado AS a ON a.nombre = tp.nombre_asociado \
        INNER JOIN Victima AS v ON v.nombre = tp.nombre_victima \
        INNER JOIN TipoContacto AS tc ON tc.tipoContacto = tp.contacto_fisico \
        ORDER BY a.codAsociado; \
    /*INSERT DE LAS VICTIMAS EN HOSPITALES*/ \
    INSERT INTO VictimaHospital (codHospital, codVictima) \
        SELECT DISTINCT h.codHospital, v.codVictima FROM Temporal AS tp \
        INNER JOIN Victima AS v ON tp.nombre_victima = v.nombre \
        INNER JOIN Hospital AS h ON tp.nombre_hospital = h.nombreHospital \
        ORDER BY v.codVictima;";

    conexion.query(consulta, function(err, result) {
        if (err) throw err; 
        res.send(result);
    })
})

app.listen(3000, (err) => {
    console.log('Corriendo en el puerto ' + (3000))
})