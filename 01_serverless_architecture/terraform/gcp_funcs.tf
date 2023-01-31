resource "google_cloudfunctions_function" "sender" {
  name        = "fnc-sender"
  description = "sender"
  runtime     = "dotnet3"

  trigger_http        = true
  available_memory_mb = 128
  timeout             = 30
  entry_point         = "sender"

  environment_variables = {
    "RECEIVERADDR" = "????????????????????????????????????????????"
  }

  labels = {
    problem-space = "01"
  }
}

resource "google_cloudfunctions_functioon_iam_member" "invoker" {
  project        = google_cloudfunctions_function.sender.project
  region         = google_cloudfunctions_function.sender.region
  cloud_function = google_cloudfunctions_function.sender.name

  role   = "roles/cloudfunctions.invoker"
  member = "user:functionRunner@example.com" # ??????????????????

  # docs
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloudfunctions_function
  # https://cloud.google.com/functions/docs/reference/iam/roles
}
