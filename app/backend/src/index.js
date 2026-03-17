const express = require("express");
const cors    = require("cors");

const app  = express();
const PORT = process.env.PORT || 4000;
const ENV  = process.env.NODE_ENV || "development";

app.use(cors());
app.use(express.json());

// Health check — used by ALB target group health check
app.get("/api/health", (req, res) => {
  res.json({
    status:      "ok",
    service:     "backend",
    environment: ENV,
    timestamp:   new Date().toISOString(),
    db_host:     process.env.DB_HOST ? "configured" : "not set",
    s3_bucket:   process.env.S3_BUCKET ? "configured" : "not set"
  });
});

// Info endpoint
app.get("/api/info", (req, res) => {
  res.json({
    service:  "IaC POC Backend",
    version:  "1.0.0",
    environment: ENV,
    runtime:  process.version,
    uptime:   Math.floor(process.uptime()) + "s",
    infrastructure: {
      compute:  "AWS ECS Fargate",
      database: "PostgreSQL 16.2 on RDS",
      storage:  "S3",
      registry: "ECR",
      lb:       "Application Load Balancer"
    }
  });
});

// DB connectivity test (non-blocking — won't crash if DB not ready)
app.get("/api/db-check", async (req, res) => {
  if (!process.env.DB_HOST) {
    return res.json({ db: "not configured — set DB_HOST env var" });
  }
  try {
    const { Client } = require("pg");
    const client = new Client({
      host:     process.env.DB_HOST,
      port:     parseInt(process.env.DB_PORT || "5432"),
      database: process.env.DB_NAME || "postgres",
      user:     process.env.DB_USER || "dbadmin",
      password: process.env.DB_PASSWORD,
      ssl:      { rejectUnauthorized: false },
      connectionTimeoutMillis: 3000
    });
    await client.connect();
    const result = await client.query("SELECT version()");
    await client.end();
    res.json({ db: "connected", version: result.rows[0].version });
  } catch (err) {
    res.status(503).json({ db: "error", detail: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`Backend API running on port ${PORT} | env: ${ENV}`);
});
