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

# module "label" {
#   source = "//example/third_party/terraform/module:cloudposse_null_label_0_12"
#   namespace  = "eg"
#   stage      = "prod"
#   name       = "bastion"
#   attributes = ["public"]
#   delimiter  = "-"

#   tags = {
#     "BusinessUnit" = "XYZ",
#     "Snapshot"     = "true"
#   }
# }

module "my_label" {
  source = "./my_module"
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
}
