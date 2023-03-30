param (
    [string]
    $project_name = "",

    [switch]
    $deploy_azure = $false,

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
    Evaluate_Output -id "AZURE LOGIN" -log ($az_login_output -join "; ")
    
    Set-Location ../terraform

    Write-Host "# DESTROYING INFRASTRUCTURE ..."
    
    if ($deploy_azure -and !$deploy_gcp) {
        $var_file = "az_only.tfvars"
    }
    elseif ($deploy_gcp -and !$deploy_azure) {
        $var_file = "gcp_only.tfvars"
    }
    else {    
        if ($az_receiver) {
            $var_file = "gcp_send_az_receive.tfvars"    
        }
        else {
            $var_file = "az_send_gcp_receive.tfvars"
        }
    }

    $tf_output = terraform destroy -var-file="vars/secrets.tfvars" -var-file="vars/$var_file" -auto-approve
    
    Evaluate_Output -id "TERRAFORM DESTROY" -log ($tf_output -join "; ")

}
else {

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
        Write-Host "# ARCHIVING C# PROJECT FOR GCP DEPLOY"
        
        if ($deploy_gcp) {
            if (!$deploy_az -or ($deploy_az -and !$az_receiver)) {
                $gcp_receiver_output = Compress-Archive -LiteralPath ../serverless_app -DestinationPath gcp_host_receiver.zip -Force
                Evaluate_Output -id "GCP RECEIVER ARCHIVE" -log ($gcp_receiver_output -join "; ")
            }

            if (!$deploy_az -or ($deploy_azure -and $az_receiver)) {
                $gcp_sender_output = Compress-Archive -LiteralPath ../serverless_app -DestinationPath gcp_host_sender.zip -Force
                Evaluate_Output -id "GCP SENDER ARCHIVE" -log ($gcp_sender_output -join "; ")
            }
            # }
        }
    }

    if (!$skip_infra) {
        Set-Location ../terraform
        Write-Host "# INITIALISING TERRAFORM"

        $tf_output = terraform init

        Evaluate_Output -id "TERRAFORM INIT" -log ($tf_output -join "; ")
        
        Write-Host "# VALIDATING TERRAFORM CONFIGURATION ..."

        $tf_output = terraform validate

        Evaluate_Output -id "TERRAFORM VALIDATE" -log ($tf_output -join "; ")

        Write-Host "# DEPLOYING INFRASTRUCTURE ..."
        
        if ($deploy_azure -and !$deploy_gcp) {
            $var_file = "az_only.tfvars"
        }
        elseif ($deploy_gcp -and !$deploy_azure) {
            $var_file = "gcp_only.tfvars"
    
        }
        else {
            if ($az_receiver) {
                $var_file = "gcp_send_az_receive.tfvars"
    
            }
            else {
                $var_file = "az_send_gcp_receive.tfvars"
            }
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
            Set-Location ../serverless_app/azure_host_receiver
            $receiver_deploy_output = func azure functionapp publish $project_name-receiver

            Evaluate_Output -id "RECEIVER DEPLOY" -log ($receiver_deploy_output -join "; ")
        
            Set-Location ../azure_host_sender
            $sender_deploy_output = func azure functionapp publish $project_name-sender

            Evaluate_Output -id "SENDER DEPLOY" -log ($sender_deploy_output -join "; ")
        }
        elseif ($deploy_gcp -and !$deploy_azure) {
            # nothing
        }
        else {
            if ($az_receiver) {
                Set-Location ../serverless_app/azure_host_receiver
                $receiver_deploy_output = func azure functionapp publish $project_name-receiver

                Evaluate_Output -id "RECEIVER DEPLOY" -log ($receiver_deploy_output -join "; ")
            }
            else {
                Set-Location .../serverless_app/azure_host_sender
                $sender_deploy_output = func azure functionapp publish $project_name-sender

                Evaluate_Output -id "SENDER DEPLOY" -log ($sender_deploy_output -join "; ")
            }
        }
    }

}