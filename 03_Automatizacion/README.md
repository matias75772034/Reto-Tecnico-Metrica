# Login automation – Atlantic City online casino

UI automation of the login flow (Annex 3) using **Java 17 + Maven + Selenium 4 + Cucumber (Gherkin) + JUnit 5**, following the **Page Object Model** pattern.

## Automated flow
| Step | Implementation |
|---|---|
| a. Open the browser with the casino URL | `Hooks.setUp()` + `HomePage.open()` (also closes the promo popup and cookie banner) |
| b. Click "Iniciar sesión" in the header | `HomePage.clickHeaderLogin()` |
| c. Enter username and password | `LoginPage.enterCredentials()` |
| d. Click "Iniciar sesión" | `LoginPage.submit()` |
| Validation | The "DEPOSITAR" button is displayed (user authenticated) |
| e. Close the browser | `Hooks.tearDown()` (attaches a screenshot as evidence first) |

## Project structure
```
src/test/java/com/reto/casino/
├── hooks/            Hooks.java                 -> open / close browser, evidence
├── pages/            BasePage, HomePage, LoginPage (Page Object Model, explicit waits)
├── runners/          RunnerTest.java            -> Cucumber + JUnit Platform Suite
├── stepdefinitions/  LoginStepDefinitions.java
└── utils/            DriverFactory, ConfigReader
src/test/resources/
├── features/login.feature                       -> Gherkin scenario
└── config.properties                            -> URL, browser, headless, timeout
```

## Prerequisites
- JDK 17+, Maven 3.9+, Google Chrome (or Edge).
- No driver download needed: Selenium Manager resolves it automatically.

## Run
```bash
mvn clean test
```
Options (override `config.properties`):
```bash
mvn clean test -Dheadless=true
mvn clean test -Dbrowser=edge
mvn clean test -Dcucumber.filter.tags="@smoke"
```

## Reports and evidence
- HTML report: `target/cucumber-reports/report.html`
- JSON report: `target/cucumber-reports/report.json`
- Screenshots: `target/evidence/`

## Design decisions
- **Explicit waits** (`WebDriverWait`), no `Thread.sleep`.
- Optional overlays (promo popup, cookies) are closed if present, so the test is not flaky.
- Fallback JS click when an overlay intercepts the click.
- `ThreadLocal<WebDriver>` ready for parallel execution.
- Test data lives in the feature `Examples` table, making it easy to add users.
