resource "null_resource" "version" {
  provisioner "local-exec" {
    command = "terraform version"
  }
}
