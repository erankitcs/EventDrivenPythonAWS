locals {
  name_prefix = join("-", [var.application_id, var.envionment])
}