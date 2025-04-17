provider "null" {
  version = "2.0.0"
}

resource "null_resource" "version" {
  provisioner "local-exec" {
    command = "terraform version && echo ${var.hello}"
  }
}
