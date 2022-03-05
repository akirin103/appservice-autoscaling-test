terraform {
  required_version = "~> 1.1.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.73.0"
    }
  }

  # backend "azurerm" {
  #   # 手動デプロイ用
  #   resource_group_name  = "hisano-terraform-rg"
  #   storage_account_name = "hisanotfstatedev"
  #   container_name       = "hisano-tfstate"
  #   key                  = "office-system-dev.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "${var.system_name}-${var.stage}-rg"
  location = var.location
}

resource "azurerm_app_service_plan" "this" {
  name                = "${var.system_name}-${var.stage}-asp"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  kind     = "Linux"
  reserved = true # `reserved` has to be set to true when kind is set to `Linux`

  sku {
    tier = var.app_service_plan_sku_tier
    size = var.app_service_plan_sku_size
  }

  tags = {
    name  = var.system_name
    stage = var.stage
  }
}

resource "azurerm_monitor_autoscale_setting" "test" {
  name                = "${var.system_name}-${var.stage}-as"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  target_resource_id  = azurerm_app_service_plan.this.id

  profile {
    name = "${var.system_name}-${var.stage}-profile"

    capacity {
      default = 1
      minimum = 1
      maximum = 2
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.this.id
        statistic          = "Average"
        time_window        = "PT5M"
        time_grain         = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_app_service_plan.this.id
        statistic          = "Average"
        time_window        = "PT5M"
        time_grain         = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }
}

resource "azurerm_app_service" "this" {
  name                = "${var.system_name}${var.stage}app"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  app_service_plan_id = azurerm_app_service_plan.this.id
  site_config {
    # when using an App Service Plan in the Free or Shared Tiers use_32_bit_worker_process must be set to true
    use_32_bit_worker_process = true
    linux_fx_version          = "python|3.9"
  }

  app_settings = {
    WEBSITE_VNET_ROUTE_ALL = "1",
    WEBSITE_DNS_SERVER     = "168.63.129.16",
  }

  tags = {
    name  = var.system_name
    stage = var.stage
  }
}
