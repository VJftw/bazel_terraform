resource "null_resource" "version" {
  provisioner "local-exec" {
    command = "echo \"module a\" && terraform version"
  }
}
