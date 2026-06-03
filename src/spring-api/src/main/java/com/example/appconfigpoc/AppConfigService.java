package com.example.appconfigpoc;

import com.azure.core.credential.TokenCredential;
import com.azure.data.appconfiguration.ConfigurationClient;
import com.azure.data.appconfiguration.ConfigurationClientBuilder;
import com.azure.data.appconfiguration.models.ConfigurationSetting;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.azure.security.keyvault.secrets.SecretClient;
import com.azure.security.keyvault.secrets.SecretClientBuilder;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.net.URI;

@Service
public class AppConfigService {
    private static final String KEY_VAULT_CONTENT_TYPE = "application/vnd.microsoft.appconfig.keyvaultref+json";

    private final ObjectMapper objectMapper = new ObjectMapper();
    private DemoConfiguration cachedConfiguration;

    public DemoConfiguration getConfiguration() {
        if (cachedConfiguration == null) {
            cachedConfiguration = hasAzureAppConfigEndpoint()
                ? loadFromAzure()
                : loadLocal();
        }

        return cachedConfiguration;
    }

    private boolean hasAzureAppConfigEndpoint() {
        return getEnv("AZURE_APPCONFIG_ENDPOINT", "").isBlank() == false;
    }

    private DemoConfiguration loadLocal() {
        return new DemoConfiguration(
            getEnv("DEMOAPP_APPLICATION_NAME", "Azure App Configuration PoC - Local"),
            getEnv("DEMOAPP_MESSAGE", "Hello from local configuration"),
            getEnv("APP_ENVIRONMENT", "local"),
            getEnv("DEMOAPP_EXTERNAL_API_BASE_URL", "https://localhost/example"),
            getEnv("DEMOAPP_EXTERNAL_API_APIKEY", "local-development-secret"),
            Boolean.parseBoolean(getEnv("FEATUREMANAGEMENT_BETAGREETING", "true")));
    }

    private DemoConfiguration loadFromAzure() {
        String endpoint = getEnv("AZURE_APPCONFIG_ENDPOINT", "");
        String label = getEnv("APP_ENVIRONMENT", "dev");
        TokenCredential credential = new DefaultAzureCredentialBuilder().build();
        ConfigurationClient client = new ConfigurationClientBuilder()
            .endpoint(endpoint)
            .credential(credential)
            .buildClient();

        ConfigurationSetting apiKeySetting = client.getConfigurationSetting(
            "DemoApp:ExternalApi:ApiKey",
            label);

        return new DemoConfiguration(
            getSetting(client, "DemoApp:ApplicationName", "common"),
            getSetting(client, "DemoApp:Message", label),
            getSetting(client, "DemoApp:Environment", label),
            getSetting(client, "DemoApp:ExternalApi:BaseUrl", "common"),
            resolveSecret(apiKeySetting, credential),
            Boolean.parseBoolean(getSetting(client, "FeatureManagement:BetaGreeting", label)));
    }

    private String getSetting(ConfigurationClient client, String key, String label) {
        return client.getConfigurationSetting(key, label).getValue();
    }

    private String resolveSecret(ConfigurationSetting setting, TokenCredential credential) {
        if (setting == null || setting.getValue() == null || setting.getValue().isBlank()) {
            return "";
        }

        String value = setting.getValue();
        String contentType = setting.getContentType();

        if ((contentType == null || !contentType.startsWith(KEY_VAULT_CONTENT_TYPE)) && !value.trim().startsWith("{")) {
            return value;
        }

        try {
            JsonNode node = objectMapper.readTree(value);
            String secretUri = node.path("uri").asText("");

            if (secretUri.isBlank()) {
                return "";
            }

            URI uri = URI.create(secretUri);
            String[] pathParts = uri.getPath().split("/");
            String secretName = pathParts.length >= 3 ? pathParts[2] : "";

            SecretClient secretClient = new SecretClientBuilder()
                .vaultUrl(uri.getScheme() + "://" + uri.getHost())
                .credential(credential)
                .buildClient();

            return secretClient.getSecret(secretName).getValue();
        } catch (Exception exception) {
            throw new IllegalStateException("Could not resolve Key Vault reference", exception);
        }
    }

    private String getEnv(String name, String fallback) {
        String value = System.getenv(name);
        return value == null || value.isBlank() ? fallback : value;
    }
}
