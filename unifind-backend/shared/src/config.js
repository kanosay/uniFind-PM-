import path from 'node:path';
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';

// Load <repo>/.env (real environment variables always win, e.g. in the cloud).
dotenv.config({ path: path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../.env') });

const DEV_SECRET = 'dev-only-secret-change-me';
const env = process.env.NODE_ENV || 'development';

if (env === 'production' && (!process.env.JWT_SECRET || process.env.JWT_SECRET === DEV_SECRET)) {
  throw new Error('JWT_SECRET must be set to a strong value in production');
}

const num = (v, d) => (v ? Number(v) : d);

export const config = {
  env,
  databaseUrl: process.env.DATABASE_URL || 'postgres://unifind:unifind@localhost:5432/unifind',
  databaseSsl: process.env.DATABASE_SSL === 'true',
  jwtSecret: process.env.JWT_SECRET || DEV_SECRET,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '12h',
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:5173',
  ports: {
    gateway: num(process.env.PORT || process.env.GATEWAY_PORT, 3000),
    auth: num(process.env.AUTH_PORT, 3001),
    university: num(process.env.UNIVERSITY_PORT, 3002),
    rating: num(process.env.RATING_PORT, 3003),
    test: num(process.env.TEST_PORT, 3004),
    blog: num(process.env.BLOG_PORT, 3005),
    audit: num(process.env.AUDIT_PORT, 3006),
  },
};

// Where the gateway finds each service (override in the cloud).
export const serviceUrls = {
  auth: process.env.AUTH_URL || `http://localhost:${config.ports.auth}`,
  university: process.env.UNIVERSITY_URL || `http://localhost:${config.ports.university}`,
  rating: process.env.RATING_URL || `http://localhost:${config.ports.rating}`,
  test: process.env.TEST_URL || `http://localhost:${config.ports.test}`,
  blog: process.env.BLOG_URL || `http://localhost:${config.ports.blog}`,
  audit: process.env.AUDIT_URL || `http://localhost:${config.ports.audit}`,
};
