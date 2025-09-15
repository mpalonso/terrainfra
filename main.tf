# Red para aislar el contenedor (opcional pero recomendado)
resource "docker_network" "lab" {
  name = "tf-net"
}

# Imagen de NGINX
resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = false
}

# Contenedor NGINX publicado en localhost:8080
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
    external = 8081
    ip       = "0.0.0.0"
    protocol = "tcp"
  }
}
