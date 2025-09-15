locals {
  # Backend
  backend_entrypoint_b64 = base64encode(file("${path.module}/backend_src/entrypoint.sh"))
  backend_app_b64        = base64encode(file("${path.module}/backend_src/app.py"))

  # Frontend
  fe_pkg_b64    = base64encode(file("${path.module}/frontend_src/package.json"))
  fe_server_b64 = base64encode(file("${path.module}/frontend_src/server.js"))
  fe_index_b64  = base64encode(file("${path.module}/frontend_src/public/index.html"))
  fe_app_b64    = base64encode(file("${path.module}/frontend_src/public/app.js"))
  fe_css_b64    = base64encode(file("${path.module}/frontend_src/public/style.css"))
}
