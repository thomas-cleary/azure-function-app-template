# azure-function-app-template

☁️ ⚡️ 🍽

[![Infra - CI/CD](https://github.com/thomas-cleary/azure-function-app-template/actions/workflows/infra-cicd.yaml/badge.svg?branch=main)](https://github.com/thomas-cleary/azure-function-app-template/actions/workflows/infra-cicd.yaml)
[![Function App - CI/CD](https://github.com/thomas-cleary/azure-function-app-template/actions/workflows/fa-cicd.yaml/badge.svg?branch=main)](https://github.com/thomas-cleary/azure-function-app-template/actions/workflows/fa-cicd.yaml)

For setup instructions, see the repository's [wiki](https://github.com/thomas-cleary/azure-function-app-template/wiki).

## Running locally

```shell
cd src
```

```shell
dotnet restore && dotnet build && func start
```

## Sending requests to the function app

Requests found in `/requests` can be run using the [REST Client](https://marketplace.visualstudio.com/items?itemName=humao.rest-client) VSCode extension.
