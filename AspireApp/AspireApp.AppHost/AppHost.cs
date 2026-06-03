using Azure.Provisioning.AppConfiguration;
using Azure.Provisioning.KeyVault;

var builder = DistributedApplication.CreateBuilder(args);

var environmentName = builder.Configuration["APP_ENVIRONMENT"] ?? "dev";
var configuredAppConfigName = builder.Configuration["APP_CONFIG_NAME"];
var configuredKeyVaultName = builder.Configuration["KEY_VAULT_NAME"];
var resourcePrefix = builder.Configuration["RESOURCE_PREFIX"];
var appConfigName = !string.IsNullOrWhiteSpace(configuredAppConfigName)
    ? configuredAppConfigName
    : !string.IsNullOrWhiteSpace(resourcePrefix)
        ? $"{resourcePrefix}-appconfig"
        : $"appconfiguration-poc-{environmentName}";
var keyVaultName = !string.IsNullOrWhiteSpace(configuredKeyVaultName)
    ? configuredKeyVaultName
    : !string.IsNullOrWhiteSpace(resourcePrefix)
        ? $"{resourcePrefix}-keyvault"
        : $"keyvault-poc-{environmentName}";

var appEnvironment = builder.AddParameter("app-environment", environmentName);

var containerAppEnvironment = builder.AddAzureContainerAppEnvironment("aca-env");
var appConfig = builder.AddAzureAppConfiguration("appconfig")
    .ConfigureInfrastructure(infrastructure =>
    {
        var appConfigStore = infrastructure.GetProvisionableResources()
            .OfType<AppConfigurationStore>()
            .Single();

        appConfigStore.Name = appConfigName;
    });
var keyVault = builder.AddAzureKeyVault("keyvault")
    .ConfigureInfrastructure(infrastructure =>
    {
        var keyVaultService = infrastructure.GetProvisionableResources()
            .OfType<KeyVaultService>()
            .Single();

        keyVaultService.Name = keyVaultName;
    });

var apiService = builder.AddProject<Projects.AspireApp_ApiService>("dotnet-api")
    .WithEnvironment("APP_ENVIRONMENT", appEnvironment)
    .WithEnvironment("AZURE_APPCONFIG_ENDPOINT", appConfig.Resource.Endpoint)
    .WithExternalHttpEndpoints()
    .WithReference(appConfig)
    .WithReference(keyVault)
    .WithHttpHealthCheck("/health")
    .PublishAsAzureContainerApp((_, _) => { });

var springApi = builder.AddDockerfile("spring-api", "../../src/spring-api")
    .WithHttpEndpoint(port: 8080, targetPort: 8080, name: "http")
    .WithEnvironment("APP_ENVIRONMENT", appEnvironment)
    .WithEnvironment("AZURE_APPCONFIG_ENDPOINT", appConfig.Resource.Endpoint)
    .WithExternalHttpEndpoints()
    .WithReference(appConfig)
    .WithReference(keyVault)
    .WithHttpHealthCheck("/health")
    .PublishAsAzureContainerApp((_, _) => { });

var nodeApi = builder.AddDockerfile("node-api", "../../src/node-api")
    .WithHttpEndpoint(port: 3000, targetPort: 3000, name: "http")
    .WithEnvironment("APP_ENVIRONMENT", appEnvironment)
    .WithEnvironment("AZURE_APPCONFIG_ENDPOINT", appConfig.Resource.Endpoint)
    .WithExternalHttpEndpoints()
    .WithReference(appConfig)
    .WithReference(keyVault)
    .WithHttpHealthCheck("/health")
    .PublishAsAzureContainerApp((_, _) => { });

builder.AddProject<Projects.AspireApp_Web>("webfrontend")
    .WithExternalHttpEndpoints()
    .WithHttpHealthCheck("/health")
    .WithReference(apiService)
    .WaitFor(apiService)
    .WaitFor(springApi)
    .WaitFor(nodeApi);

builder.Build().Run();
