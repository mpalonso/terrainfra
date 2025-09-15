resource "docker_container" "api_backend" {
  name  = "api-backend"
  image = "python:3.12-slim"

  depends_on = [docker_container.seed_backend]

  networks_advanced { name = docker_network.lab.name }

  env = [
    "FLASK_SECRET=devsecret", # cambia en el futuro
    "BACKEND_PORT=5000"
  ]

  ports {
    internal = 5000
    external = 5000
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  volumes {
    volume_name    = docker_volume.backend_vol.name
    container_path = "/backend"
    read_only      = false
  }

  command = ["/backend/entrypoint.sh"]
}
