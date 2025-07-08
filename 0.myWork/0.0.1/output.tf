# ──────────────────────────────────────────────────────────────────────────────
# Study-Focused Outputs - Cleaned and Matched with terraform.auto.tfvars
# Assumes corresponding variables and random_string resources are defined

# Composite output with local and random_string references
output "fullname" {
  # Combines local fullname with a random string and prints each character split by "<>"
  value     = "${local.fullname} - ${random_string.prefix[0].result} -->>> ${join("<>", split("", random_string.prefix[0].result))}"
  sensitive = true
}

# Simple variable + random string suffix
output "application_name" {
  value = "${var.Application_name} - ${random_string.prefix[0].result}"
}

output "Environment_name" {
  value = "${local.environment_name} - ${random_string.prefix[1].result}"
}

output "Region" {
  value     = "${local.region} - ${random_string.prefix[2].result}"
  sensitive = true
}

output "Input_type" {
  value = "Auto.tfvars/.tfvars.json"
}

# ──────────────────────────────────────────────────────────────────────────────
# Direct variable references for clarity and learning

output "application" {
  description = "The application name"
  value       = var.Application_name
}

output "environment" {
  description = "The deployment environment"
  value       = var.Environment_name
}

output "region" {
  description = "The AWS region in use"
  value       = var.Region
  
}

output "input_format" {
  description = "Input data format"
  value       = var.Input_type
}

output "example_number" {
  description = "Example numeric variable (e.g., timeout in seconds)"
  value       = var.Example_Number
}

output "example_flag" {
  description = "Example boolean variable (e.g., feature toggle)"
  value       = var.Example_boolean
}

output "example_list" {
  description = "Example list of ordered values"
  value       = var.Example_list
}

output "list_first" {
  description = "First item in list"
  value       = var.Example_list[0]
}

output "example_set" {
  description = "Example set of unique, unordered values"
  value       = var.Example_set
}

output "set_as_list_indexed" {
  description = "Access set by converting to list"
  value       = tolist(var.Example_set)[1]
}

output "example_map" {
  description = "Example map with key-value pairs"
  value       = var.Example_map
}

output "map_second" {
  description = "Access 'second' key from map"
  value       = var.Example_map["second"]
}

output "example_tuple" {
  description = "Tuple as a fixed-length, ordered data structure"
  value       = var.Example_tuple
}

output "tuple_first" {
  description = "First item in tuple"
  value       = var.Example_tuple[0]
}

output "tuple_second" {
  description = "Second item in tuple"
  value       = var.Example_tuple[1]
}

output "tuple_third" {
  description = "Third item in tuple"
  value       = var.Example_tuple[2]
}
