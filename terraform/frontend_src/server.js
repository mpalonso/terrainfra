import express from "express";
const app = express();

const PORT = process.env.PORT || 3000;
// El frontend llama a la API en localhost:5000 (configurable por env si quieres)
const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:5000";

app.use((req,res,next) => { res.setHeader("Cache-Control","no-store"); next(); });
app.use(express.static("./public"));

app.get("/config.js", (req,res) => {
  res.type("application/javascript").send(`window.__CONFIG__ = { BACKEND_URL: "${BACKEND_URL}" };`);
});

app.listen(PORT, () => {
  console.log(`Frontend listening on http://localhost:${PORT}`);
});
