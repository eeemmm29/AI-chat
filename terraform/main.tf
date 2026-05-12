provider "google" {
  project = var.project_id
  region  = var.region

  user_project_override = true
  billing_project       = var.project_id
}

resource "google_project_service" "identityplatform" {
  service = "identitytoolkit.googleapis.com"
}

resource "google_project_service" "cloudrun" {
  service = "run.googleapis.com"
}

resource "google_identity_platform_config" "default" {
  project    = var.project_id
  depends_on = [google_project_service.identityplatform]
}
