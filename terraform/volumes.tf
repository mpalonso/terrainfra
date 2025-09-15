resource "docker_volume" "backend_vol" {
  name = "backend_vol"
}

resource "docker_volume" "frontend_vol" {
  name = "frontend_vol"
}
