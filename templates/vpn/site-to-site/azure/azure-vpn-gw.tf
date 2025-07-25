## Azure side resources/services
# Azure Virtual Network
data "azurerm_virtual_network" "existing" {

  name                = var.vpn_config.azure.virtual_network_name
  resource_group_name = var.vpn_config.azure.resource_group_name
}

# Gateway Subnet (Azure requirement: "GatewaySubnet" is required for VPN Gateway)
resource "azurerm_subnet" "gateway" {

  name                 = "GatewaySubnet"
  resource_group_name  = var.vpn_config.azure.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.existing.name
  address_prefixes     = [var.vpn_config.azure.gateway_subnet_cidr]
}

# Public IPs for Azure VPN Gateway
resource "azurerm_public_ip" "pub_ip" {
  count = 2 # 2 Public IPs for Active-Active configuration

  name                = "${var.vpn_config.terrarium_id}-vpn-ip-${count.index + 1}"
  location            = var.vpn_config.azure.region
  resource_group_name = var.vpn_config.azure.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"] # Availability zones
}

# Azure VPN Gateway with pre-allocated APIPA addresses
resource "azurerm_virtual_network_gateway" "vpn_gw" {

  name                = "${var.vpn_config.terrarium_id}-vpn-gateway"
  location            = var.vpn_config.azure.region
  resource_group_name = var.vpn_config.azure.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = true
  sku           = var.vpn_config.azure.vpn_sku

  ip_configuration {
    name                          = "${var.vpn_config.terrarium_id}-gateway-config-1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub_ip[0].id
    subnet_id                     = azurerm_subnet.gateway.id
  }

  ip_configuration {
    name                          = "${var.vpn_config.terrarium_id}-gateway-config-2"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pub_ip[1].id
    subnet_id                     = azurerm_subnet.gateway.id
  }

  # https://learn.microsoft.com/en-us/azure/vpn-gateway/bgp-howto
  # The Azure APIPA BGP IP address field is optional. (APIPA: Automatic Private IP Addressing) 
  # If your on-premises VPN devices use APIPA address for BGP, 
  # you must select an address from the Azure-reserved APIPA address range for VPN, 
  # which is from 169.254.21.0 to 169.254.22.255.
  bgp_settings {
    asn = var.vpn_config.azure.bgp_asn
    peering_addresses {
      ip_configuration_name = "${var.vpn_config.terrarium_id}-gateway-config-1"
      apipa_addresses = [
        # Note - Inside tunnel addresses generated by AWS may not be used 
        # due to Azure's APIPA address range (from 169.254.21.0 to 169.254.22.255).

        # Example of var.vpn_config.azure.apipa_cidrs is ["169.254.21.0/30", "169.254.21.4/30", "169.254.22.0/30", "169.254.22.4/30"]
        for i, cidr in var.vpn_config.azure.apipa_cidrs : cidrhost(cidr, 2) if i % 2 == 0
        # Example: "169.254.21.2", "169.254.22.2"
        # The 1st value is used aws_vpn_connection.to_azure[0].tunnel1_cgw_inside_address
        # The 2nd value is used aws_vpn_connection.to_azure[0].tunnel2_cgw_inside_address
      ]
    }
    peering_addresses {
      ip_configuration_name = "${var.vpn_config.terrarium_id}-gateway-config-2"
      apipa_addresses = [
        # Note - Inside tunnel addresses generated by AWS may not be used 
        # due to Azure's APIPA address range (from 169.254.21.0 to 169.254.22.255).

        # Example of var.vpn_config.azure.apipa_cidrs is ["169.254.21.0/30", "169.254.21.4/30", ",169.254.22.0/30", "169.254.22.4/30"]
        for i, cidr in var.vpn_config.azure.apipa_cidrs : cidrhost(cidr, 2) if i % 2 == 1
        # Example: "169.254.21.6", "169.254.22.6"
        # The 1st value is used aws_vpn_connection.to_azure[1].tunnel1_cgw_inside_address
        # The 2nd value is used aws_vpn_connection.to_azure[1].tunnel2_cgw_inside_address
      ]
    }
  }
}
