resource "docker_image" "incidents_app" {
  # Imagen base con Python 3.12 slim (para Flask)
  name         = "python:3.12-slim"
  keep_locally = false
}
