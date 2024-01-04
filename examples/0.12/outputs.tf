output "vars" {
  value = {
    "hello" = var.hello,
    "single_value" = var.single_value,
    "list_value" = var.list_value,
    "dict_value" = var.dict_value,
  }
}
