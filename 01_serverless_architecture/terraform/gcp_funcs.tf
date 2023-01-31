resource "google_cloudfunctions_function" "sender" {
  count       = var.deploy_gcp && var.gcp_send ? 1 : 0
  name        = "fnc-sender"
  description = "sender"
  runtime     = "dotnet6"

  trigger_http        = true
  available_memory_mb = 128
  timeout             = 30
  entry_point         = "sender"

  environment_variables = {
    "RECEIVERADDR" = var.gcp_receive ? google_cloudfunctions_function.receiver[0].https_trigger_url : "https://${azurerm_linux_function_app.receiver[0].default_hostname}/api/receiver?code=${data.azurerm_function_app_host_keys.receiver[0].default_function_key}"
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

  trigger_http        = true
  available_memory_mb = 128
  timeout             = 30
  entry_point         = "receiver"

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
