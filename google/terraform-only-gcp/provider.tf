provider "google" {
    credentials = "gcp-svc-account.json"
    project     = "${var.google_project}"
    region      = "${var.google_region}"
}