package com.reto.casino.pages;

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class LoginPage extends BasePage {

    private static final By USER_INPUT = By.cssSelector("input[name='user']");
    private static final By PASSWORD_INPUT = By.cssSelector("input[name='password']");
    private static final By SUBMIT_BUTTON = By.xpath("//button[not(@id='login')"
            + " and contains(translate(normalize-space(.),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),'INICIAR SESI')]");

    public LoginPage(WebDriver driver) {
        super(driver);
    }

    public void enterCredentials(String user, String password) {
        type(USER_INPUT, user);
        type(PASSWORD_INPUT, password);
    }

    public void submit() {
        click(SUBMIT_BUTTON);
    }
}
