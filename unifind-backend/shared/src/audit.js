import { query } from './db.js';

/**
 * Append an entry to the audit log (create/update/delete actions).
 * Pass `client` to take part in a running transaction; defaults to the pool.
 * Failures are logged but never break the business action.
 */
export async function writeAudit(
  { actor, action, entityType, entityId = null, details = {} },
  client = { query },
) {
  try {
    await client.query(
      `INSERT INTO audit_log (actor_id, actor_role, action, entity_type, entity_id, details)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [actor?.id ?? null, actor?.role ?? null, action, entityType, entityId === null ? null : String(entityId), details],
    );
  } catch (err) {
    console.error('[audit] failed to write entry', err.message);
  }
}
