provider "azurerm" {
  features {}
}

locals {
  name     = "moin"
  location = "Switzerland North"
  tags = {
    managed-by = "Terraform"
  }
}

resource "azurerm_resource_group" "aks" {
  name     = local.name
  location = local.location
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = local.name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = local.name

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  tags = local.tags
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}
