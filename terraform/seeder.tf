locals {
  incidents_json_b64 = base64encode(file("${path.module}/app_data/incidents.json"))
  entrypoint_b64     = base64encode(file("${path.module}/app_data/entrypoint.sh"))
}

resource "docker_container" "seed_incidents" {
  name    = "incidents-seeder"
  image   = "alpine:3.19"
  restart = "no"
  must_run = false

  networks_advanced { name = docker_network.lab.name }

  # Monta el volumen donde dejaremos los ficheros
  volumes {
    volume_name    = docker_volume.incidents_data.name
    container_path = "/data"
    read_only      = false
  }

  # Pasamos el contenido como variables de entorno en base64
  env = [
    "INCIDENTS_JSON_B64=${local.incidents_json_b64}",
    "ENTRYPOINT_B64=${local.entrypoint_b64}",
  ]

  # Escribimos los ficheros dentro del volumen y salimos
  command = [
    "sh", "-lc", <<-EOC
      set -e
      echo "$INCIDENTS_JSON_B64" | base64 -d > /data/incidents.json
      echo "$ENTRYPOINT_B64" | base64 -d > /data/entrypoint.sh
      chmod +x /data/entrypoint.sh
    EOC
  ]
}
