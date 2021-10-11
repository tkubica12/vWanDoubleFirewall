variable "prefix" {
  type = string
}

variable "location" {
  type = string
  default = "westeurope"
}

variable "name" {
  type = string
}

variable "vnetRange" {
  type = string
}

variable "vwanHubId" {
  type = string
}

variable "vwanRouteId" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "owners" {
  type = list(string)
}

variable "deployDemo" {
  type = string
}

variable "externalFwIp" {
  type = string
}

variable "externalVnetName" {
  type = string
}

variable "externalVnetId" {
  type = string
}

variable "externalRgName" {
  type = string
}