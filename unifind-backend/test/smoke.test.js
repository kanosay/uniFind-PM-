// End-to-end smoke test against a RUNNING stack (npm run dev) with a migrated + seeded DB.
//   BASE_URL=http://localhost:3000 npm test
import assert from 'node:assert/strict';
import { test } from 'node:test';

const BASE = process.env.BASE_URL || 'http://localhost:3000';
const call = async (path, { method = 'GET', body, token } = {}) => {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: { 'Content-Type': 'application/json', ...(token && { Authorization: `Bearer ${token}` }) },
    body: body && JSON.stringify(body),
  });
  return { status: res.status, body: await res.json().catch(() => null) };
};
const email = `smoke${Date.now()}@example.com`;
let token;

test('gateway health aggregates all services', async () => {
  const r = await call('/api/health');
  assert.equal(r.status, 200);
  assert.equal(r.body.services.length, 6);
});

test('GET /university/list returns seeded universities with paging', async () => {
  const r = await call('/api/university/list?pageSize=5');
  assert.equal(r.status, 200);
  assert.equal(r.body.total, 26);
  assert.equal(r.body.items.length, 5);
});

test('filtering, sorting and empty state', async () => {
  const pub = await call('/api/university/list?type=public&pageSize=100');
  assert.equal(pub.body.total, 8);
  const empty = await call('/api/university/list?q=zzzzzz');
  assert.deepEqual(empty.body.items, []);
  const bad = await call('/api/university/list?sort=nonsense');
  assert.equal(bad.status, 400);
});

test('GET /university/:id returns faculties; unknown id is 404', async () => {
  const list = await call('/api/university/list?q=Charles');
  const id = list.body.items[0].id;
  const r = await call(`/api/university/${id}`);
  assert.equal(r.body.faculties.length, 17);
  assert.equal((await call('/api/university/999999')).status, 404);
  assert.equal((await call('/api/university/abc')).status, 400);
});

test('search and compare', async () => {
  const s = await call('/api/university/search?q=Faculty of Law');
  assert.ok(s.body.total >= 1);
  const c = await call('/api/university/compare?ids=1,2');
  assert.equal(c.body.items.length, 2);
  assert.equal((await call('/api/university/compare?ids=1')).status, 400);
});

test('register, login, me', async () => {
  const reg = await call('/api/auth/register', { method: 'POST', body: { email, password: 'password123', displayName: 'Smoke' } });
  assert.equal(reg.status, 201);
  assert.equal((await call('/api/auth/register', { method: 'POST', body: { email, password: 'password123', displayName: 'x' } })).status, 409);
  assert.equal((await call('/api/auth/login', { method: 'POST', body: { email, password: 'wrongwrong' } })).status, 401);
  const login = await call('/api/auth/login', { method: 'POST', body: { email, password: 'password123' } });
  token = login.body.token;
  assert.equal((await call('/api/auth/me', { token })).body.user.email, email);
});

test('rating + review flow (one review per user)', async () => {
  const before = await call('/api/university/1/rating');
  assert.equal(before.status, 200);
  assert.equal(before.body.rankedGlobally, false);
  assert.equal((await call('/api/review/create', { method: 'POST', body: { universityId: 1, rating: 5 } })).status, 401);
  const ok = await call('/api/review/create', { method: 'POST', token, body: { universityId: 1, rating: 4, comment: 'Good' } });
  assert.equal(ok.status, 201);
  assert.equal((await call('/api/review/create', { method: 'POST', token, body: { universityId: 1, rating: 5 } })).status, 409);
  assert.equal((await call('/api/review/create', { method: 'POST', token, body: { universityId: 2, rating: 9 } })).status, 400);
  const after = await call('/api/university/1/rating');
  assert.ok(after.body.reviewCount >= 1);
});

test('audit list is admin-only; stubs return 501', async () => {
  assert.equal((await call('/api/audit/list')).status, 401);
  assert.equal((await call('/api/audit/list', { token })).status, 403);
  assert.equal((await call('/api/blog/list')).status, 501);
  assert.equal((await call('/api/test/questions')).status, 501);
});
