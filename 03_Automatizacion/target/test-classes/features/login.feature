@login
Feature: Inicio de sesión en el Casino Online Atlantic City
  Como usuario registrado del casino online
  Quiero iniciar sesión con mi usuario y contraseña
  Para acceder a mi cuenta y realizar depósitos

  @smoke @critical
  Scenario Outline: Inicio de sesión exitoso con credenciales válidas
    Given que el usuario abre el navegador con la URL del casino
    When da clic en "Iniciar sesión" de la cabecera
    And ingresa el usuario "<usuario>" y la contraseña "<contrasena>"
    And da clic en el botón "Iniciar sesión" del formulario
    Then visualiza el botón "DEPOSITAR" en la cabecera

    Examples:
      | usuario        | contrasena     |
      | Testcalimaco34 | Testcalimaco34 |
