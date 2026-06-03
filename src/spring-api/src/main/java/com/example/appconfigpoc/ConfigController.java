package com.example.appconfigpoc;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ConfigController {
    private final AppConfigService appConfigService;

    public ConfigController(AppConfigService appConfigService) {
        this.appConfigService = appConfigService;
    }

    @GetMapping("/health")
    HealthResponse health() {
        return new HealthResponse("Healthy", "spring-api");
    }

    @GetMapping("/config")
    ConfigResponse config() {
        DemoConfiguration config = appConfigService.getConfiguration();

        return new ConfigResponse(
            config.applicationName(),
            config.message(),
            config.environment(),
            config.externalApiBaseUrl());
    }

    @GetMapping("/secret")
    SecretResponse secret() {
        DemoConfiguration config = appConfigService.getConfiguration();

        return new SecretResponse(config.externalApiApiKey() != null && !config.externalApiApiKey().isBlank());
    }

    @GetMapping("/feature-flags")
    FeatureFlagsResponse featureFlags() {
        DemoConfiguration config = appConfigService.getConfiguration();

        return new FeatureFlagsResponse(config.betaGreeting());
    }

    record HealthResponse(String status, String service) {
    }

    record ConfigResponse(
        String applicationName,
        String message,
        String environment,
        String externalApiBaseUrl) {
    }

    record SecretResponse(boolean secretResolved) {
    }

    record FeatureFlagsResponse(boolean betaGreeting) {
    }
}
