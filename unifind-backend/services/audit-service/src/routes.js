import { Router } from 'express';
import { authenticate, requireRole, ROLES } from '@unifind/shared/auth';
import { query } from '@unifind/shared/db';
import { parsePaging } from '@unifind/shared/validate';

export const router = Router();

// GET /audit/list?action&entityType&actorId&page&pageSize – admin only (entries are written by the other services)
router.get('/list', authenticate, requireRole(ROLES.ADMIN), async (req, res) => {
  const { page, pageSize, offset } = parsePaging(req.query, { defaultSize: 50, maxSize: 200 });
  const params = [];
  const where = [];
  for (const [qp, col] of [['action', 'a.action'], ['entityType', 'a.entity_type'], ['actorId', 'a.actor_id']]) {
    if (req.query[qp]) { params.push(req.query[qp]); where.push(`${col}::text = $${params.length}`); }
  }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const total = (await query(`SELECT COUNT(*)::int AS n FROM audit_log a ${whereSql}`, params)).rows[0].n;
  const { rows } = await query(
    `SELECT a.id, a.actor_id AS "actorId", u.email AS "actorEmail", a.actor_role AS "actorRole",
            a.action, a.entity_type AS "entityType", a.entity_id AS "entityId", a.details, a.created_at AS "createdAt"
       FROM audit_log a LEFT JOIN app_user u ON u.id = a.actor_id ${whereSql}
      ORDER BY a.created_at DESC, a.id DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
    [...params, pageSize, offset]);
  res.json({ items: rows, total, page, pageSize });
});
