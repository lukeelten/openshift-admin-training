# Project name
variable "ProjectName" {
  type = "string"
  description = "Descriptive name of project"
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

variable "Training" {
  description = "Nummer der Training Teilnehmer"
  type = "string"
}
