import jwt from 'jsonwebtoken';
import { config } from './config.js';
import { forbidden, unauthorized } from './errors.js';

export const ROLES = Object.freeze({ STUDENT: 'student', ADMIN: 'admin' });

export function signToken(user) {
  return jwt.sign({ sub: user.id, role: user.role, email: user.email }, config.jwtSecret, {
    expiresIn: config.jwtExpiresIn,
  });
}

/** Express middleware: requires a valid Bearer token and sets req.user = { id, role, email }. */
export function authenticate(req, _res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');
  if (scheme !== 'Bearer' || !token) return next(unauthorized());
  try {
    const p = jwt.verify(token, config.jwtSecret);
    req.user = { id: p.sub, role: p.role, email: p.email };
    next();
  } catch (err) {
    // In development, say *why* the token was rejected (never do this in production).
    if (config.env !== 'production') console.warn(`[auth] token rejected: ${err.name}: ${err.message}`);
    next(unauthorized(config.env !== 'production' ? `Invalid or expired token (${err.message})` : 'Invalid or expired token'));
  }
}

/** Express middleware factory: requireRole('admin'). Use after authenticate. */
export const requireRole = (...roles) => (req, _res, next) =>
  roles.includes(req.user?.role) ? next() : next(forbidden());
