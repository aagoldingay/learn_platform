param (
    [string]
    $tenant_id = "",

    [switch]
    $deploy_azure = $true,

    [switch]
    $deploy_gcp = $false,

    [switch]
    $az_receiver = $false,

    [switch]
    $skip_build = $false,

    [switch]
    $skip_test = $false,

    [switch]
    $skip_infra = $false,

    [switch]
    $tf_apply_only = $false,

    [switch]
    $skip_code_deploy = $false,

    [switch]
    $destroy = $false
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

if ($destroy) {

    $az_login_output = az login -t $tenant_id
    
    Evaluate_Output -id "AZURE LOGIN" -log ($az_login_output -join "; ")
    
    cd ../terraform

    Write-Host "# DESTROYING INFRASTRUCTURE ..."
    
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

    $tf_output = terraform destroy -var-file="vars/secrets.tfvars" -var-file="vars/$var_file" -auto-approve
    
    Evaluate_Output -id "TERRAFORM DESTROY" -log ($tf_output -join "; ")

} else {

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
        # if ($deploy_gcp -and !$deploy_azure) {
        #     Write-Host "# PUBLISHING serverless_app/gcp_host ..."

        # dotnet publish ../serverless_app/gcp_host_receiver -o gcp_host_receiver
        # Compress-Archive -LiteralPath gcp_host_receiver -DestinationPath gcp_host_receiver.zip

        # dotnet publish ../serverless_app/gcp_host_sender -o gcp_host_sender
        # Compress-Archive -LiteralPath gcp_host_sender -DestinationPath gcp_host_sender.zip -Force
            
        #     $publish_output = $(dotnet publish ../serverless_app/gcp_host --os linux -o ./serverless_app)
            
        #     Evaluate_Output
            
        #     Compress-Archive -LiteralPath serverless_app -DestinationPath gcp_serverless_app.zip -Force
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
            $tf_output = terraform plan -var-file="vars/secrets.tfvars" -var-file="vars/$var_file"

            Evaluate_Output -id "TERRAFORM PLAN" -log ($tf_output -join "; ")
        }

        Write-Host "# # APPLYING CONFIGURATION ..."

        $tf_output = terraform apply -var-file="vars/secrets.tfvars" -var-file="vars/$var_file" -auto-approve

        Evaluate_Output -id "TERRAFORM APPLY" -log ($tf_output -join "; ")
    }

    if (!$skip_code_deploy) {
        if ($deploy_azure -and !$deploy_gcp) {
            cd ../serverless_app/azure_host_receiver
            $receiver_deploy_output = func azure functionapp publish 01-serverless-receiver

            Evaluate_Output -id "RECEIVER DEPLOY" -log ($receiver_deploy_output -join "; ")
        
            cd ../azure_host_sender
            $sender_deploy_output = func azure functionapp publish 01-serverless-sender

            Evaluate_Output -id "SENDER DEPLOY" -log ($sender_deploy_output -join "; ")
        }
    }

}