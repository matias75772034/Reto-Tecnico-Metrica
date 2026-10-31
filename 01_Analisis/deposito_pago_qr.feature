# =====================================================================================
#  CRITERIO DE ETIQUETADO (Pregunta 2)
# -------------------------------------------------------------------------------------
#  @critical   -> Si falla, el usuario NO puede depositar o existe riesgo de pérdida
#                 de dinero / fraude. Bloquea el pase a producción.
#  @smoke      -> Subconjunto mínimo y rápido (< 5 min) que valida que el flujo
#                 principal está "vivo" luego de cada despliegue.
#  @regression -> Todos los escenarios funcionales; se ejecutan en cada release.
#  Etiquetas complementarias: @happy_path @alternative_path @negative_path
#                 @exception_path @security @performance
# =====================================================================================
@deposito @pago_qr
Feature: Depósito mediante la pasarela "Pago con QR"
  Como usuario autenticado del Casino Online Atlantic City
  Quiero depositar saldo generando un código QR
  Para pagar desde Yape, Plin u otra billetera electrónica

  Reglas de negocio:
  - Monto mínimo por transacción: S/10 | Monto máximo por transacción: S/500
  - Montos rápidos: S/10, S/100, S/300 | "Otro monto" para ingreso manual
  - Moneda: PEN | Estados del depósito: Pendiente, Exitoso, Fallido
  - Un QR es de un solo uso

  Background:
    Given que el usuario "Testcalimaco35" inició sesión en el casino online
    And hizo clic en el botón "DEPOSITAR" del header
    And seleccionó la pasarela "Pago con QR"
  # =================================== HAPPY PATH ===================================

  @critical @smoke @regression @happy_path
  Scenario Outline: Generar QR seleccionando un monto rápido
    When selecciona el monto rápido "S/<monto>"
    And hace clic en "SIGUIENTE"
    Then se muestra un código QR para pagar S/<monto>
    And se registra el depósito con monto <monto>, moneda "PEN" y estado "Pendiente"

    Examples:
      | monto |
      |    10 |
      |   100 |
      |   300 |

  @critical @regression @happy_path
  Scenario Outline: Generar QR ingresando "Otro monto" válido
    When selecciona "Otro monto"
    And ingresa el monto "<monto>"
    And hace clic en "SIGUIENTE"
    Then se muestra un código QR para pagar S/<monto>

    Examples: Valores límite y partición válida
      | monto  |
      |     10 |
      |  10.01 |
      |    250 |
      | 499.99 |
      |    500 |

  @critical @smoke @regression @happy_path
  Scenario: Pago exitoso del QR acredita el saldo
    Given que generó un QR por S/100
    When realiza el pago del QR desde la billetera Yape
    Then el depósito cambia a estado "Exitoso"
    And el saldo del usuario se incrementa en S/100
    And se muestra la confirmación de depósito exitoso
  # ================================ ALTERNATIVE PATH ================================

  @regression @alternative_path
  Scenario: Cambiar el monto seleccionado antes de generar el QR
    Given que seleccionó el monto rápido "S/10"
    When selecciona el monto rápido "S/300"
    And hace clic en "SIGUIENTE"
    Then se muestra un código QR para pagar S/300

  @regression @alternative_path
  Scenario: Regresar al listado de pasarelas con la flecha atrás
    When hace clic en la flecha "←" de la pantalla "Pago con QR"
    Then se muestra nuevamente el listado de métodos de depósito
    And no se genera ningún depósito

  @regression @alternative_path
  Scenario: Cerrar el modal de depósito sin generar QR
    Given que seleccionó el monto rápido "S/100"
    When hace clic en la "X" del modal
    Then el modal se cierra
    And no se registra ningún depósito para el usuario

  @regression @alternative_path
  Scenario: Consultar las instrucciones de "¿Cómo depositar?"
    When hace clic en "¿Cómo depositar?"
    Then se despliegan los pasos para depositar con QR

  @regression @alternative_path
  Scenario: Generar un nuevo QR luego de que el anterior expiró
    Given que generó un QR por S/100 que expiró sin ser pagado
    When genera un nuevo QR por S/100
    Then se muestra un código QR distinto al anterior
    And el depósito anterior permanece con estado "Fallido"
  # ================================== NEGATIVE PATH =================================

  @critical @smoke @regression @negative_path
  Scenario Outline: No permitir montos fuera de rango o con formato inválido
    When selecciona "Otro monto"
    And ingresa el monto "<monto>"
    Then el botón "SIGUIENTE" permanece deshabilitado
    And se muestra el mensaje "<mensaje>"

    Examples:
      | monto  | mensaje                                      |
      |   9.99 | Monto mínimo por transacción: S/10.          |
      |      0 | Monto mínimo por transacción: S/10.          |
      |    -10 | Monto mínimo por transacción: S/10.          |
      | 500.01 | El monto máximo por transacción es de S/500. |
      |   1000 | El monto máximo por transacción es de S/500. |
      |    abc | Ingrese un monto válido                      |

  @regression @negative_path
  Scenario: Botón SIGUIENTE deshabilitado sin monto seleccionado
    When no selecciona ningún monto
    Then el botón "SIGUIENTE" permanece deshabilitado

  @critical @regression @negative_path
  Scenario: Usuario sin sesión no puede acceder al depósito
    Given que el usuario no ha iniciado sesión
    When hace clic en el botón "DEPOSITAR" del header
    Then se muestra el formulario de inicio de sesión
    And no se muestra la pasarela "Pago con QR"
  # ================================= EXCEPTION PATH =================================

  @critical @regression @exception_path
  Scenario: Timeout de la pasarela de pago al generar el QR
    Given que el servicio de la pasarela QR no responde dentro del tiempo límite
    When selecciona el monto rápido "S/100"
    And hace clic en "SIGUIENTE"
    Then se muestra un mensaje amigable "No pudimos generar tu QR, inténtalo nuevamente"
    And el depósito se registra con estado "Fallido"
    And el saldo del usuario no se modifica

  @regression @exception_path
  Scenario: Pasarela de pago responde con error 500
    Given que el servicio de la pasarela QR responde con error 500
    When genera un QR por S/100
    Then se muestra un mensaje de error controlado sin detalles técnicos
    And el error queda registrado en los logs de la aplicación

  @critical @regression @exception_path
  Scenario: QR expira sin recibir el pago
    Given que generó un QR por S/100
    When transcurre el tiempo de vigencia del QR sin recibir el pago
    Then el QR se muestra como expirado
    And el depósito cambia a estado "Fallido"
    And el saldo del usuario no se modifica

  @critical @regression @exception_path
  Scenario: Pago aprobado por la billetera pero falla el callback al casino
    Given que generó un QR por S/100
    And el pago fue aprobado en la billetera
    When el callback de confirmación hacia el casino falla
    Then el proceso de conciliación reintenta la confirmación
    And el depósito finalmente queda en estado "Exitoso" sin duplicar el saldo

  @regression @exception_path
  Scenario: Pérdida de conexión durante la generación del QR
    Given que el usuario pierde la conexión a internet
    When hace clic en "SIGUIENTE" con el monto "S/100"
    Then se muestra un mensaje de "Sin conexión"
    And al recuperar la conexión puede reintentar sin generar depósitos duplicados
  # ================================== SECURITY PATH =================================

  @critical @regression @security
  Scenario: No se permite reutilizar un QR ya pagado
    Given que generó un QR por S/100 y fue pagado exitosamente
    When se intenta pagar nuevamente el mismo QR
    Then la billetera rechaza el pago indicando que el QR ya fue utilizado
    And el saldo del usuario se incrementa una sola vez

  @critical @regression @security
  Scenario: No se permite manipular el monto en la petición
    Given que seleccionó el monto rápido "S/10"
    When se intercepta la petición y se modifica el monto a 1
    Then el backend rechaza la petición por monto inválido
    And no se genera el código QR

  @critical @regression @security
  Scenario: Doble clic en SIGUIENTE no genera depósitos duplicados
    Given que seleccionó el monto rápido "S/100"
    When hace doble clic en "SIGUIENTE"
    Then se genera un único código QR
    And se registra un único depósito en estado "Pendiente"

  @critical @regression @security
  Scenario: Un usuario no puede consultar el QR o depósito de otro usuario
    Given que el usuario "Testcalimaco35" generó un depósito
    When otro usuario consulta ese depósito modificando su identificador
    Then el sistema responde "Acceso denegado"

  @regression @security
  Scenario: Sesión expirada bloquea la generación del QR
    Given que la sesión del usuario expiró
    When hace clic en "SIGUIENTE" con el monto "S/100"
    Then se redirige al formulario de inicio de sesión
    And no se genera el código QR

  @regression @security
  Scenario: El campo "Otro monto" no es vulnerable a inyección
    When selecciona "Otro monto"
    And ingresa el valor "<script>alert(1)</script>"
    Then el valor es rechazado y no se ejecuta ningún script
  # ================================ PERFORMANCE PATH ================================

  @performance
  Scenario: Tiempo de generación del QR menor a 3 segundos
    Given que seleccionó el monto rápido "S/100"
    When hace clic en "SIGUIENTE"
    Then el código QR se muestra en menos de 3 segundos

  @performance
  Scenario: Múltiples depósitos en simultáneo
    Given que 100 usuarios autenticados están en la pasarela "Pago con QR"
    When generan un QR en simultáneo durante 10 minutos
    Then el percentil 95 del tiempo de respuesta es menor a 3 segundos
    And la tasa de error es menor al 1 %
    And cada depósito queda registrado una sola vez en la tabla Depositos

  @performance
  Scenario: Usuario genera varios QR consecutivos
    When el mismo usuario genera 5 QR consecutivos por S/10
    Then cada QR se genera en menos de 3 segundos
    And cada QR tiene un identificador único
