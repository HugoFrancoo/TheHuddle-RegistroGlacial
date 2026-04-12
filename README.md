# TheHuddle-RegistroGlacial

Proyecto para el challenge de modelado y validacion SQL de Penguin Academy.

## 1) Motor elegido: PostgreSQL (justificacion tecnica)

Se eligio PostgreSQL porque:

- Permite integridad referencial real con `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL`.
- Soporta tipos `ENUM`, utiles para dominios cerrados como estado de pedido, moneda y metodo de pago.
- Tiene buen comportamiento para carga CSV (via `COPY`, scripts Python, herramientas ETL).
- Soporta indexacion robusta (indices simples y parciales).
- Es estable para escenarios transaccionales y auditoria.

Limitaciones relevantes:

- Requiere instalacion/configuracion previa.
- Si el volumen crece mucho, hay que planificar mantenimiento (vacuum, monitoreo de indices).
- Los errores de integridad durante una carga masiva exigen orden de insercion y manejo de transacciones.

## 2) Estructura del proyecto

- [01_schema_and_import.sql](C:\Users\Hugo Franco\Desktop\TheHuddle-RegistroGlacial\01_schema_and_import.sql): definicion del modelo relacional (tipos, tablas, PK/FK, CHECK, UNIQUE, indices).
- [02_validation_queries.sql](C:\Users\Hugo Franco\Desktop\TheHuddle-RegistroGlacial\02_validation_queries.sql): consultas estructurales y validaciones de integridad (sin agregaciones).
- [config.py](C:\Users\Hugo Franco\Desktop\TheHuddle-RegistroGlacial\config.py): variables de conexion desde `.env`.
- [postgres_connect.py](C:\Users\Hugo Franco\Desktop\TheHuddle-RegistroGlacial\postgres_connect.py): crea el schema ejecutando SQL.
- [load_data.py](C:\Users\Hugo Franco\Desktop\TheHuddle-RegistroGlacial\load_data.py): carga CSV en orden relacional.
- [requirements.txt](C:\Users\Hugo Franco\Desktop\TheHuddle-RegistroGlacial\requirements.txt): dependencias Python.

## 3) Como ejecutar

1. Crear un archivo `.env` en la raiz:

```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=prueba1
POSTGRES_USER=postgres
POSTGRES_PASSWORD=tu_password
```

2. Instalar dependencias:

```bash
python -m pip install -r requirements.txt
```

3. Crear tablas y constraints:

```bash
python postgres_connect.py
```

4. Cargar datos:

```bash
python load_data.py --replace
```

Opciones de carga:

- `--replace`: limpia tablas antes de cargar.
- `--safe-mode`: filtra relaciones rotas antes de insertar.
- Sin `--safe-mode`: modo estricto, deja que PostgreSQL rechace violaciones de integridad (recomendado para defender el challenge).

## 4) Criterio de diseño relacional

- Se separaron entidades principales: `customers`, `products`, `orders`, `order_items`, `payments`, `order_status_history`, `order_audit`.
- Se definieron PK naturales del dataset (`*_id`).
- Se definieron FK de dependencia:
  - `orders -> customers`
  - `order_items -> orders, products`
  - `payments -> orders`
  - `order_status_history -> orders`
  - `order_audit -> orders`
- Se agregaron `CHECK` para reglas de negocio (precios positivos, descuento valido, soft-delete coherente, etc.).
- Se agregaron indices en columnas usadas por joins y filtros frecuentes.

## 5) SQL Injection (explicacion para review)

### Como ocurre

Ocurre cuando se construye SQL concatenando texto ingresado por usuario.

Ejemplo inseguro:

```python
user_input = "' OR 1=1 --"
query = "SELECT * FROM customers WHERE email = '" + user_input + "'"
```

El input altera la consulta y puede devolver datos no autorizados, modificar registros o borrar informacion.

### Que practica la habilita

- Concatenar strings para construir SQL dinamico con input externo.
- No validar ni parametrizar consultas.

### Como se corrige

Usar consultas parametrizadas:

```python
cur.execute("SELECT * FROM customers WHERE email = %s", (user_input,))
```

Con parametros, el valor se trata como dato, no como parte del SQL ejecutable.

## 6) Que mostrar en la review

1. Modelo de tablas y relaciones en `01_schema_and_import.sql`.
2. Ejecucion de carga en modo estricto (`python load_data.py --replace`).
3. Consultas estructurales y de validacion en `02_validation_queries.sql`.
4. Explicacion de por que el motor elegido y como se evita SQL injection.
