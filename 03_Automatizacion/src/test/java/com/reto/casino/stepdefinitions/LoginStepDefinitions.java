package com.reto.casino.stepdefinitions;

import com.reto.casino.pages.HomePage;
import com.reto.casino.pages.LoginPage;
import com.reto.casino.utils.DriverFactory;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class LoginStepDefinitions {

    private HomePage homePage() {
        return new HomePage(DriverFactory.getDriver());
    }

    private LoginPage loginPage() {
        return new LoginPage(DriverFactory.getDriver());
    }

    @Given("que el usuario abre el navegador con la URL del casino")
    public void abrirUrlDelCasino() {
        homePage().open();
    }

    @When("da clic en {string} de la cabecera")
    public void clicIniciarSesionCabecera(String boton) {
        homePage().clickHeaderLogin();
    }

    @And("ingresa el usuario {string} y la contraseña {string}")
    public void ingresarCredenciales(String usuario, String contrasena) {
        loginPage().enterCredentials(usuario, contrasena);
    }

    @And("da clic en el botón {string} del formulario")
    public void clicIniciarSesionFormulario(String boton) {
        loginPage().submit();
    }

    @Then("visualiza el botón {string} en la cabecera")
    public void validarInicioDeSesion(String boton) {
        assertTrue(homePage().isDepositButtonDisplayed(),
                "El usuario no inició sesión: no se visualiza el botón " + boton);
    }
}
