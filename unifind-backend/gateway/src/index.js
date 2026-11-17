import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import { createProxyMiddleware } from 'http-proxy-middleware';
import { config, serviceUrls } from '@unifind/shared/config';
import { errorHandler, notFoundHandler } from '@unifind/shared/errors';

/**
 * Public entry point for the React app and third parties (public REST API, PBS 15.3).
 * Every route is /api/<…> and is forwarded to the owning service with the /api prefix removed.
 * ORDER MATTERS: the more specific rules come first.
 */
const routes = [
  { name: 'auth',       target: serviceUrls.auth,       match: (p) => p.startsWith('/api/auth') },
  { name: 'rating',     target: serviceUrls.rating,     match: (p) => /^\/api\/university\/\d+\/rating\/?$/.test(p) || p.startsWith('/api/review') },
  { name: 'university', target: serviceUrls.university, match: (p) => p.startsWith('/api/university') },
  { name: 'test',       target: serviceUrls.test,       match: (p) => p.startsWith('/api/test') },
  { name: 'blog',       target: serviceUrls.blog,       match: (p) => p.startsWith('/api/blog') },
  { name: 'audit',      target: serviceUrls.audit,      match: (p) => p.startsWith('/api/audit') },
];

const app = express();
app.disable('x-powered-by');
app.use(helmet());
app.use(cors({ origin: config.corsOrigin }));

// Aggregated health of the whole backend.
app.get('/api/health', async (_req, res) => {
  const services = await Promise.all(
    routes.map(async ({ name, target }) => {
      try {
        const r = await fetch(`${target}/health`, { signal: AbortSignal.timeout(2000) });
        return { name, status: r.ok ? 'ok' : 'degraded' };
      } catch {
        return { name, status: 'down' };
      }
    }),
  );
  const ok = services.every((s) => s.status === 'ok');
  res.status(ok ? 200 : 503).json({ gateway: 'ok', status: ok ? 'ok' : 'degraded', services });
});

// No body parsing here – request bodies are streamed straight to the services.
for (const { name, target, match } of routes) {
  app.use(
    createProxyMiddleware({
      target,
      changeOrigin: true,
      pathFilter: (pathname) => match(pathname),
      pathRewrite: { '^/api': '' },
      on: {
        error: (err, _req, res) => {
          console.error(`[gateway] ${name}-service unreachable:`, err.message);
          if (!res.headersSent && typeof res.writeHead === 'function') {
            res.writeHead(502, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: { code: 'BAD_GATEWAY', message: `${name}-service is unavailable` } }));
          }
        },
      },
    }),
  );
}

app.use(notFoundHandler);
app.use(errorHandler);

const server = app.listen(config.ports.gateway, () => console.log(`[gateway] listening on :${config.ports.gateway}`));
process.on('SIGTERM', () => server.close(() => process.exit(0)));
process.on('SIGINT', () => server.close(() => process.exit(0)));
