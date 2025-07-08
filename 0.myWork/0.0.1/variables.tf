# ──────────────────────────────────────────────────────────────────────────────
# Basic string variable
# - Represents plain text (UTF-8)
# - Used for naming resources, identifiers, regions, etc.
# - Most common and flexible primitive type
variable "Application_name" {
  type        = string
  description = "The name of the application"
}

# ──────────────────────────────────────────────────────────────────────────────
# String again, but here for environment names
# - Common examples: "dev", "test", "prod"
# - Often used to determine branching logic in modules
variable "Environment_name" {
  type        = string
  description = "The name of the environment (e.g., dev, staging, prod)"
}

# ──────────────────────────────────────────────────────────────────────────────
# Another string – but with a default value
# - AWS regions like "us-east-1", "eu-west-2"
# - Marked as sensitive for security practice (not shown in logs)
variable "Region" {
  type        = string
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
  //sensitive   = true
}

# ──────────────────────────────────────────────────────────────────────────────
# String representing the data format
# - Could be "json", "yaml", "xml"
# - Useful in conditional logic or when selecting file readers/parsers
variable "Input_type" {
  type        = string
  description = "The type of input format (e.g., json, yaml, xml)"
  default     = "json"
}

# ──────────────────────────────────────────────────────────────────────────────
# Number: numeric value (integer or float)
# - Used for timeouts, port numbers, CPU limits, etc.
# - Can be used in arithmetic operations and conditionals
variable "Example_Number" {
  type        = number
  description = "A floating-point example value for things like timeouts or resource limits"
  default     = 15.75
}

# ──────────────────────────────────────────────────────────────────────────────
# Boolean: true or false
# - Common for flags (e.g., enable_feature = true)
# - Used in conditional blocks or ternary expressions
variable "Example_boolean" {
  type        = bool
  description = "A flag to enable or disable a feature, like logging or debug mode"
  default     = false
}

# ──────────────────────────────────────────────────────────────────────────────
# List: ordered collection of values (can have duplicates)
# - Useful for things like availability zones, subnet IDs
# - Accessed by index: var.Example_list[0]
variable "Example_list" {
  type        = list(string)
  description = "A list of availability zones or environment tags"
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

# ──────────────────────────────────────────────────────────────────────────────
# Set: unordered collection of **unique** values
# - Similar to list, but no duplicates, and no guaranteed order
# - Ideal for role flags, permissions, tags that don't need order
variable "Example_set" {
  type        = set(string)
  description = "A set of enabled feature flags or access levels"
  default     = ["read", "write", "execute"]
}

# ──────────────────────────────────────────────────────────────────────────────
# Map: key-value pairs with string keys and uniform value types
# - Useful for config tables, per-environment overrides
# - Access with keys: var.Example_map["version"]
variable "Example_map" {
  type        = map(any) # could also use map(string) for stricter typing
  description = "A key-value map that could represent dynamic config like instance types or user metadata"
  default = {
    environment   = "production"
    instance_type = "t3.medium"
    version       = "1.0.5"
  }
}


# ──────────────────────────────────────────────────────────────────────────────
# Tuple: fixed-length, position-based, mixed types
# - Each element has a defined position and type
# - Good for multi-part identifiers, version components, etc.
# - Access by index: var.Tuple_example[1] → 42
variable "Example_tuple" {
  type        = tuple([string, number, bool])
  description = "A tuple representing a composite key: user ID (string), age (number), active flag (bool)"
  default     = ["user123", 42, true]
}













/* 
# ──────────────────────────────────────────────────────────────────────────────
# Object: fixed structure with named keys and specific types
# - Great for passing structured data into modules
# - Supports nested types (map, list, etc.)
# - Use dot notation to access: var.Object_example.name
variable "Object_example" {
  type = object({
    name        = string
    age         = number
    is_active   = bool
    tags        = list(string)
    attributes  = map(string)
  })
  description = "A structured object representing user metadata and attributes"
  default = {
    name       = "Alice Johnson"
    age        = 34
    is_active  = true
    tags       = ["admin", "team-lead"]
    attributes = {
      department = "Engineering"
      location   = "London"
      timezone   = "Europe/London"
    }
  }
} */


