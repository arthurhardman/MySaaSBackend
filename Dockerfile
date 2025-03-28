# Fase base para a execução (modo rápido no Visual Studio)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

# Fase de construção do serviço
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["MySaaSBackend.csproj", "./"]
RUN dotnet restore "./MySaaSBackend.csproj"
COPY . . 
WORKDIR "/src"
RUN dotnet build "./MySaaSBackend.csproj" -c $BUILD_CONFIGURATION -o /app/build

# Fase de publicação do serviço
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./MySaaSBackend.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Fase final para execução (modo normal ou produção)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MySaaSBackend.dll"]
