terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "null" {

}

resource "null_resource" "version" {
  provisioner "local-exec" {
    command = "terraform version && echo ${var.hello}"
  }
}

module "my_label" {
  source = "./my_module"
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
}
