import { Router } from 'express';
import { authenticate, requireRole, ROLES } from '@unifind/shared/auth';
import { notImplemented } from '@unifind/shared/errors';

export const router = Router();

// Tables blog_post / blog_comment already exist (db/migrations/001_init.sql).
// TODO (PBS 14.2–14.5): implement; every create/update/delete must call writeAudit().

router.get('/list', () => { throw notImplemented(); });                                   // GET  /blog/list
router.get('/:id', () => { throw notImplemented(); });                                    // GET  /blog/:id (post + comments)
router.post('/create', authenticate, () => { throw notImplemented(); });                  // POST /blog/create
router.post('/:id/comment', authenticate, () => { throw notImplemented(); });             // POST /blog/:id/comment
router.post('/:id/hide', authenticate, requireRole(ROLES.ADMIN), () => { throw notImplemented(); }); // admin moderation
