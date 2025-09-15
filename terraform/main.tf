resource "docker_network" "lab" {
  name = "tf-net"
}

resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = false
}

resource "docker_container" "web" {
  name  = "web"
  image = docker_image.nginx.image_id

  # Mantener NGINX en primer plano para que el contenedor no salga
  command = ["nginx", "-g", "daemon off;"]

  networks_advanced {
    name = docker_network.lab.name
  }

  ports {
    internal = 80
    external = 8080
    ip       = "0.0.0.0"
    protocol = "tcp"
  }
}
