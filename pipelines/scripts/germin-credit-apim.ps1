param (
    $ml_subscription_id,
    $ml_workspace_rg,
    $ml_vnet_name,
    $ml_apim_name,
    $ml_apim_email,
    $ml_location
)
#
#Output of New-AzApiManagementVirtualNetwork is returned in SubnetResourceId
#
#$ml_subscription_id="513a7987-b0d9-4106-a24d-4b3f49136ea8"
#$ml_workspace_rg="blog-mlopsapim-rg"
#$ml_vnet_name="blog-mlopsapim-vnetv2"
#$ml_apim_name="blog-mlopsapim-apimv2"
#$ml_apim_email="rebremer@microsoft.com"
#$location="westeuroep"
#
$VirtualNetwork=New-AzApiManagementVirtualNetwork -SubnetResourceId "/subscriptions/$ml_subscription_id/resourceGroups/$ml_workspace_rg/providers/Microsoft.Network/virtualNetworks/$ml_vnet_name/subnets/apim"
New-AzApiManagement -Name $ml_apim_name -ResourceGroupName $ml_workspace_rg -Location "westeurope" -Organization $ml_apim_name -AdminEmail $ml_apim_email -VirtualNetwork $VirtualNetwork -VpnType "External"