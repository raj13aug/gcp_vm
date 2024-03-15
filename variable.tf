variable "organization_id" {
  description = "ID of a Google Cloud Organization"
}

variable "billing_account_id" {
  description = "ID of a Google Cloud Billing Account which will be used to pay for resources"
}

variable "name" {
  description = "Name of a Google Cloud Project"
}

variable "id" {
  description = "ID of a Google Cloud Project. Can be omitted and will be generated automatically"
  default     = ""
}

variable "project_id" {
  type        = string
  description = "project id "
}

variable "region" {
  type        = string
  description = "Region of policy "
}

variable "uptime_schedule" {
  type        = map(string)
  description = "Key/value pairs to define the uptime schedule: start and stop are cron expressions, time_zone is an IANA time zone name"
  default = {
    start     = "0 6 * * *"
    stop      = "0 0 * * *"
    time_zone = "Asia/Kolkata"
  }
}