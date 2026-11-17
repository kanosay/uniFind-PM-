// Minimal migration runner:  node db/migrate.js [--reset]
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { pool } from '@unifind/shared/db';

const dir = path.join(path.dirname(fileURLToPath(import.meta.url)), 'migrations');
const reset = process.argv.includes('--reset');

const client = await pool.connect();
try {
  if (reset) {
    console.log('Dropping all tables (--reset)…');
    await client.query('DROP SCHEMA public CASCADE; CREATE SCHEMA public;');
  }
  await client.query(`CREATE TABLE IF NOT EXISTS schema_migrations (
    name TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT now())`);
  const done = new Set((await client.query('SELECT name FROM schema_migrations')).rows.map((r) => r.name));

  for (const file of fs.readdirSync(dir).filter((f) => f.endsWith('.sql')).sort()) {
    if (done.has(file)) continue;
    console.log(`Applying ${file}`);
    try {
      await client.query('BEGIN');
      await client.query(fs.readFileSync(path.join(dir, file), 'utf8'));
      await client.query('INSERT INTO schema_migrations (name) VALUES ($1)', [file]);
      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    }
  }
  console.log('Migrations up to date.');
} finally {
  client.release();
  await pool.end();
}
