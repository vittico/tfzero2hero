variable "bucket_name" {
  description = "Este es el nombre del bucket"

}

variable "bucket_acl" {
  description = "La acl del bucket, por defecto private"
  default     = "private"
}

variable "environment" {
  default     = "dev"
  description = "Este es el ambiente al que este recurso pertenece"
}




