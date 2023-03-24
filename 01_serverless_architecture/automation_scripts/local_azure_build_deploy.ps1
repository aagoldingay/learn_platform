param (
    [string]
    $tenant_id,

    [bool]
    $deploy_azure = $true,

    [bool]
    $deploy_gcp,

    [bool]
    $az_receiver
)

Write-Host "# BUILDING serverless_app ..."

$build_output = $(dotnet build ../serverless_app "/p:DeployOnBuild=true /p:DeployTarget=Package;CreatePackageOnPublish=true")

if ($LASTEXITCODE -ne 0) {
    Write-Warning -Message ($build_output -join "; ")
    throw "# # BUILD FAILED"
} else {
    Write-Host "# # BUILD SUCCESSFUL"
}

Write-Host "# RUNNING TESTS IN serverless_app ..."

$test_output = $(dotnet test ../serverless_app)

if ($LASTEXITCODE -ne 0) {
    Write-Warning -Message ($build_output -join "; ")
    throw "# # TESTS FAILED"
} else {
    Write-Host "# # TESTS SUCCESSFUL"
}

if ($deploy_azure -and !$deploy_gcp) {
    Write-Host "# PUBLISHING serverless_app/azure_host ..."
    
    $az_receiver_publish_output = $(dotnet publish ../serverless_app/azure_host_receiver -c Release -o ./az_serverless_receiver)
    
    if ($LASTEXITCODE -ne 0) {
        Write-Warning -Message ($build_output -join "; ")
        throw "# # PUBLISH FAILED"
    } else {
        Write-Host "# # PUBLISH SUCCESSFUL"
    }
    
    Compress-Archive -LiteralPath az_serverless_receiver -DestinationPath az_serverless_receiver.zip -Force

    $az_sender_publish_output = $(dotnet publish ../serverless_app/azure_host_sender -c Release -o ./az_serverless_sender)

    if ($LASTEXITCODE -ne 0) {
        Write-Warning -Message ($build_output -join "; ")
        throw "# # PUBLISH FAILED"
    } else {
        Write-Host "# # PUBLISH SUCCESSFUL"
    }
    
    Compress-Archive -LiteralPath az_serverless_sender -DestinationPath az_serverless_sender.zip -Force
}

# if ($deploy_gcp -and !$deploy_azure) {
#     Write-Host "# PUBLISHING serverless_app/gcp_host ..."
    
#     $publish_output = $(dotnet publish ../serverless_app/gcp_host --os linux -o ./serverless_app)
    
#     if ($LASTEXITCODE -ne 0) {
#         Write-Warning -Message ($build_output -join "; ")
#         throw "# # PUBLISH FAILED"
#     } else {
#         Write-Host "# # PUBLISH SUCCESSFUL"
#     }
    
#     Compress-Archive -LiteralPath serverless_app -DestinationPath gcp_serverless_app.zip
# }

# Write-Host "# DEPLOYING INFRASTRUCTURE ..."

# if ($deploy_azure -and !$deploy_gcp) {
#     az login -t $tenant_id
#     cd ../terraform
#     terraform plan -var-file az_only.tfvars

# } elseif ($deploy_gcp -and !$deploy_azure) {

#     Write-Host "# # GCP ONLY ..."

# } else {

#     Write-Host "# # AZ AND GCP"
#     az login -t $tenant_id

#     if ($az_receiver) {

#         # deploy where az hosts receiver

#     } else {

#         # deploy where gcp hosts receiver

#     }
# }

az functionapp deployment source config-zip -g 01_serverless -n 01-serverless-receiver --src az_serverless_receiver.zip

az functionapp deployment source config-zip -g 01_serverless -n 01-serverless-sender --src az_serverless_sender.zip