import { query } from '@unifind/shared/db';

const PUBLIC = 'id, email, display_name AS "displayName", role, created_at AS "createdAt"';

export async function create({ email, passwordHash, displayName, role = 'student' }) {
  const { rows } = await query(
    `INSERT INTO app_user (email, password_hash, display_name, role) VALUES ($1,$2,$3,$4) RETURNING ${PUBLIC}`,
    [email, passwordHash, displayName, role],
  );
  return rows[0];
}

export async function findByEmailWithHash(email) {
  const { rows } = await query(`SELECT ${PUBLIC}, password_hash AS "passwordHash" FROM app_user WHERE email = $1`, [email]);
  return rows[0] ?? null;
}

export async function findById(id) {
  const { rows } = await query(`SELECT ${PUBLIC} FROM app_user WHERE id = $1`, [id]);
  return rows[0] ?? null;
}
