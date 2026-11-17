import { Router } from 'express';
import { badRequest, notFound } from '@unifind/shared/errors';
import { parseId, parsePaging, requireString } from '@unifind/shared/validate';
import * as dao from './dao/universityDao.js';

export const router = Router();
const str = (v) => (typeof v === 'string' && v.trim() ? v.trim() : undefined);

// GET /university/list?q&type&category&city&major&language&maxFee&sort=name|units|rating|ranking&order=asc|desc&page&pageSize
router.get('/list', async (req, res) => {
  const { page, pageSize, offset } = parsePaging(req.query);
  const sort = str(req.query.sort) ?? 'name';
  if (!dao.isValidSort(sort)) throw badRequest('sort must be one of: name, units, rating, ranking');
  let maxFee;
  if (req.query.maxFee !== undefined) {
    maxFee = Number(req.query.maxFee);
    if (!Number.isFinite(maxFee) || maxFee < 0) throw badRequest('maxFee must be a number >= 0');
  }
  const { items, total } = await dao.list({
    q: str(req.query.q), type: str(req.query.type), category: str(req.query.category), city: str(req.query.city),
    major: str(req.query.major), language: str(req.query.language), maxFee,
    sort, order: str(req.query.order), limit: pageSize, offset,
  });
  // Empty array + total 0 => the UI shows the "No matching universities" state (PBS 10.4).
  res.json({ items, total, page, pageSize });
});

// GET /university/search?q=…  (name, abbreviation, faculty or major)
router.get('/search', async (req, res) => {
  const q = requireString(req.query, 'q', { min: 2, max: 100 });
  const { page, pageSize, offset } = parsePaging(req.query);
  const { items, total } = await dao.search(q, { limit: pageSize, offset });
  res.json({ items, total, page, pageSize, query: q });
});

// GET /university/compare?ids=1,2,3   (2–4 universities)
router.get('/compare', async (req, res) => {
  const ids = [...new Set(String(req.query.ids ?? '').split(',').filter(Boolean).map((v) => parseId(v, 'ids[]')))];
  if (ids.length < 2 || ids.length > 4) throw badRequest('ids must contain 2 to 4 distinct university ids');
  const items = await dao.getManyForCompare(ids);
  if (items.length !== ids.length) throw notFound('One or more universities were not found');
  res.json({ items });
});

// GET /university/:id
router.get('/:id', async (req, res) => {
  const university = await dao.getById(parseId(req.params.id));
  if (!university) throw notFound('University not found');
  res.json(university);
});
