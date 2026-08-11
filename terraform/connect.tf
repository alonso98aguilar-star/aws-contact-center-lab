resource "aws_connect_instance" "lab" {
  identity_management_type = "CONNECT_MANAGED"
  inbound_calls_enabled    = true
  outbound_calls_enabled   = true
  instance_alias            = var.connect_instance_alias
}

# El security profile "Admin" y el "Basic Routing Profile" los crea Connect
# automáticamente al provisionar la instancia — no los define Terraform,
# solo se consultan por nombre para usarlos en el usuario administrador.
data "aws_connect_security_profile" "admin" {
  instance_id = aws_connect_instance.lab.id
  name        = "Admin"
}

data "aws_connect_routing_profile" "basic" {
  instance_id = aws_connect_instance.lab.id
  name        = "Basic Routing Profile"
}

resource "aws_connect_user" "admin" {
  instance_id           = aws_connect_instance.lab.id
  name                  = "admin.aguilar"
  routing_profile_id    = data.aws_connect_routing_profile.basic.routing_profile_id
  security_profile_ids  = [data.aws_connect_security_profile.admin.security_profile_id]

  identity_info {
    first_name = "Andres"
    last_name  = "Aguilar"
  }

  phone_config {
    phone_type                     = "SOFT_PHONE"
    after_contact_work_time_limit  = 0
  }
}

resource "aws_connect_lambda_function_association" "processor" {
  instance_id  = aws_connect_instance.lab.id
  function_arn = aws_lambda_function.contact_processor.arn
}
