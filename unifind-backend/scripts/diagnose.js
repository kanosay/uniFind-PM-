// Prints the raw result of register -> login -> me, straight to the auth-service AND through the gateway.
//   node scripts/diagnose.js
const email = `diag${Date.now()}@example.com`;
const show = async (label, url, opts = {}) => {
  try {
    const res = await fetch(url, opts);
    const text = await res.text();
    console.log(`\n${label}\n  ${opts.method || 'GET'} ${url} -> ${res.status}\n  ${text.slice(0, 400)}`);
    try { return JSON.parse(text); } catch { return null; }
  } catch (e) {
    console.log(`\n${label}\n  ${url} -> FAILED: ${e.message}`);
    return null;
  }
};
const json = (b) => ({ method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(b) });

console.log('Node', process.version, process.platform);
await show('1. register (gateway)', 'http://localhost:3000/api/auth/register', json({ email, password: 'password123', displayName: 'Diag' }));
const login = await show('2. login (gateway)', 'http://localhost:3000/api/auth/login', json({ email, password: 'password123' }));
const token = login?.token;
console.log(`\n   token received: ${token ? 'yes (' + token.length + ' chars)' : 'NO'}`);
const auth = { headers: { Authorization: `Bearer ${token}` } };
await show('3. me via gateway', 'http://localhost:3000/api/auth/me', auth);
await show('4. me directly on auth-service', 'http://localhost:3001/auth/me', auth);
