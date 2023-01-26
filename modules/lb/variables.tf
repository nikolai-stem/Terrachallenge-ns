variable "proj" {
  type = object({
    name = string
    env  = string
  })
}

variable "rg" {
  type = object({
    name     = string
    location = string
  })
}

variable "public_ip_address_id" {
  type = string
}
