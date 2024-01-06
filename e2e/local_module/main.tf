terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "null" {

}

module "my_module_a" {
  source = "./module_a"
}


module "my_module_b" {
  source = "./module_b"
}
