import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import { config } from './config.js';
import { pool } from './db.js';
import { errorHandler, notFoundHandler } from './errors.js';

/**
 * Standard bootstrap for every microservice.
 *   bootstrapService({ name, port, routes: [['/university', router], ...] })
 * Gives each service: security headers, CORS, JSON parsing, GET /health, 404 + error handling.
 */
export function bootstrapService({ name, port, routes }) {
  const app = express();
  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors({ origin: config.corsOrigin }));
  app.use(express.json({ limit: '100kb' }));

  app.get('/health', async (_req, res) => {
    let db = 'up';
    try { await pool.query('SELECT 1'); } catch { db = 'down'; }
    res.status(db === 'up' ? 200 : 503).json({ service: name, status: db === 'up' ? 'ok' : 'degraded', db });
  });

  for (const [path, router] of routes) app.use(path, router);
  app.use(notFoundHandler);
  app.use(errorHandler);

  const server = app.listen(port, () => console.log(`[${name}] listening on :${port}`));
  const shutdown = () => server.close(() => pool.end().finally(() => process.exit(0)));
  process.on('SIGTERM', shutdown);
  process.on('SIGINT', shutdown);
  return { app, server };
}
