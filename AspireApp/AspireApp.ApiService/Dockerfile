FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src
COPY AspireApp/AspireApp.sln AspireApp/
COPY AspireApp/AspireApp.ApiService/AspireApp.ApiService.csproj AspireApp/AspireApp.ApiService/
COPY AspireApp/AspireApp.ServiceDefaults/AspireApp.ServiceDefaults.csproj AspireApp/AspireApp.ServiceDefaults/
RUN dotnet restore AspireApp/AspireApp.ApiService/AspireApp.ApiService.csproj

COPY AspireApp/AspireApp.ApiService AspireApp/AspireApp.ApiService
COPY AspireApp/AspireApp.ServiceDefaults AspireApp/AspireApp.ServiceDefaults
RUN dotnet publish AspireApp/AspireApp.ApiService/AspireApp.ApiService.csproj -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime

WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 8080

ENTRYPOINT ["dotnet", "AspireApp.ApiService.dll"]
