import { badRequest } from './errors.js';

export function parseId(value, name = 'id') {
  const n = Number(value);
  if (!Number.isInteger(n) || n <= 0 || n > 2147483647) throw badRequest(`${name} must be a positive integer`);
  return n;
}

export function parsePaging(query, { defaultSize = 20, maxSize = 100 } = {}) {
  const page = query.page === undefined ? 1 : Number(query.page);
  const pageSize = query.pageSize === undefined ? defaultSize : Number(query.pageSize);
  if (!Number.isInteger(page) || page < 1) throw badRequest('page must be an integer >= 1');
  if (!Number.isInteger(pageSize) || pageSize < 1 || pageSize > maxSize) {
    throw badRequest(`pageSize must be an integer between 1 and ${maxSize}`);
  }
  return { page, pageSize, offset: (page - 1) * pageSize };
}

export function requireString(body, field, { min = 1, max = 5000 } = {}) {
  const v = body?.[field];
  if (typeof v !== 'string' || v.trim().length < min || v.length > max) {
    throw badRequest(`${field} must be a string of ${min}–${max} characters`);
  }
  return v.trim();
}

export const escapeLike = (s) => s.replace(/[\\%_]/g, (c) => `\\${c}`);
