package com.reto.casino.utils;

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.edge.EdgeDriver;
import org.openqa.selenium.edge.EdgeOptions;

public final class DriverFactory {

    private static final ThreadLocal<WebDriver> DRIVER = new ThreadLocal<>();

    private DriverFactory() {
    }

    public static void initDriver() {
        boolean headless = Boolean.parseBoolean(ConfigReader.get("headless"));
        WebDriver driver;
        if ("edge".equalsIgnoreCase(ConfigReader.get("browser"))) {
            EdgeOptions options = new EdgeOptions();
            options.addArguments("--start-maximized");
            if (headless) options.addArguments("--headless=new", "--window-size=1920,1080");
            driver = new EdgeDriver(options);
        } else {
            ChromeOptions options = new ChromeOptions();
            options.addArguments("--start-maximized", "--disable-notifications");
            if (headless) options.addArguments("--headless=new", "--window-size=1920,1080");
            driver = new ChromeDriver(options);
        }
        DRIVER.set(driver);
    }

    public static WebDriver getDriver() {
        return DRIVER.get();
    }

    public static void quitDriver() {
        if (DRIVER.get() != null) {
            DRIVER.get().quit();
            DRIVER.remove();
        }
    }
}
