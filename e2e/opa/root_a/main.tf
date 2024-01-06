terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "null" {

}

resource "null_resource" "i_am_a_bad_resource" {

  provisioner "local-exec" {
    command = "echo \"I am a bad resource\""
  }
}
