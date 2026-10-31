# Reto Técnico QA Automation Senior – Depósito pasarela "Pago con QR"

> Preguntas 1 y 2 (Gherkin + etiquetado): ver [deposito_pago_qr.feature](deposito_pago_qr.feature)

---

## Pregunta 3 – Estrategias de prueba

### 3.1 Pruebas funcionales

| Estrategia | Qué valida en "Pago con QR" |
|---|---|
| **Pruebas funcionales de UI (E2E)** | Flujo completo: login → DEPOSITAR → Pago con QR → monto → SIGUIENTE → QR → pago → saldo actualizado. |
| **Pruebas de API / Servicios** | Endpoints de generación de QR, consulta de estado y callback/webhook de confirmación de la billetera (códigos HTTP, contrato JSON, validaciones de monto). |
| **Pruebas de integración** | Casino ↔ pasarela QR ↔ billeteras (Yape, Plin, +16) ↔ servicio de saldo. Uso de mocks/stubs para simular respuestas (aprobado, rechazado, timeout). |
| **Pruebas de base de datos** | Registro en `Depositos` (monto, moneda PEN, estado, fecha, UsuarioId) y transición de estados Pendiente → Exitoso / Fallido. |
| **Pruebas de humo (Smoke)** | Validación rápida post-despliegue del flujo principal (`@smoke`). |
| **Pruebas de regresión** | Suite automatizada (`@regression`) en cada release vía CI/CD. |
| **Pruebas exploratorias** | Sesiones time-boxed sobre comportamientos no documentados (refresh durante el QR, varias pestañas, etc.). |
| **Pruebas de aceptación (UAT / BDD)** | Escenarios Gherkin validados con negocio (PO). |
| **Pruebas de compatibilidad** | Navegadores (Chrome, Edge, Firefox, Safari) y dispositivos móviles/responsive (el QR debe verse y escanearse). |

### 3.2 Pruebas no funcionales

| Estrategia | Qué valida |
|---|---|
| **Performance – Carga** | Comportamiento con la carga esperada (ej. 100 usuarios concurrentes). |
| **Performance – Estrés** | Incremento progresivo hasta encontrar el punto de quiebre. |
| **Performance – Picos (Spike)** | Picos repentinos (promociones, quincena, eventos deportivos). |
| **Performance – Resistencia (Soak)** | Carga sostenida por horas (fugas de memoria, conexiones a BD). |
| **Seguridad** | OWASP Top 10: manipulación de monto, IDOR, reutilización de QR, XSS/SQLi, gestión de sesión, HTTPS, rate limiting. |
| **Usabilidad** | Claridad de mensajes, montos rápidos, instrucciones "¿Cómo depositar?". |
| **Accesibilidad** | WCAG 2.1 AA: contraste, navegación por teclado, lectores de pantalla. |
| **Confiabilidad / Resiliencia** | Reintentos, idempotencia, conciliación ante caídas de la pasarela. |

---

## Pregunta 4 – Herramientas

| Propósito | Herramienta |
|---|---|
| Gestión de pruebas y defectos | Jira + Xray / Zephyr |
| Diseño BDD | Gherkin + Cucumber |
| Automatización UI | Selenium WebDriver (Java) + Cucumber + JUnit, patrón Page Object Model (alternativas: Serenity BDD Screenplay, Playwright) |
| Automatización API | Postman, Karate |
| Mocks de la pasarela | WireMock / Postman Mock Server |
| Performance | Apache JMeter, k6 (alternativa: Gatling) |
| Seguridad | Burp Suite |
| Base de datos | SQL Server Management Studio (SSMS) |
| Compatibilidad cross-browser | BrowserStack / Selenium Grid |
| CI/CD y reportes | Jenkins / GitHub Actions / Azure DevOps, Allure / Cucumber Reports |
| Control de versiones | Git (GitHub / GitLab / Bitbucket) |
| DevTools / Proxy | Chrome DevTools (Network throttling, simulación offline) |

---

## Pregunta 5 – Técnicas de prueba de caja negra

### 5.1 Partición de equivalencia
Se divide el campo **"Otro monto"** en clases donde el sistema debe comportarse igual.

| Clase | Rango | Tipo | Ejemplo | Resultado esperado |
|---|---|---|---|---|
| CE1 | monto < 10 | Inválida | 5 | SIGUIENTE deshabilitado / mensaje de mínimo |
| CE2 | 10 ≤ monto ≤ 500 | **Válida** | 250 | Se genera el QR |
| CE3 | monto > 500 | Inválida | 800 | Mensaje de máximo S/500 |
| CE4 | No numérico | Inválida | "abc" | Monto inválido |
| CE5 | Vacío | Inválida | "" | SIGUIENTE deshabilitado |

### 5.2 Análisis de valores límite
Límites: **10** y **500** (2 decimales por `DECIMAL(10,2)`).

| Valor | Esperado |
|---|---|
| 9.99 | ❌ Rechazado |
| **10** | ✅ Aceptado |
| 10.01 | ✅ Aceptado |
| 499.99 | ✅ Aceptado |
| **500** | ✅ Aceptado |
| 500.01 | ❌ Rechazado |

### 5.3 Tabla de decisión

