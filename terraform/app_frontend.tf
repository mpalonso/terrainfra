resource "docker_container" "web_frontend" {
  name  = "web-frontend"
  image = "node:20-alpine"

  depends_on = [docker_container.seed_frontend, docker_container.api_backend]

  networks_advanced { name = docker_network.lab.name }

  env = [
    "PORT=3000",
    "BACKEND_URL=http://localhost:5000"
  ]

  ports {
    internal = 3000
    external = 3000
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  volumes {
    volume_name    = docker_volume.frontend_vol.name
    container_path = "/frontend"
    read_only      = false
  }

  command = ["sh", "-lc", "cd /frontend && npm install --omit=dev && node server.js"]
}
