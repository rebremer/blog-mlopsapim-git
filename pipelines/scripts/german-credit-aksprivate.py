from azureml.core.authentication import AzureCliAuthentication
from azureml.core.compute import AksCompute, ComputeTarget
from azureml.core import Workspace
import os
import sys
#
workspace=sys.argv[1]
subscription_id=sys.argv[2]
resource_grp=sys.argv[3]
vnet_name = sys.argv[4]
aks_name=sys.argv[5]
network_range=sys.argv[6]
dns_service_ip=sys.argv[7]
#
cli_auth = AzureCliAuthentication()
ws = Workspace(workspace_name = workspace,
               subscription_id = subscription_id,
               resource_group = resource_grp,
               auth=cli_auth)
#
print("Creating new aks cluster")
# Subnet to use for AKS
subnet_name = "aks"
#
# Create AKS configuration
prov_config=AksCompute.provisioning_configuration(load_balancer_type="InternalLoadBalancer")
# Set info for existing virtual network to create the cluster in
prov_config.vnet_resourcegroup_name = resource_grp
prov_config.vnet_name = vnet_name
prov_config.service_cidr = network_range
prov_config.dns_service_ip = dns_service_ip
prov_config.subnet_name = subnet_name
prov_config.load_balancer_subnet = subnet_name
prov_config.docker_bridge_cidr = "172.17.0.1/16"
# Create compute target
aks_target = ComputeTarget.create(workspace = ws, name = aks_name, provisioning_configuration = prov_config)
# Wait for the operation to complete
aks_target.wait_for_completion(show_output = True)