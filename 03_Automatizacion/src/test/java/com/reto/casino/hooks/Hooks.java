package com.reto.casino.hooks;

import com.reto.casino.utils.DriverFactory;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.Scenario;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class Hooks {

    @Before
    public void setUp() {
        DriverFactory.initDriver();
    }

    /** Paso e. Cerrar el navegador (se adjunta evidencia al reporte antes de cerrar). */
    @After
    public void tearDown(Scenario scenario) {
        if (DriverFactory.getDriver() != null) {
            byte[] screenshot = ((TakesScreenshot) DriverFactory.getDriver()).getScreenshotAs(OutputType.BYTES);
            scenario.attach(screenshot, "image/png", scenario.getName());
            saveEvidence(scenario, screenshot);
        }
        DriverFactory.quitDriver();
    }

    private void saveEvidence(Scenario scenario, byte[] screenshot) {
        try {
            Path folder = Paths.get("target", "evidence");
            Files.createDirectories(folder);
            String status = scenario.isFailed() ? "FAILED" : "PASSED";
            String fileName = status + "_line" + scenario.getLine() + "_" + System.currentTimeMillis() + ".png";
            Files.write(folder.resolve(fileName), screenshot);
        } catch (IOException e) {
            System.err.println("Could not save evidence: " + e.getMessage());
        }
    }
}
