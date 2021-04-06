USE Practica1;

/*CONSULTA 1*/
SELECT h.nombreHospital, d.direccion, COUNT(v.codVictima) FROM Hospital AS h 
	INNER JOIN VictimaHospital AS vh ON vh.codHospital = h.codHospital
    INNER JOIN Victima AS v ON v.codVictima = vh.codVictima
    INNER JOIN Direccion AS d ON d.codDireccion = h.codDireccion
	WHERE v.codEstado = 11
    GROUP BY h.nombreHospital, d.direccion;
    
/*CONSULTA 2*/
SELECT DISTINCT v.nombre, v.apellido FROM Victima AS v
	INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima
    WHERE tv.efectividadVictima > 5 AND
    tv.codTratamiento = 4 AND
    v.codEstado = 5;
    
/*CONSULTA 3*/
SELECT v.nombre, v.apellido, d.direccion FROM Victima AS v
	INNER JOIN Direccion AS d ON d.codDireccion = v.codDireccion
    INNER JOIN Contacto AS c ON v.codVictima = c.codVictima
    WHERE v.codEstado = 11
    GROUP BY v.nombre, v.apellido, d.direccion
    HAVING COUNT(codAsociado) > 3;

/*CONSULTA 4*/
SELECT v.nombre, v.apellido FROM Victima AS v
	INNER JOIN Contacto AS c ON v.codVictima = c.codVictima
	WHERE v.codEstado = 14 AND 
    c.codTipoContacto = 4
    GROUP BY v.nombre, v.apellido
    HAVING COUNT(codAsociado) > 2;

/*CONSULTA 5*/
SELECT v.codVictima, v.nombre, v.apellido FROM Victima AS v
	INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima
    WHERE tv.codTratamiento = 3
    GROUP BY codVictima
    ORDER BY COUNT(tv.codTratamiento) DESC
    LIMIT 5;

/*CONSULTA 6*/
SELECT DISTINCT v.nombre, v.apellido, v.fechaMuerte FROM Victima AS v
	INNER JOIN Ubicacion AS u ON u.codVictima = v.codVictima
    INNER JOIN Direccion AS d ON d.codDireccion = u.codDireccion
    INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima
    WHERE tv.codTratamiento = 2 AND
    d.direccion = '1987 Delphine Well' AND
    v.fechaMuerte != '1790-01-02 00:00:00';
    
/*CONSULTA 7*/
SELECT v.nombre, v.apellido, d.direccion FROM Victima AS v
	INNER JOIN Direccion AS d ON d.codDireccion = v.codDireccion
    INNER JOIN Contacto AS c ON c.codVictima = v.codDireccion
    INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima
    INNER JOIN VictimaHospital AS vh ON vh.codVictima = v.codVictima
    GROUP BY v.nombre, v.apellido, d.direccion
    HAVING COUNT(c.codAsociado) <= 2 AND COUNT(tv.codTratamiento) <= 2;

/*CONSULTA 8*/
SELECT * FROM (
	SELECT MONTH(v.fechaPrimeraSospecha) AS 'mes', v.nombre, v.apellido FROM Victima AS v
		INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima
        GROUP BY MONTH(v.fechaPrimeraSospecha), v.nombre, v.apellido
        ORDER BY COUNT(tv.codTratamiento) ASC
        LIMIT 5
) t1
UNION ALL
SELECT * FROM (
	SELECT MONTH(v.fechaPrimeraSospecha) AS 'mes', v.nombre, v.apellido FROM Victima AS v
		INNER JOIN TratamientoVictima AS tv ON tv.codVictima = v.codVictima
        GROUP BY MONTH(v.fechaPrimeraSospecha), v.nombre, v.apellido
        ORDER BY COUNT(tv.codTratamiento) DESC
        LIMIT 5
) t2;

/*CONSULTA 9*/
SELECT CONCAT(COUNT(codVictima)/(SELECT COUNT(codVictima) FROM VictimaHospital) * 100, '%') AS Porcentaje 
	FROM VictimaHospital 
	GROUP BY codHospital;
    
/*CONSULTA 10*/
SELECT DISTINCT nombreHospital, MAX(promedio), tc.tipoContacto FROM (    
	SELECT h.nombreHospital, tc.tipoContacto, COUNT(c.codVictima)/(SELECT COUNT(codVictima) FROM Contacto) * 100 promedio FROM Contacto AS c
	INNER JOIN TipoContacto AS tc ON tc.codTipoContacto = c.codTipoContacto
    INNER JOIN VictimaHospital AS vh ON vh.codVictima = c.codVictima
    INNER JOIN Hospital AS h ON h.codHospital = vh.codHospital
    GROUP BY h.nombreHospital, tc.tipoContacto
) t1
INNER JOIN TipoContacto AS tc ON tc.tipoContacto = t1.tipoContacto
GROUP BY nombreHospital, tc.tipoContacto
HAVING MAX(promedio)
ORDER BY MAX(promedio) DESC;