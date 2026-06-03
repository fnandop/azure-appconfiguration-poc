import { AppConfigurationClient } from "@azure/app-configuration";
import { DefaultAzureCredential } from "@azure/identity";
import { SecretClient } from "@azure/keyvault-secrets";

const serviceName = "node-api";
const keyVaultContentType = "application/vnd.microsoft.appconfig.keyvaultref+json";

const localConfig = {
  applicationName: process.env.DEMOAPP_APPLICATION_NAME ?? "Azure App Configuration PoC - Local",
  message: process.env.DEMOAPP_MESSAGE ?? "Hello from local configuration",
  environment: process.env.APP_ENVIRONMENT ?? "local",
  externalApiBaseUrl: process.env.DEMOAPP_EXTERNAL_API_BASE_URL ?? "https://localhost/example",
  externalApiApiKey: process.env.DEMOAPP_EXTERNAL_API_APIKEY ?? "local-development-secret",
  betaGreeting: parseBoolean(process.env.FEATUREMANAGEMENT_BETAGREETING, true)
};

let cachedConfig;

export async function getConfig() {
  if (!cachedConfig) {
    cachedConfig = process.env.AZURE_APPCONFIG_ENDPOINT
      ? await loadFromAzure()
      : localConfig;
  }

  return cachedConfig;
}

export function getHealth() {
  return {
    status: "Healthy",
    service: serviceName
  };
}

async function loadFromAzure() {
  const endpoint = process.env.AZURE_APPCONFIG_ENDPOINT;
  const label = process.env.APP_ENVIRONMENT ?? "dev";
  const credential = new DefaultAzureCredential();
  const client = new AppConfigurationClient(endpoint, credential);

  const values = {
    applicationName: await getSetting(client, "DemoApp:ApplicationName", "common"),
    message: await getSetting(client, "DemoApp:Message", label),
    environment: await getSetting(client, "DemoApp:Environment", label),
    externalApiBaseUrl: await getSetting(client, "DemoApp:ExternalApi:BaseUrl", "common"),
    betaGreeting: parseBoolean(await getSetting(client, "FeatureManagement:BetaGreeting", label), false)
  };

  const apiKeySetting = await client.getConfigurationSetting({
    key: "DemoApp:ExternalApi:ApiKey",
    label
  });

  values.externalApiApiKey = await resolveSecret(apiKeySetting, credential);

  return values;
}

async function getSetting(client, key, label) {
  const setting = await client.getConfigurationSetting({ key, label });
  return setting.value;
}

async function resolveSecret(setting, credential) {
  if (!setting?.value) {
    return "";
  }

  if (!setting.contentType?.startsWith(keyVaultContentType) && !setting.value.trim().startsWith("{")) {
    return setting.value;
  }

  const reference = JSON.parse(setting.value);
  const secretUri = reference.uri;

  if (!secretUri) {
    return "";
  }

  const parsedUri = new URL(secretUri);
  const pathParts = parsedUri.pathname.split("/").filter(Boolean);
  const secretName = pathParts[1];
  const secretClient = new SecretClient(`${parsedUri.protocol}//${parsedUri.host}`, credential);
  const secret = await secretClient.getSecret(secretName);

  return secret.value ?? "";
}

function parseBoolean(value, fallback) {
  if (value === undefined || value === null || value === "") {
    return fallback;
  }

  return String(value).toLowerCase() === "true";
}
