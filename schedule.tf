resource "google_compute_resource_policy" "uptime_schedule" {
  name        = var.name
  project     = var.project_id
  region      = var.region
  description = "Start and stop instances"
  instance_schedule_policy {
    vm_start_schedule {
      schedule = var.uptime_schedule["start"]
    }
    vm_stop_schedule {
      schedule = var.uptime_schedule["stop"]
    }
    time_zone = var.uptime_schedule["time_zone"]
  }
}