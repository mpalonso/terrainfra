resource "docker_container" "incidents_app" {
  name  = "incidents-app"
  image = docker_image.incidents_app.image_id

  command = ["/data/entrypoint.sh"]

  networks_advanced {
    name = docker_network.lab.name
  }

  ports {
    internal = 5000
    external = 5000
    ip       = "0.0.0.0"
    protocol = "tcp"
  }

  volumes {
    host_path      = "${path.root}/../data"
    container_path = "/data"
  }
}