| Condición / Regla | R1 | R2 | R3 | R4 |
|---|---|---|---|---|
| Usuario autenticado | Sí | Sí | Sí | No |
| Monto entre 10 y 500 | Sí | Sí | No | – |
| Pasarela disponible | Sí | No | – | – |
| **Acción** | Genera QR (Pendiente) | Mensaje de error (Fallido) | SIGUIENTE deshabilitado | Redirige al login |

### 5.4 Transición de estados
Estados del depósito (tabla `Depositos.Estado`):

```
[Inicio] --genera QR--> Pendiente --pago confirmado--> Exitoso
                          |
                          +--timeout / expira / rechazo--> Fallido
```
Transiciones inválidas a probar: `Exitoso → Pendiente`, `Fallido → Exitoso` sin nuevo pago, `Exitoso → Exitoso` (reutilización del QR).

### 5.5 Casos de uso / Error guessing
- **Casos de uso:** flujo principal y alternos del Gherkin (Happy / Alternative Path).
- **Error guessing:** doble clic en SIGUIENTE, refresh con el QR abierto, montos con coma (`10,50`), espacios, números con muchos decimales, abrir el depósito en dos pestañas.

---

## Pregunta 6 – Evaluación técnica de performance

### 6.1 Objetivo
Validar que la generación del QR y el registro del depósito soportan la concurrencia esperada con un tiempo de respuesta **< 3 s** y encontrar el **punto de quiebre** del sistema.

### 6.2 Alcance (transacciones a medir)
1. Login (`POST /login`)
2. Carga de métodos de depósito
3. **Generación del QR** (`POST /deposit/qr`) ← transacción crítica
4. Consulta de estado del depósito (polling)
5. Callback / webhook de confirmación de pago

### 6.3 Ambiente y datos
- Ambiente de pre-producción con capacidad similar a producción (o escalado proporcional).
- Pasarela de pago **mockeada** con WireMock (latencia configurable) para no generar transacciones reales.
- Pool de **N usuarios de prueba** (CSV) para evitar bloqueos por sesión única.
- Monitoreo de servidores de aplicación y BD SQL Server (CPU, memoria, locks).

### 6.4 Tipos de prueba y escenarios

| Prueba | Configuración (ejemplo) | Objetivo |
|---|---|---|
| **Línea base** | 1 usuario, 10 iteraciones | Tiempo de referencia |
| **Carga** | 100 usuarios, ramp-up 5 min, 30 min sostenido | Validar SLA con carga esperada |
| **Estrés** | +50 usuarios cada 5 min hasta degradación (100 → 1000+) | Hallar punto de quiebre |
| **Picos (Spike)** | De 50 a 500 usuarios en 30 s | Reacción ante promociones |

### 6.5 Herramienta y ejecución
- **JMeter** (Thread Group / Ultimate Thread Group, CSV Data Set Config, extractores JSON para token e IdDeposito, aserciones de duración `< 3000 ms`)

### 6.6 Criterios de aceptación (SLA)
- p95 de generación del QR **< 3 s**; p99 < 5 s.
- Tasa de error **< 1 %**.
- Throughput ≥ el pico esperado de negocio (ej. 50 depósitos/s).
- CPU < 75 % y memoria estable en la prueba de carga.
- **Integridad:** cada depósito registrado una sola vez en `Depositos` (sin duplicados ni QR repetidos).

### 6.7 Entregable
Informe con resultados por escenario, gráficos (tiempo de respuesta vs. usuarios, throughput, errores), punto de quiebre identificado, cuellos de botella y recomendaciones.

---

## Pregunta 7 – Métricas para determinar el punto de quiebre

| Categoría | Métrica | Señal de quiebre |
|---|---|---|
| Tiempo de respuesta | Promedio, **p90 / p95 / p99**, máximo | p95 supera 3 s o crece de forma exponencial |
| Throughput | Transacciones/s (TPS), requests/s | Deja de crecer (se aplana o cae) aunque se aumenten usuarios |
| Errores | **% de error**, códigos HTTP 5xx, timeouts | Tasa de error > 1 % |
| Concurrencia | Usuarios virtuales activos | Número de usuarios en el que ocurre la degradación = **punto de quiebre** |
| Latencia | Latencia de red, tiempo de conexión, TTFB | Incremento sostenido |
| Servidor de aplicación | CPU, memoria, hilos, Garbage Collection | CPU > 80–85 %, memoria saturada, GC frecuente |
| Base de datos (SQL Server) | Tiempo de queries, conexiones activas, bloqueos/deadlocks, pool de conexiones | Pool agotado, deadlocks, queries lentas |
| Pasarela externa | Tiempo de respuesta del proveedor QR, timeouts | Dependencia externa saturada |
| Infraestructura | Disco I/O, ancho de banda de red | Cuello de botella de red / I/O |
| Integridad de negocio | Depósitos duplicados, QR repetidos, estados inconsistentes | Cualquier inconsistencia |

**Punto de quiebre:** la cantidad de usuarios concurrentes a partir de la cual el **throughput deja de crecer**, el **tiempo de respuesta se dispara** por encima del SLA (3 s) y la **tasa de error supera el 1 %**. Se grafica *usuarios vs. tiempo de respuesta vs. throughput vs. errores* y se identifica el "codo" de la curva.