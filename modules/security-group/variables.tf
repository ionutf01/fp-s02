variable "name" { 
  type = string 
}
variable "description" { 
  type = string
  default = "Managed by Terraform" 
}
variable "vpc_id"      { type = string }

variable "ingress_rules" {
  type = list(object({
    description = string
    port        = number
    cidr_blocks = list(string)
  }))
  default = []
}

variable "tags" { 
  type = map(string)
  default = {} 
}
