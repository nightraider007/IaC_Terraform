locals {
  fullname = "${var.Application_name}-${var.Environment_name}-${var.Region}"

  environment_name = var.Environment_name
  application_name = var.Application_name
  region           = var.Region
}

locals {
  # String: plain text
  app_name = "my-app"

  # Number: integer or float
  max_replicas = 5
  cpu_threshold = 0.75

  # Boolean: true or false
  is_production = false

  # List: ordered collection (duplicates allowed)
  regions = ["uk-south", "uk-west", "northeurope"]

  # Set: unordered collection (no duplicates)
  enabled_features = toset(["monitoring", "logging", "logging"]) # "logging" will be deduplicated

  # Map: key-value pairs
  tags = {
    environment = "dev"
    owner       = "mark"
    department  = "analytics"
  }

  # Tuple: fixed-length, ordered collection of potentially mixed types
  vm_config = ["Standard_B2ms", 128, true]
}


locals {
  region_list = ["uk-south", "uk-west", "uk-south"]  # Order matters, duplicates allowed
}
locals {
  region_set = toset(["uk-south", "uk-west", "uk-south"])  # Deduplicated and unordered
}
locals {
  vm_properties = ["Standard_B2ms", 128, true]  # Fixed length: string, number, bool
}
locals {
  resource_tags = {
    environment = "dev"
    team        = "cloud"
    owner       = "mark"
  }
}
//https://chatgpt.com/share/686c75a7-aaa8-800d-b2b8-f9811e08c7dc
//https://doublex-nwankou.atlassian.net/wiki/x/HICTB