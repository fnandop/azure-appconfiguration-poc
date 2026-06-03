public sealed class DemoAppOptions
{
    public string? ApplicationName { get; set; }

    public string? Message { get; set; }

    public string? Environment { get; set; }

    public ExternalApiOptions ExternalApi { get; set; } = new();
}

public sealed class ExternalApiOptions
{
    public string? BaseUrl { get; set; }

    public string? ApiKey { get; set; }
}
