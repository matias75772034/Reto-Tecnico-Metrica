package com.reto.casino.pages;

import com.reto.casino.utils.ConfigReader;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;

public class HomePage extends BasePage {

    private static final By PROMO_POPUP_CLOSE = By.id("optiRealclosePopupImage");
    private static final By ACCEPT_COOKIES = By.xpath("//button[normalize-space()='ACEPTAR COOKIES']");
    private static final By HEADER_LOGIN_BUTTON = By.id("login");
    private static final By HEADER_DEPOSIT_BUTTON = By.xpath("//*[self::button or self::a]"
            + "[contains(translate(normalize-space(.),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),'DEPOSITAR')]");

    public HomePage(WebDriver driver) {
        super(driver);
    }

    public void open() {
        driver.get(ConfigReader.get("base.url"));
        closeInitialOverlays();
    }

    private void closeInitialOverlays() {
        clickIfPresent(PROMO_POPUP_CLOSE, 10);
        clickIfPresent(ACCEPT_COOKIES, 3);
    }

    public void clickHeaderLogin() {
        click(HEADER_LOGIN_BUTTON);
    }

    public boolean isDepositButtonDisplayed() {
        return isDisplayed(HEADER_DEPOSIT_BUTTON);
    }
}
