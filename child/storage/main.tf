resource "azurerm_storage_account" "storage" {
  for_each                 = var.storage
  name                     = each.value.storage_name
  location                 = each.value.location
  resource_group_name      = each.value.rg_name
  account_replication_type = each.value.replication_name
  account_tier             = each.value.tier
}
