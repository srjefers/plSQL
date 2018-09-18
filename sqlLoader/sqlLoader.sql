-- [tabla].[campo]%TYPE;

CREATE TABLE CARGA_MASIVA(
    ID_CARGA_MASIVA         INT NOT NULL,
    CADENA_1                VARCHAR2(15) NOT NULL,
    CADENA_2                VARCHAR2(15),
    CADENA_3                VARCHAR2(15),
    CADENA_4                VARCHAR2(15),
    CONSTRAINT PK_CARGA_MASIVA PRIMARY KEY (ID_CARGA_MASIVA)
);

SET SERVEROUTPUT ON;
DECLARE
-- Variables de archivo
VALORES VARCHAR2(32767);
F1 UTL_FILE.FILE_TYPE;  
-- Variables manejo de datos
 CADENA1         CARGA_MASIVA.CADENA_1%TYPE;
 CADENA2         CARGA_MASIVA.CADENA_2%TYPE;
 CADENA3         CARGA_MASIVA.CADENA_3%TYPE;
 CADENA4         CARGA_MASIVA.CADENA_4%TYPE;
-- Variables control de datos
CONT INT;
VALIDACION INTEGER;
VALIDACION_INI INTEGER;
CADENA_CORREGIDA VARCHAR2(100);
BEGIN
    CONT := 0;
    VALIDACION := 0;

    -- ([directorio], [archivo], [modo lectura/escritura])
    F1 := UTL_FILE.FOPEN('DP1', 'pruebas.txt', 'R');
    IF UTL_FILE.IS_OPEN(F1) THEN
        dbms_output.put_line('->> YPA!');               
        LOOP
            BEGIN
                -- Se obtiene cada linea, tomando en cuenta que sera linea a linea 
                -- por lo tanto por cada iteracion se procedera a leer otra linea
                UTL_FILE.GET_LINE(F1,VALORES);
                -- Omitiendo cabeceras/titulos de columnas del archivo
                IF (CONT <> '0')  THEN

                    -- Se analiza el archivo para determinar el Indice/Posicion donde
                    -- se encuentre la cadena buscada
                    -- ([cadena], [cadena a buscar], [ocurrencia])
                    VALIDACION := INSTR(VALORES,'||', 1);
                    VALIDACION_INI := INSTR(VALORES,'|',1);
                
                    -- En la siguientes validaciones se pretende evitar trabajo de mas,
                    -- eso significa que segun las validaciones anteriores estas redireccionaran
                    -- a distintos bloques de codigo para su procesado
                    IF VALIDACION <= 1 THEN
                        SELECT nvl(regexp_substr(VALORES, '[^|]+', 1, 1), 'vacia'), 
                            nvl(regexp_substr(VALORES, '[^|]+', 1, 2), 'vacia'),
                            nvl(regexp_substr(VALORES, '[^|]+', 1, 3), 'vacia'),
                            nvl(regexp_substr(VALORES, '[^|]+', 1, 4), 'vacia')
                        INTO CADENA1, CADENA2,
                        CADENA3,CADENA4
                        FROM dual;

                        /*dbms_output.put_line(CADENA1||'---'||CADENA2||'---'||
                        CADENA3||'---'||CADENA4||'++++');*/
                    ELSIF VALIDACION_INI = 1 THEN
                        -- En el caso que la primer posicion sea nula, esa se omitira o se 
                        -- procesara de forma distinta
                        dbms_output.put_line('###');
                    ELSE
                        -- ([cadena erronea], [resultado], [separador])
                        CORRIGE_CADENAS(VALORES, CADENA_CORREGIDA, '|');
                        CORRIGE_CADENAS(CADENA_CORREGIDA, CADENA_CORREGIDA, '|');
                        SELECT nvl(regexp_substr(CADENA_CORREGIDA, '[^|]+', 1, 1), 'vacia'), 
                            nvl(regexp_substr(CADENA_CORREGIDA, '[^|]+', 1, 2), 'vacia'),
                            nvl(regexp_substr(CADENA_CORREGIDA, '[^|]+', 1, 3), 'vacia'),
                            nvl(regexp_substr(CADENA_CORREGIDA, '[^|]+', 1, 4), 'vacia')
                        INTO CADENA1, CADENA2,
                        CADENA3,CADENA4
                        FROM dual;
                        /*dbms_output.put_line(CADENA1||'---'||CADENA2||'---'||
                        CADENA3||'---'||CADENA4||'++++');*/
                        
                    END IF;                     

                    INSERT INTO CARGA_MASIVA VALUES ((SELECT NVL(MAX(ID_CARGA_MASIVA),0)+1 
                    FROM CARGA_MASIVA), CADENA1, CADENA2, CADENA3, CADENA4);

                END IF;
                CONT := CONT + 1;

                -- Detiene la lectura del archivo al no encontrar nada y sale del LOOP
                EXCEPTION WHEN No_Data_Found THEN EXIT;
            END;
        END LOOP;       
    ELSE
        dbms_output.put_line('Error al abrir el archivo');
    END IF;
    UTL_FILE.FCLOSE(F1); 
END;
/


-- El procedimiento CORRIGE_CADENAS analizara la *cadena erronea* y por medio de REGEX buscara los errores
-- para porteriormente sustituirlos con *el separador de cadena* cero *el separador de cadena*
CREATE OR REPLACE PROCEDURE CORRIGE_CADENAS (
    CADENA_ERRONEA IN VARCHAR2,
    CADENA_SOLUCION OUT VARCHAR2,
    FORMATO_SEPARADOR IN VARCHAR2)
AS
BEGIN
    CADENA_SOLUCION := REGEXP_REPLACE(CADENA_ERRONEA, '(\'||FORMATO_SEPARADOR||'){2,2}', '\2'||FORMATO_SEPARADOR||'0'||FORMATO_SEPARADOR||'');
END;
/