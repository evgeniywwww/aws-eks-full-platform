variable "tags" {
  type = map(string)
}

variable "iam_roles" {
  type        = map(object({
    principal = string
    policies  = list(string)
  }))
}