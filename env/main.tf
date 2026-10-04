module "env_rg" {
  source = "../child/rg"
  rgs    = var.env_rg
}
module "env_storage" {
  depends_on = [module.env_rg]
  source     = "../child/storage"
  storage    = var.env_storage

}
