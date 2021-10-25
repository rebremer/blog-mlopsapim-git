param (
    $ml_workspace_rg,
    $ml_apim_name,
    $ml_deployment_name,
    $ml_tenant_id
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
#

((Get-Content -path pipelines/scripts/api_policy_template.xml -Raw) -replace '{tenant_id}', $ml_tenant_id) | Set-Content -Path pipelines/scripts/api_policy.xml

$Api = Get-AzAPIManagement -ResourceGroupName $ml_workspace_rg -Name $ml_apim_name
$apiContext = New-AzApiManagementContext -ResourceGroupName $api.resourcegroupname -ServiceName $api.name
#
$oldapi = Get-AzApiManagementApi -Context $apiContext -Name "testprivv2"
Remove-AzApiManagementApi -context $apiContext -ApiId $oldapi.ApiId
#
$uri="http://172.19.0.7:80/api/v1/service/$ml_deployment_name"
$newapi = New-AzApiManagementApi -context $apiContext -SubscriptionRequired:$false -name "testprivv2" -ServiceUrl $uri -protocols @('http','https') -path "testprivv2"
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