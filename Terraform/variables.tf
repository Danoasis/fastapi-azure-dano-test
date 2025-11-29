variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "canadacentral"
}

variable "container_name" {
  type = string
}

variable "postgres_admin" {
  type = string
}

variable "postgres_password" {
  type      = string
  sensitive = true
}
