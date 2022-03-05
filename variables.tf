variable "app_service_plan_sku_tier" {
  type    = string
  default = "Standard"
}

# 2022年01月時点ではprivate linkが使用可能なのはP1v2から
variable "app_service_plan_sku_size" {
  type    = string
  default = "S1"
}

variable "system_name" {
  type    = string
  default = "webapp-autoscaling"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "location" {
  type    = string
  default = "japaneast"
}
