provider "google" {
  project = var.project_id
  region  = var.region

  user_project_override = true
  billing_project       = var.project_id
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

# Enable Google as a Sign-In Provider
resource "google_identity_platform_default_supported_idp_config" "google" {
  project       = var.project_id
  idp_id        = "google.com"
  enabled       = true
  client_id     = var.google_client_id
  client_secret = var.google_client_secret

  depends_on = [google_project_service.enabled_apis]
}

# Cloud SQL Instance (PostgreSQL)
resource "google_sql_database_instance" "instance" {
  name             = "chat-db-instance"
  region           = var.region
  database_version = "POSTGRES_15"
  project          = var.project_id

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true
    }
  }

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
  password = "changeme-use-secrets-later"
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
        value = "postgresql://chat_user:changeme-use-secrets-later@/chat_db?host=/cloudsql/${google_sql_database_instance.instance.connection_name}"
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.instance.connection_name]
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [google_project_service.enabled_apis]
}

# Cloud Run Service for Frontend
resource "google_cloud_run_v2_service" "frontend" {
  name     = "chat-frontend"
  location = var.region
  project  = var.project_id

  template {
    containers {
      image = "gcr.io/${var.project_id}/chat-frontend:latest"
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  depends_on = [google_project_service.enabled_apis]
}

# Allow unauthenticated access to the backend
resource "google_cloud_run_v2_service_iam_member" "backend_noauth" {
  location = google_cloud_run_v2_service.backend.location
  project  = google_cloud_run_v2_service.backend.project
  name     = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Allow unauthenticated access to the frontend
resource "google_cloud_run_v2_service_iam_member" "frontend_noauth" {
  location = google_cloud_run_v2_service.frontend.location
  project  = google_cloud_run_v2_service.frontend.project
  name     = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

output "backend_url" {
  value = google_cloud_run_v2_service.backend.uri
}

output "frontend_url" {
  value = google_cloud_run_v2_service.frontend.uri
}
