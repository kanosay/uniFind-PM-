import { Router } from 'express';
import { writeAudit } from '@unifind/shared/audit';
import { authenticate } from '@unifind/shared/auth';
import { withTransaction } from '@unifind/shared/db';
import { badRequest, conflict, notFound } from '@unifind/shared/errors';
import { parseId, parsePaging } from '@unifind/shared/validate';
import * as dao from './dao/ratingDao.js';

export const universityRatingRouter = Router();
export const reviewRouter = Router();

// GET /university/:id/rating – global rankings + average student rating
universityRatingRouter.get('/:id/rating', async (req, res) => {
  const id = parseId(req.params.id);
  if (!(await dao.universityExists(id))) throw notFound('University not found');
  res.json(await dao.getRating(id));
});

// GET /review/list?universityId=…
reviewRouter.get('/list', async (req, res) => {
  const universityId = parseId(req.query.universityId, 'universityId');
  const { page, pageSize, offset } = parsePaging(req.query, { defaultSize: 10, maxSize: 50 });
  res.json({ items: await dao.listReviews(universityId, { limit: pageSize, offset }), page, pageSize });
});

// POST /review/create – one review per user per university; audited
reviewRouter.post('/create', authenticate, async (req, res) => {
  const universityId = parseId(req.body?.universityId, 'universityId');
  const rating = req.body?.rating;
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) throw badRequest('rating must be an integer from 1 to 5');
  const comment = typeof req.body?.comment === 'string' ? req.body.comment.trim().slice(0, 2000) || null : null;
  if (!(await dao.universityExists(universityId))) throw notFound('University not found');

  try {
    const review = await withTransaction(async (client) => {
      const created = await dao.createReview(client, { userId: req.user.id, universityId, rating, comment });
      await writeAudit(
        { actor: req.user, action: 'review.create', entityType: 'review', entityId: created.id, details: { universityId, rating } },
        client,
      );
      return created;
    });
    res.status(201).json(review);
  } catch (err) {
    if (err.code === '23505') throw conflict('You have already reviewed this university');
    throw err;
  }
});
