resource "null_resource" "version" {
  provisioner "local-exec" {
    command = "echo \"module b\" && terraform version"
  }
}
