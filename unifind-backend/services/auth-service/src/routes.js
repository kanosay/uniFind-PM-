import bcrypt from 'bcryptjs';
import { Router } from 'express';
import { writeAudit } from '@unifind/shared/audit';
import { authenticate, signToken } from '@unifind/shared/auth';
import { badRequest, conflict, notFound, notImplemented, unauthorized } from '@unifind/shared/errors';
import { requireString } from '@unifind/shared/validate';
import * as users from './dao/userDao.js';

export const router = Router();
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// POST /auth/register – public self-registration always creates a *student*.
router.post('/register', async (req, res) => {
  const email = requireString(req.body, 'email', { max: 254 }).toLowerCase();
  if (!EMAIL_RE.test(email)) throw badRequest('email is not valid');
  const password = requireString(req.body, 'password', { min: 8, max: 128 });
  const displayName = requireString(req.body, 'displayName', { min: 1, max: 80 });

  let user;
  try {
    user = await users.create({ email, passwordHash: await bcrypt.hash(password, 10), displayName });
  } catch (err) {
    if (err.code === '23505') throw conflict('An account with this email already exists');
    throw err;
  }
  await writeAudit({ actor: user, action: 'user.register', entityType: 'user', entityId: user.id });
  res.status(201).json({ user, token: signToken(user) });
});

// POST /auth/login
router.post('/login', async (req, res) => {
  const email = requireString(req.body, 'email', { max: 254 }).toLowerCase();
  const password = requireString(req.body, 'password', { max: 128 });
  const row = await users.findByEmailWithHash(email);
  const ok = row?.passwordHash && (await bcrypt.compare(password, row.passwordHash));
  if (!ok) throw unauthorized('Invalid email or password');
  const { passwordHash, ...user } = row;
  res.json({ user, token: signToken(user) });
});

// GET /auth/me
router.get('/me', authenticate, async (req, res) => {
  const user = await users.findById(req.user.id);
  if (!user) throw notFound('User no longer exists');
  res.json({ user });
});

// GET /auth/google – TODO (PBS 5.3 / 7.3): Google OAuth 2.0 login (passport-google-oauth20 or google-auth-library).
router.get('/google', () => { throw notImplemented('Google login is not implemented yet'); });
