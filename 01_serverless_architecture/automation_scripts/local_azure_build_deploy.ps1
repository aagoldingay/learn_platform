param (
    [string]
    $tenant_id = "",

    [bool]
    $deploy_azure = $true,

    [bool]
    $deploy_gcp = $false,

    [bool]
    $az_receiver = $false,

    [bool]
    $skip_build = $false,

    [bool]
    $skip_test = $false,

    [bool]
    $skip_infra = $false,

    [bool]
    $tf_apply_only = $false,

    [bool]
    $skip_code_deploy = $false
)

function Evaluate_Output {
    param(
        [string]
        $id,

        [string]
        $log
    )

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "# # $id FAILED"
        Write-Error $log
        exit
    }
    else {
        Write-Host "# # $id SUCCESSFUL"
    }
}

if (!$skip_build) {
    Write-Host "# BUILDING serverless_app ..."
    
    $build_output = $(dotnet build ../serverless_app "/p:DeployOnBuild=true /p:DeployTarget=Package;CreatePackageOnPublish=true")

    Evaluate_Output -id "BUILD" -log ($build_output -join "; ")
}

if (!$skip_test) {
    Write-Host "# RUNNING TESTS IN serverless_app ..."
    
    $test_output = $(dotnet test ../serverless_app)

    Evaluate_Output -id "TESTS" -log ($test_output -join "; ")
}

if (!$skip_code_deploy) {
    if ($deploy_azure -and !$deploy_gcp) {
        Write-Host "# PUBLISHING serverless_app ..."
        
        $az_receiver_publish_output = $(dotnet publish ../serverless_app/azure_host_receiver -c Release -o ./az_serverless_receiver)

        Evaluate_Output -id "PUBLISH" -log ($az_receiver_publish_output -join "; ")
        
        Compress-Archive -LiteralPath az_serverless_receiver -DestinationPath az_serverless_receiver.zip -Force

        $az_sender_publish_output = $(dotnet publish ../serverless_app/azure_host_sender -c Release -o ./az_serverless_sender)

        Evaluate_Output -id "PUBLISH" -log ($az_sender_publish_output -join "; ")
        
        Compress-Archive -LiteralPath az_serverless_sender -DestinationPath az_serverless_sender.zip -Force
    }

    # if ($deploy_gcp -and !$deploy_azure) {
    #     Write-Host "# PUBLISHING serverless_app/gcp_host ..."
        
    #     $publish_output = $(dotnet publish ../serverless_app/gcp_host --os linux -o ./serverless_app)
        
    #     Evaluate_Output
        
    #     Compress-Archive -LiteralPath serverless_app -DestinationPath gcp_serverless_app.zip
    # }
}

if (!$skip_infra) {
    $az_login_output = az login -t $tenant_id

    Evaluate_Output -id "AZURE LOGIN" -log ($az_login_output -join "; ")

    cd ../terraform
    Write-Host "# INITIALISING TERRAFORM"

    $tf_output = terraform init

    Evaluate_Output -id "TERRAFORM INIT" -log ($tf_output -join "; ")
    
    Write-Host "# VALIDATING TERRAFORM CONFIGURATION ..."

    $tf_output = terraform validate

    Evaluate_Output -id "TERRAFORM VALIDATE" -log ($tf_output -join "; ")

    Write-Host "# DEPLOYING INFRASTRUCTURE ..."
    
    if ($deploy_azure -and !$deploy_gcp) {
        $var_file = "az_only.tfvars"
        
    
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
    }

    if (!$tf_apply_only) {
        $tf_output = terraform plan -var-file=secrets.tfvars -var-file=$var_file

        Evaluate_Output -id "TERRAFORM PLAN" -log ($tf_output -join "; ")
    }

    $tf_output = terraform apply -var-file=secrets.tfvars -var-file=$var_file -auto-approve

    Evaluate_Output -id "TERRAFORM APPLY" -log ($tf_output -join "; ")
}

if (!$skip_code_deploy) {
    if ($deploy_azure -and !$deploy_gcp) {
        $receiver_deploy_output = az functionapp deployment source config-zip -g 01_serverless -n 01-serverless-receiver --src az_serverless_receiver.zip

        Evaluate_Output -id "RECEIVER DEPLOY" -log ($receiver_deploy_output -join "; ")
    
        $sender_deploy_output = az functionapp deployment source config-zip -g 01_serverless -n 01-serverless-sender --src az_serverless_sender.zip

        Evaluate_Output -id "SENDER DEPLOY" -log ($sender_deploy_output -join "; ")
    }
}