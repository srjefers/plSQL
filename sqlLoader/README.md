# SqlLoader creado con Pl/SQL

En algunos casos llegara el momento en el cual sera necesario hacer **CARGAS MASIVAS**  de datos a la base de datos, partiendo de este punto podemos deducir
que SqlLOADER es una excelente opcion para la carga de datos, pero con la desventaje que SqlLoader no te permitira analizar los datos que seran cargados
masivamente, quizas puedas utilizar una herramienta ETL para poder cargar datos y analizarlos pero en algunos casos no tendras el privilegio de hacerlo, 
este procedimiento almacenado es creado con ese fin; analizar los datos que son cargados desde un archivo de texto plano en cualquier formato [txt, cvs, etc].

Se ha tratado de hacerlo lo mas optimizado posible, para que este no afecte el *performence* de la base de datos.

## Como?

### REGEXP_REPLACE

*([cadena], [expresionRegular], [cadena que remplazara])*
Permite resolver la inconsistencia de archivos, en los cuales dos separadores esten juntos sin ningun
elemento que pueda dividirlos, es necesario para remplazar esos separadores con un elemento entre ellos 
y asi el funcionamiento sea normal. Sin esta la cadena se correra una posicion a la izquiera y generar
una inconsistencia de datos.
[Documentacion](https://docs.oracle.com/cd/B19306_01/server.102/b14200/functions130.htm)


### regexp_substr

*([cadena], [expresionRegular], [posicion], [ocurrencia])*
Permite separar la cadena separando por cada elemento segun la expresion regular.
Esta funcion es la que hace mayor parte dentro del procedimiento.
[Documentacion](https://docs.oracle.com/cd/B12037_01/server.101/b10759/functions116.htm)  


### INSTR

*([cadena], [cadena a buscar], [ocurrencia])*
Permite leer la candena y retornar indice donde la *cadena a buscar* sea encontrada. 
La ocurrencia determinara cuantas veces se buscara.
Esta funcion permite analizar la cadena antes de que se separe cada dato. Optimiza codigo reduciendo la cantidad
de lineas debido a que determinara que cadena son erroneas y que cadenas son perfectas para se utilizadas por *REGEXP_SUBSTR*
[Documentacion](https://docs.oracle.com/cd/B19306_01/server.102/b14200/functions068.htm)


### UTL_FILE.FILE_TYPE

*([directorio], [archivo], [modo lectura/escritura])*
Permite la lectura del archivo ademas determina el modo con el que se trabajara.
[Documentacion](https://docs.oracle.com/cd/B19306_01/appdev.102/b14258/u_file.htm)

### Porque no estas usando TRIGGERS para los ID's

Para esta vez he considerado que no es necesario el uso de TRIGGERS, debido a que un trigger podria llegar a causar un mal 
impacto en la integridad de la data procesado, debido a que al realizar un `SELECT SEQUENCE FROM DUAL` esta no puede regresar 
a su valor anterior.

## Lista de cosas por hacer :)

* Buscar una mayor optimizacion
* Asegurar la transaccionalidad [COMMIT/ROLLBACK]


