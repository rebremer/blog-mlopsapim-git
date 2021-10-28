param (
    $ml_subscription_id,
    $ml_workspace_rg,
    $ml_vnet_name,
    $ml_apim_name,
    $ml_apim_email,
    $ml_location
)
#
$VirtualNetwork=New-AzApiManagementVirtualNetwork -SubnetResourceId "/subscriptions/$ml_subscription_id/resourceGroups/$ml_workspace_rg/providers/Microsoft.Network/virtualNetworks/$ml_vnet_name/subnets/apim"
New-AzApiManagement -Name $ml_apim_name -ResourceGroupName $ml_workspace_rg -Location "westeurope" -Organization $ml_apim_name -AdminEmail $ml_apim_email -VirtualNetwork $VirtualNetwork -VpnType "External"