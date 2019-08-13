variable "Types" {
  description = "Node types: EC2 instance types to use for different nodes"
  type = "map"
  # Master
  # Infra
  # App
}

variable "Zone" {
  type = "string"
  description = "Existing DNS zone to put openshift cluster in"
  default = "cc-openshift.de"
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
