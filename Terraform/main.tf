terraform {
  required_providers {
    # Specify terraform needed providers
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.113.0"
    }
  }
}

provider "azurerm" {
  # Azure configuration provider needed to enable default features
  features {}
}
# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "fastapi-rg"
  location = var.location
}

# Container registry (ACR)
resource "azurerm_container_registry" "acr" {
  name = "fastapiregistry${random_string.suffix.result}"
  # Name should be global and unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"
  # Tier economico basico
  admin_enabled = true
}

resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false

}

# Container APP env

resource "azurerm_container_app_environment" "env" {
  name                = "fastapi-env"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_container_app.app.identity[0].principal_id

}

# Container APP (Our FastAPI)
resource "azurerm_container_app" "app" {
  revision_mode = "Single"
  # Added revision_mode due to log error message: "Required attribute "revision_mode"
  # not specified: An attribute named "revision_mode" is required here"
  name                = "fastapi-container"
  resource_group_name = azurerm_resource_group.rg.name
  # location                = var.location
  container_app_environment_id = azurerm_container_app_environment.env.id
  identity {
    type = "SystemAssigned"
  }

  template {
    container {
      name  = "fastapi"
      image = "${azurerm_container_registry.acr.login_server}/fastapi-azure-app:latest"
      # Imagen de docker en ACR
      cpu    = 0.5
      memory = "1.0Gi"

      env {
        name  = "DB_HOST"
        value = azurerm_postgresql_flexible_server.db.fqdn
      }
      env {
        name  = "DB_USER"
        value = "dbadmin@${azurerm_postgresql_flexible_server.db.name}"
      }
      env {
        name  = "DB_PASS"
        value = random_password.DB_PASS.result
      }
      env {
        name  = "DB_NAME"
        value = "fastapi_db"
      }

    }
  }
  ingress {
    external_enabled = true
    # Makes the API public from the internet
    target_port = 8000
    # Uvicorn exposed port
    traffic_weight {
      # Added traffic_weight because of: "Too few blocks specified for "
      # traffic_weight": At least 1 block(s) are expected for "traffic_weight""
      percentage      = 100
      latest_revision = true


    }
  }
}

# PostgreSQL Serverless DB
resource "random_password" "DB_PASS" {
  length = 18
  # Automatically generated safe password 
  special = true

}

resource "azurerm_postgresql_flexible_server" "db" {
  name                = "${var.resource_group_name}-db"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  administrator_login           = var.postgres_admin
  administrator_password        = var.postgres_password
  version                       = "14"
  sku_name                      = "B_Standard_B1ms"
  storage_mb                    = 32768
  backup_retention_days         = 7
  zone                          = 1
  public_network_access_enabled = true

}