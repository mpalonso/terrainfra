# Puedes usar un recurso docker_image si quieres, pero con cadena basta
resource "docker_container" "incidents_app" {
  name  = "incidents-app"
  image = "python:3.12-slim"

  depends_on = [docker_container.seed_incidents]

  networks_advanced { name = docker_network.lab.name }

  ports {
    internal = 5000
    external = 5000
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  # Montamos el volumen ya poblado por el seeder
  volumes {
    volume_name    = docker_volume.incidents_data.name
    container_path = "/data"
    read_only      = false
  }

  # Arrancamos con el script dentro del volumen
  command = ["/data/entrypoint.sh"]
}
