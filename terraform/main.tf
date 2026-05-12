provider "google" {
  project = var.project_id
  region  = var.region
}

# Identity Platform (Firebase Auth)
resource "google_identity_platform_config" "default" {
  project    = var.project_id
  depends_on = [google_project_service.enabled_apis]
}

# Example Cloud SQL Instance (PostgreSQL)
# resource "google_sql_database_instance" "instance" {
#   name             = "chat-db-instance"
#   region           = var.region
#   database_version = "POSTGRES_15"
#   settings {
#     tier = "db-f1-micro"
#   }
#   depends_on = [google_project_service.enabled_apis]
# }

# Example Cloud Run Service for Backend
# resource "google_cloud_run_v2_service" "backend" {
#   name     = "chat-backend"
#   location = var.region
#   template {
#     containers {
#       image = "gcr.io/${var.project_id}/chat-backend"
#     }
#   }
#   depends_on = [google_project_service.enabled_apis]
# }
