variable "prefix" {
  type    = string
  default = "tom"
}

module "sharedEnvironment" {
  source = "./modules/sharedEnvironment"
  prefix = var.prefix
}

module "environments" {
  for_each            = yamldecode(file("./environments.yaml"))
  source              = "./modules/environments"
  prefix              = var.prefix
  name                = each.key
  vnetRange           = each.value.vnetRange
  vwanHubId           = module.sharedEnvironment.vwanHubId
  vwanRouteId         = module.sharedEnvironment.vwanRouteId
  tags                = each.value.tags
  owners              = each.value.owners
  deployDemo          = each.value.deployDemo
  externalFwIp        = module.sharedEnvironment.externalFwIp
  externalVnetName    = module.sharedEnvironment.externalVnetName
  externalVnetId      = module.sharedEnvironment.externalVnetId
  externalRgName      = module.sharedEnvironment.externalRgName
}
