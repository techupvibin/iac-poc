const express = require("express");
const axios   = require("axios");

const app  = express();
const PORT = process.env.PORT || 3000;
const API_URL = process.env.API_URL || "http://localhost:4000";
const ENV  = process.env.NODE_ENV || "development";

app.use(express.json());

// Health check
app.get("/", (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
      <head>
        <title>IaC POC — Frontend</title>
        <style>
          body { font-family: Arial, sans-serif; background: #0d1b3e; color: white; padding: 40px; }
          h1   { color: #00a8e8; }
          .card { background: #1a4b8c; padding: 20px; border-radius: 8px; margin: 20px 0; }
          .status { color: #00c896; font-weight: bold; }
        </style>
      </head>
      <body>
        <h1>IaC POC — Frontend Running</h1>
        <div class="card">
          <p>Environment: <span class="status">${ENV}</span></p>
          <p>Service: <span class="status">Frontend (Node.js)</span></p>
          <p>Deployed via: <span class="status">Terraform + GitLab CI/CD</span></p>
        </div>
        <div class="card">
          <p>Infrastructure: ECS Fargate + ALB + ECR</p>
          <p>Backend API: <a href="/api/health" style="color:#00a8e8">/api/health</a></p>
        </div>
      </body>
    </html>
  `);
});

// Proxy to backend
app.get("/api/*", async (req, res) => {
  try {
    const response = await axios.get(`${API_URL}${req.path}`);
    res.json(response.data);
  } catch (err) {
    res.status(502).json({ error: "Backend unavailable", detail: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Frontend running on port ${PORT} | env: ${ENV}`);
});
