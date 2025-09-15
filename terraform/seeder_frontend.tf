resource "docker_container" "seed_frontend" {
  name     = "seed-frontend"
  image    = "alpine:3.19"
  restart  = "no"
  must_run = false

  networks_advanced { name = docker_network.lab.name }

  volumes {
    volume_name    = docker_volume.frontend_vol.name
    container_path = "/frontend"
  }

  env = [
    "FE_PKG_B64=${local.fe_pkg_b64}",
    "FE_SERVER_B64=${local.fe_server_b64}",
    "FE_INDEX_B64=${local.fe_index_b64}",
    "FE_APP_B64=${local.fe_app_b64}",
    "FE_CSS_B64=${local.fe_css_b64}",
  ]

  command = [
    "sh", "-lc", <<-EOC
      set -e
      mkdir -p /frontend/public
      echo "$FE_PKG_B64"   | base64 -d > /frontend/package.json
      echo "$FE_SERVER_B64"| base64 -d > /frontend/server.js
      echo "$FE_INDEX_B64" | base64 -d > /frontend/public/index.html
      echo "$FE_APP_B64"   | base64 -d > /frontend/public/app.js
      echo "$FE_CSS_B64"   | base64 -d > /frontend/public/style.css
    EOC
  ]
}
