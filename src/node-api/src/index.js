import express from "express";
import { apiReference } from "@scalar/express-api-reference";
import { getConfig, getHealth } from "./configService.js";

const app = express();
const port = Number(process.env.PORT ?? 3000);

const openApiDocument = {
  openapi: "3.1.0",
  info: {
    title: "Node API",
    version: "1.0.0"
  },
  paths: {
    "/health": {
      get: {
        summary: "Get service health",
        responses: {
          "200": {
            description: "Service health",
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    status: { type: "string" },
                    service: { type: "string" }
                  },
                  required: ["status", "service"]
                }
              }
            }
          }
        }
      }
    },
    "/config": {
      get: {
        summary: "Get resolved non-sensitive configuration",
        responses: {
          "200": {
            description: "Resolved configuration",
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    applicationName: { type: "string" },
                    message: { type: "string" },
                    environment: { type: "string" },
                    externalApiBaseUrl: { type: "string" }
                  },
                  required: ["applicationName", "message", "environment", "externalApiBaseUrl"]
                }
              }
            }
          },
          "500": {
            description: "Configuration load failed"
          }
        }
      }
    },
    "/secret": {
      get: {
        summary: "Report whether the external API secret was resolved",
        responses: {
          "200": {
            description: "Secret resolution status",
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    secretResolved: { type: "boolean" }
                  },
                  required: ["secretResolved"]
                }
              }
            }
          },
          "500": {
            description: "Configuration load failed"
          }
        }
      }
    },
    "/feature-flags": {
      get: {
        summary: "Get feature flag values",
        responses: {
          "200": {
            description: "Feature flag values",
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    betaGreeting: { type: "boolean" }
                  },
                  required: ["betaGreeting"]
                }
              }
            }
          },
          "500": {
            description: "Configuration load failed"
          }
        }
      }
    }
  }
};

app.get("/openapi.json", (_req, res) => {
  res.json(openApiDocument);
});

app.use(
  "/scalar",
  apiReference({
    content: openApiDocument
  })
);

app.get("/health", (_req, res) => {
  res.json(getHealth());
});

app.get("/config", async (_req, res, next) => {
  try {
    const config = await getConfig();
    res.json({
      applicationName: config.applicationName,
      message: config.message,
      environment: config.environment,
      externalApiBaseUrl: config.externalApiBaseUrl
    });
  } catch (error) {
    next(error);
  }
});

app.get("/secret", async (_req, res, next) => {
  try {
    const config = await getConfig();
    res.json({
      secretResolved: Boolean(config.externalApiApiKey)
    });
  } catch (error) {
    next(error);
  }
});

app.get("/feature-flags", async (_req, res, next) => {
  try {
    const config = await getConfig();
    res.json({
      betaGreeting: config.betaGreeting
    });
  } catch (error) {
    next(error);
  }
});

app.use((error, _req, res, _next) => {
  console.error(error.message);
  res.status(500).json({ error: "Configuration load failed" });
});

app.listen(port, () => {
  console.log(`node-api listening on ${port}`);
});
