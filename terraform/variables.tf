variable "aws_region" {
  description = "Región de AWS donde vive el laboratorio"
  type        = string
  default     = "us-east-1"
}

variable "connect_instance_alias" {
  description = "Alias de la instancia de Amazon Connect"
  type        = string
  default     = "contact-center-lab-aguilar"
}
