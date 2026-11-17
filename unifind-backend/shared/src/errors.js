export class HttpError extends Error {
  constructor(status, code, message, details) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export const badRequest = (msg, details) => new HttpError(400, 'BAD_REQUEST', msg, details);
export const unauthorized = (msg = 'Authentication required') => new HttpError(401, 'UNAUTHORIZED', msg);
export const forbidden = (msg = 'Insufficient permissions') => new HttpError(403, 'FORBIDDEN', msg);
export const notFound = (msg = 'Not found') => new HttpError(404, 'NOT_FOUND', msg);
export const conflict = (msg) => new HttpError(409, 'CONFLICT', msg);
export const notImplemented = (msg = 'Not implemented yet') => new HttpError(501, 'NOT_IMPLEMENTED', msg);

export function notFoundHandler(req, _res, next) {
  next(notFound(`Route ${req.method} ${req.path} not found`));
}

// eslint-disable-next-line no-unused-vars
export function errorHandler(err, req, res, _next) {
  if (err instanceof HttpError) {
    return res.status(err.status).json({ error: { code: err.code, message: err.message, details: err.details } });
  }
  if (err?.type === 'entity.parse.failed') {
    return res.status(400).json({ error: { code: 'BAD_REQUEST', message: 'Invalid JSON body' } });
  }
  console.error(`[error] ${req.method} ${req.originalUrl}`, err);
  res.status(500).json({ error: { code: 'INTERNAL', message: 'Internal server error' } });
}
