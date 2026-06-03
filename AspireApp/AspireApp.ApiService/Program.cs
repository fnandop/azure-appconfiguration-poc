using Azure.Identity;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Microsoft.Extensions.Options;
using Microsoft.FeatureManagement;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

var appConfigEndpoint = builder.Configuration["AZURE_APPCONFIG_ENDPOINT"];
var appEnvironment = builder.Configuration["APP_ENVIRONMENT"]
    ?? builder.Environment.EnvironmentName.ToLowerInvariant();

if (!string.IsNullOrWhiteSpace(appConfigEndpoint))
{
    var credential = new DefaultAzureCredential();

    builder.Configuration.AddAzureAppConfiguration(options =>
    {
        options.Connect(new Uri(appConfigEndpoint), credential)
            .Select(KeyFilter.Any, "common")
            .Select(KeyFilter.Any, appEnvironment)
            .ConfigureKeyVault(keyVault => keyVault.SetCredential(credential))
            .UseFeatureFlags(featureFlags => featureFlags.Label = appEnvironment);
    });
}

builder.AddServiceDefaults();

builder.Services.AddProblemDetails();
builder.Services.AddOpenApi();
builder.Services.AddAzureAppConfiguration();
builder.Services.AddFeatureManagement();
builder.Services.Configure<DemoAppOptions>(builder.Configuration.GetSection("DemoApp"));

var app = builder.Build();

app.UseExceptionHandler();

if (!string.IsNullOrWhiteSpace(appConfigEndpoint))
{
    app.UseAzureAppConfiguration();
}


app.MapOpenApi();
app.MapScalarApiReference();


app.MapGet("/health", () => Results.Ok(new HealthResponse("Healthy", "dotnet-api")));

app.MapGet("/config", (IOptionsSnapshot<DemoAppOptions> options) =>
{
    var demoApp = options.Value;

    return Results.Ok(new ConfigResponse(
        demoApp.ApplicationName,
        demoApp.Message,
        demoApp.Environment,
        demoApp.ExternalApi.BaseUrl));
});

app.MapGet("/secret", (IOptionsSnapshot<DemoAppOptions> options) =>
{
    var secretResolved = !string.IsNullOrWhiteSpace(options.Value.ExternalApi.ApiKey);

    return Results.Ok(new SecretResponse(secretResolved));
});

app.MapGet("/feature-flags", async (IFeatureManagerSnapshot featureManager) =>
{
    var betaGreeting = await featureManager.IsEnabledAsync("BetaGreeting");

    return Results.Ok(new FeatureFlagsResponse(betaGreeting));
});

app.Run();

record HealthResponse(string Status, string Service);

record ConfigResponse(
    string? ApplicationName,
    string? Message,
    string? Environment,
    string? ExternalApiBaseUrl);

record SecretResponse(bool SecretResolved);

record FeatureFlagsResponse(bool BetaGreeting);
