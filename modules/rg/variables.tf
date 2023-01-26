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
