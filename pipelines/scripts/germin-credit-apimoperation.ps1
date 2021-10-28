param (
    $ml_workspace_rg,
    $ml_apim_name,
    $ml_endpoint_url,
    $ml_tenant_id,
    $ml_key
)
#
((Get-Content -path pipelines/scripts/api_policy_template.xml -Raw) -replace '{tenant_id}', $ml_tenant_id) | Set-Content -Path pipelines/scripts/api_policy.xml
#
$positionscore=$ml_endpoint_url.IndexOf("/score")
$url=$ml_endpoint_url.Substring(0, $positionscore)
#
$Api = Get-AzAPIManagement -ResourceGroupName $ml_workspace_rg -Name $ml_apim_name
$apiContext = New-AzApiManagementContext -ResourceGroupName $api.resourcegroupname -ServiceName $api.name
# Add secret as named value

$ml_key_object = Get-AzApiManagementNamedValue -Context $apiContext -Name "AMLKey"
if($ml_key_object -eq $null){
   New-AzApiManagementNamedValue -Context $apiContext -NamedValueId "AMLKey" -Name "AMLKey" -Value $ml_key -Secret
}else
{
   Set-AzApiManagementNamedValue -Context $apiContext -NamedValueId "AMLKey" -Value $ml_key -Secret $True
}

#
# Test if old api already exists
$oldapi = Get-AzApiManagementApi -Context $apiContext -Name "testprivv2"
#
#
if($oldapi -eq $null){
   # API does not yet exist
}else
{
   Remove-AzApiManagementApi -context $apiContext -ApiId $oldapi.ApiId
}
#
$newapi = New-AzApiManagementApi -context $apiContext -SubscriptionRequired:$false -name "testprivv2" -ServiceUrl $url -protocols @('http','https') -path "testprivv2"
$newapi.SubscriptionRequired=$false
Set-AzApiManagementApi -InputObject $newapi -Name $newapi.Name -ServiceUrl $newapi.ServiceUrl -Protocols $newapi.Protocols
#
Set-AzApiManagementPolicy -Context $apiContext -PolicyFilePath pipelines/scripts/api_policy.xml -ApiId $newapi.ApiId
#
New-AzApiManagementOperation -Context $apiContext -ApiId $newapi.ApiId -OperationId "score" -Name "score" -Method "POST" -UrlTemplate "/score" -Description "Use this operation to score"
#
#$virtualNetwork = New-AzApiManagementVirtualNetwork -SubnetResourceId "/subscriptions/513a7987-b0d9-4106-a24d-4b3f49136ea8/resourceGroups/blog-mlopsapim-rg/providers/Microsoft.Network/virtualNetworks/blog-mlopsapim-vnet/subnets/apim"
#$Api.VpnType = "External"
#$Api.VirtualNetwork = $virtualNetwork
#Set-AzApiManagement -InputObject $Api