terraform {
  required_version = ">=1.8.3"

  required_providers {
    aws = {
      source  = "registry.opentofu.org/hashicorp/aws"
      version = "~>5.42"
    }
    tls = {
      source  = "registry.opentofu.org/hashicorp/tls"
      version = "~>4.0"
    }
  }
}
