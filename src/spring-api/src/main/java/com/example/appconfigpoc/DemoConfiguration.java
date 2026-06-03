package com.example.appconfigpoc;

public record DemoConfiguration(
    String applicationName,
    String message,
    String environment,
    String externalApiBaseUrl,
    String externalApiApiKey,
    boolean betaGreeting) {
}
