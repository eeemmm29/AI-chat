variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "google_client_id" {
  description = "The Google OAuth Client ID"
  type        = string
}

variable "google_client_secret" {
  description = "The Google OAuth Client Secret"
  type        = string
  sensitive   = true
}
