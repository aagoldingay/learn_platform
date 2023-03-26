resource "google_storage_bucket" "function_store" {
  count    = var.deploy_gcp ? 1 : 0
  name     = "${var.project_name}-deploy-store"
  location = "EU"
}

# requires the following commands to be run first, from /automation_scripts:
# dotnet publish ../serverless_app/gcp_host_receiver -o gcp_host_receiver
# Compress-Archive -LiteralPath gcp_host_receiver -DestinationPath gcp_host_receiver.zip
resource "google_storage_bucket_object" "receiver" {
  count  = var.deploy_gcp && var.gcp_receive ? 1 : 0
  name   = "gcp_host_receiver.zip"
  bucket = google_storage_bucket.function_store[0].name
  source = "../automation_scripts/gcp_host_receiver.zip"
}

# requires the following commands to be run first, from /automation_scripts:
# dotnet publish ../serverless_app/gcp_host_sender -o gcp_host_sender
# Compress-Archive -LiteralPath gcp_host_sender -DestinationPath gcp_host_sender.zip
resource "google_storage_bucket_object" "sender" {
  count  = var.deploy_gcp && var.gcp_send ? 1 : 0
  name   = "gcp_host_sender.zip"
  bucket = google_storage_bucket.function_store[0].name
  source = "../automation_scripts/gcp_host_sender.zip"
}

resource "google_cloudfunctions_function" "sender" {
  count       = var.deploy_gcp && var.gcp_send ? 1 : 0
  name        = "fnc-sender"
  description = "sender"
  runtime     = "dotnet6"

  source_archive_bucket = google_storage_bucket.function_store[0].name
  source_archive_object = google_storage_bucket_object.sender[0].name

  trigger_http                 = true
  available_memory_mb          = 128
  timeout                      = 30
  entry_point                  = "gcp_host_sender.sender"
  https_trigger_security_level = "SECURE_ALWAYS"

  environment_variables = {
    "RECEIVERADDR" = var.gcp_receive ? google_cloudfunctions_function.receiver[0].https_trigger_url : "https://${azurerm_windows_function_app.receiver[0].default_hostname}/api/receiver?code=${data.azurerm_function_app_host_keys.receiver[0].default_function_key}"
  }

  build_environment_variables = {
    "GOOGLE_BUILDABLE" = "serverless_app/gcp_host_sender/gcp_host_sender.csproj"
  }

  labels = {
    problem-space = "01"
  }
}

resource "google_cloudfunctions_function_iam_member" "send_invoker" {
  count          = var.deploy_gcp && var.gcp_send ? 1 : 0
  project        = google_cloudfunctions_function.sender[0].project
  region         = google_cloudfunctions_function.sender[0].region
  cloud_function = google_cloudfunctions_function.sender[0].name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"

  # docs
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function
}

resource "google_cloudfunctions_function" "receiver" {
  count       = var.deploy_gcp && var.gcp_receive ? 1 : 0
  name        = "fnc-receiver"
  description = "receiver"
  runtime     = "dotnet6"

  source_archive_bucket = google_storage_bucket.function_store[0].name
  source_archive_object = google_storage_bucket_object.receiver[0].name

  trigger_http                 = true
  available_memory_mb          = 128
  timeout                      = 30
  entry_point                  = "gcp_host_receiver.receiver"
  https_trigger_security_level = "SECURE_ALWAYS"

  build_environment_variables = {
    "GOOGLE_BUILDABLE" = "serverless_app/gcp_host_receiver/gcp_host_receiver.csproj"
  }

  labels = {
    problem-space = "01"
  }
}

resource "google_cloudfunctions_function_iam_member" "receiver_invoker" {
  count          = var.deploy_gcp && var.gcp_receive ? 1 : 0
  project        = google_cloudfunctions_function.receiver[0].project
  region         = google_cloudfunctions_function.receiver[0].region
  cloud_function = google_cloudfunctions_function.receiver[0].name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"

  # docs
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function
}
