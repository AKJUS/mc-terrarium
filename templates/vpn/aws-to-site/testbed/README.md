# Testbed SSH Access Guide

## Prerequisites

1. Install OpenTofu
2. Apply the OpenTofu configuration

## Network Details required to build AWS-Site VPN

To view the network configuration details for each CSP:

```shell
# Show all network details
tofu output network_details
```

```shell
# Show specific CSP details
tofu output -json network_details | jq .aws
tofu output -json network_details | jq .azure
tofu output -json network_details | jq .gcp
tofu output -json network_details | jq .alibaba
tofu output -json network_details | jq .ibm

# Example: Get Azure gateway subnet CIDR
tofu output -json network_details | jq -r .azure.gateway_subnet_cidr
```

## Setup SSH Access

1. Save the private key to a file:

```shell
tofu output -json ssh_info | jq -r .private_key > private_key.pem
chmod 600 private_key.pem
```

## Connect to VMs

Use the following commands to connect to each VM:

### AWS Instance

```shell
tofu output -json ssh_info | jq -r .aws.command
```

### GCP Instance

```shell
tofu output -json ssh_info | jq -r .gcp.command
```

### Azure Instance

```shell
tofu output -json ssh_info | jq -r .azure.command
```

### Alibaba Instance

```shell
tofu output -json ssh_info | jq -r .alibaba.command
```

### IBM Instance

```shell
tofu output -json ssh_info | jq -r .ibm.command
```

## All at once

```shell
# Show specific CSP details
tofu output -json network_details | jq .aws
tofu output -json network_details | jq .azure
tofu output -json network_details | jq .gcp
tofu output -json network_details | jq .alibaba
tofu output -json network_details | jq .ibm

# Save the private key to a file
tofu output -json ssh_info | jq -r .private_key > private_key.pem
chmod 600 private_key.pem

# Connect to VMs
tofu output -json ssh_info | jq -r .aws.command
tofu output -json ssh_info | jq -r .azure.command
tofu output -json ssh_info | jq -r .gcp.command
tofu output -json ssh_info | jq -r .alibaba.command
tofu output -json ssh_info | jq -r .ibm.command
```

## Need to delete as a separate process during testing

1. Run the following command

```shell
tofu state rm aws_route_table.imported_route_table
```

2. Truncate `imports.tf` and perform tofu destroy.

## Note

This testbed uses OpenTofu. Make sure to use `tofu` commands.
