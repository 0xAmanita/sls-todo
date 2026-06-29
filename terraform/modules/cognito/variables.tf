variable "pool_name" {
  description = "Cognito User Pool name"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
