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
  source = "./modules/a"
}


module "my_module_b" {
  source = "./modules/b"
}
