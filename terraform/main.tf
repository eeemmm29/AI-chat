provider "google" {
  project = var.project_id
  region  = var.region
}

# Identity Platform (Firebase Auth)
resource "google_identity_platform_config" "default" {
  project = var.project_id

  sign_in {
    allow_duplicate_emails = false

    email {
      enabled           = true
      password_required = true
    }
  }

  authorized_domains = [
    "localhost",
    "${var.project_id}.firebaseapp.com",
    "${var.project_id}.web.app",
  ]

  depends_on = [google_project_service.enabled_apis]
}

# Cloud SQL Instance (PostgreSQL)
resource "google_sql_database_instance" "instance" {
  name             = "chat-db-instance"
  region           = var.region
  database_version = "POSTGRES_15"
  project          = var.project_id

  settings {
    tier = "db-f1-micro" # Smallest tier for Free Tier / low cost
    
    ip_configuration {
      ipv4_enabled = true
    }
  }

  # Helps with cleanup during development, set to true for production
  deletion_protection = false 
  
  depends_on = [google_project_service.enabled_apis]
}

# Database
resource "google_sql_database" "database" {
  name     = "chat_db"
  instance = google_sql_database_instance.instance.name
}

# Database User
resource "google_sql_user" "users" {
  name     = "chat_user"
  instance = google_sql_database_instance.instance.name
  password = "changeme-use-secrets-later" # In prod, use Secret Manager
}

# Cloud Run Service for Backend
resource "google_cloud_run_v2_service" "backend" {
  name     = "chat-backend"
  location = var.region
  project  = var.project_id

  template {
    containers {
      image = "gcr.io/${var.project_id}/chat-backend:latest"
      
      env {
        name  = "DATABASE_URL"
        value = "postgresql://chat_user:changeme-use-secrets-later@/${google_sql_database.database.name}?host=/cloudsql/${google_sql_database_instance.instance.connection_name}"
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [google_project_service.enabled_apis]
}

# Allow unauthenticated access to the backend (for public API)
resource "google_cloud_run_v2_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.backend.location
  project  = google_cloud_run_v2_service.backend.project
  name     = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
