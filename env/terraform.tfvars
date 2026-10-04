env_rg = {
  rgs1 = {
    rg_name  = "ado-pipeline-rg"
    location = "CentralIndia"
  }
  rgs1 = {
    rg_name  = "ado-azure"
    location = "CentralIndia"
  }
}
env_storage = {
  storage1 = {
    storage_name     = "adopipelinestorage679872"
    location         = "CentralIndia"
    rg_name          = "ado-pipeline-rg"
    replication_name = "LRS"
    tier             = "Standard"
  }
}
