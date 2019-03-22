# Project name
variable "ProjectName" {
  type = "string"
  description = "Descriptive name of project"
}

variable "ProjectId" {
  type = "string"
  description = "Project Id contains only lowercase alphanumerical characters."
}

variable "PublicKey" {
  description = "Public SSH key which will be used for EC2 instances to access."
  type = "string"
}

variable "Types" {
  description = "Node types: EC2 instance types to use for different nodes"
  type = "map"
  # Bastion
  # Master
  # Infra
  # App
}

variable "Zone" {
  type = "string"
  description = "Existing DNS zone to put openshift cluster in"
}

variable "Counts" {
  description = "Number of instances per node type"
  type = "map"
  # Master
  # Infra
  # App
}
