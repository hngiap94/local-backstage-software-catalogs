resource "aws_amplify_app" "hello_world_app" {
  name       = "${{values.application_name}}"
  repository = var.repository
  access_token = var.access_token
  build_spec = <<-EOT
    version: 0.1
    frontend:
      phases:
        build:
          commands:
            - echo "build frontend"
      artifacts:
        baseDirectory: src
        files:
          - '**/*'
  EOT
}

resource "aws_amplify_branch" "main" {
  app_id  = aws_amplify_app.hello_world_app.id
  branch_name = "main"
}