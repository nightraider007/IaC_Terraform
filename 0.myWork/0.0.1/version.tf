terraform {
  required_providers {
    random = {
      source  = "hashicorp/random" # Random provider for generating random values
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.8.0"
}
