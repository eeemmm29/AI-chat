variable "gcp_services" {
  description = "List of GCP services to enable"
  type        = list(string)
  default = [
    "run.googleapis.com",             # Cloud Run
    "sqladmin.googleapis.com",        # PostgreSQL
    "identitytoolkit.googleapis.com", # Auth
    "secretmanager.googleapis.com"    # Security
  ]
}

resource "google_project_service" "enabled_apis" {
  for_each = toset(var.gcp_services)
  project  = var.project_id
  service  = each.key

  # Prevents services from being disabled if you delete them from the list
  disable_on_destroy = false
}
