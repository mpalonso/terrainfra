resource "docker_container" "seed_backend" {
  name     = "seed-backend"
  image    = "alpine:3.19"
  restart  = "no"
  must_run = false

  networks_advanced { name = docker_network.lab.name }

  volumes {
    volume_name    = docker_volume.backend_vol.name
    container_path = "/backend"
  }

  env = [
    "BACKEND_ENTRYPOINT_B64=${local.backend_entrypoint_b64}",
    "BACKEND_APP_B64=${local.backend_app_b64}",
  ]

  command = [
    "sh", "-lc", <<-EOC
      set -e
      mkdir -p /backend
      echo "$BACKEND_ENTRYPOINT_B64" | base64 -d > /backend/entrypoint.sh
      echo "$BACKEND_APP_B64"        | base64 -d > /backend/app.py
      chmod +x /backend/entrypoint.sh
    EOC
  ]
}
