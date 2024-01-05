terraform {
  backend "local" {
    path = "{{label}}-terraform.tfstate"
  }
}


/*
label: {{label}}
label.name: {{label.name}}
label.package: {{label.package}}
label.repo_name: {{label.repo_name}}
label.workspace_root: {{label.workspace_root}}
workspace_name: {{workspace_name}}
*/
