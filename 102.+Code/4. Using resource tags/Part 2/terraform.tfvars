webapp_environment = {
  "production" = {
    serviceplan={
        serviceplan500090={
            sku="F1"
            os_type="Windows"
        }
    }
    serviceapp={
        webapp5055040030="serviceplan500090"
        stagingwebapp505000400="serviceplan500090"
    }
  }
}

resource_tags = {
  "tags" = {
     department="Logistics"
     tier="Tier2"
  }
}