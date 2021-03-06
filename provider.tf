terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
}

provider "random" {
}