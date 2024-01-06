variable "hello" {
  description = "an example tf var"
}

variable "single_value" {
  type = string
}

variable "list_value" {
  type = list
}

variable "dict_value" {
  type = object({
    e_1 = string
    e_2 = string
  })
}
