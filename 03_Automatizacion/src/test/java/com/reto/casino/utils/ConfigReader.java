package com.reto.casino.utils;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

public final class ConfigReader {

    private static final Properties PROPERTIES = new Properties();

    static {
        try (InputStream input = ConfigReader.class.getClassLoader().getResourceAsStream("config.properties")) {
            PROPERTIES.load(input);
        } catch (IOException | NullPointerException e) {
            throw new IllegalStateException("No se pudo cargar config.properties", e);
        }
    }

    private ConfigReader() {
    }

    /** Permite sobrescribir cualquier valor por línea de comandos: -Dclave=valor */
    public static String get(String key) {
        return System.getProperty(key, PROPERTIES.getProperty(key));
    }
}
