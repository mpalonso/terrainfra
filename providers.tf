provider "docker" {
  # si usas Docker rootless y tu socket está en otra ruta, cámbialo aquí
  host = "unix:///var/run/docker.sock"
}
