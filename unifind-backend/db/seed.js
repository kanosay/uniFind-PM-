// Loads db/data/prague_universities_en.json into the database. Idempotent (safe to re-run).
//   node db/seed.js
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import bcrypt from 'bcryptjs';
import { pool, withTransaction } from '@unifind/shared/db';

const file = path.join(path.dirname(fileURLToPath(import.meta.url)), 'data/prague_universities_en.json');
const { universities } = JSON.parse(fs.readFileSync(file, 'utf8'));
const blank = (v) => (v === undefined || v === null || String(v).trim() === '' ? null : String(v).trim());

await withTransaction(async (c) => {
  let faculties = 0;
  await c.query('TRUNCATE TABLE university, test_question RESTART IDENTITY CASCADE');
  for (const u of universities) {
    const { rows } = await c.query(
      `INSERT INTO university (name, abbreviation, type, category, address, website, note)
       VALUES ($1,$2,$3,$4,$5,$6,$7)
       ON CONFLICT (name) DO UPDATE SET
         abbreviation = EXCLUDED.abbreviation, type = EXCLUDED.type, category = EXCLUDED.category,
         address = EXCLUDED.address, website = EXCLUDED.website, note = EXCLUDED.note, updated_at = now()
       RETURNING id`,
      [u.name, blank(u.abbreviation), u.type, u.category, blank(u.address), blank(u.website), blank(u.note)],
    );
    const universityId = rows[0].id;
    for (const f of u.faculties ?? []) {
      await c.query(
        `INSERT INTO faculty (university_id, name, abbreviation, city, unit_type)
         VALUES ($1,$2,$3,$4,$5)
         ON CONFLICT (university_id, name) DO UPDATE SET
           abbreviation = EXCLUDED.abbreviation, city = EXCLUDED.city, unit_type = EXCLUDED.unit_type`,
        [universityId, f.name, blank(f.abbreviation), blank(f.city), f.unit_type],
      );
      faculties++;
    }
  }

  // Global ranking sources named in the PBS (entries are loaded in a later task, PBS 11.3).
  await c.query(
    `INSERT INTO ranking_source (code, name, url) VALUES
       ('QS',   'QS World University Rankings', 'https://www.topuniversities.com/world-university-rankings'),
       ('THE',  'Times Higher Education World University Rankings', 'https://www.timeshighereducation.com/world-university-rankings'),
       ('ARWU', 'Academic Ranking of World Universities (Shanghai)', 'https://www.shanghairanking.com/rankings/arwu')
     ON CONFLICT (code) DO NOTHING`,
  );

  // Seed test questions for the Career Guidance Test
  const questionsFile = path.join(path.dirname(fileURLToPath(import.meta.url)), 'data/test_questions_seed.sql');
  const questionsSql = fs.readFileSync(questionsFile, 'utf8');
  await c.query(questionsSql);
  console.log('Seeded test questions.');

  // Seed majors with tags for career test matching
  const majorsFile = path.join(path.dirname(fileURLToPath(import.meta.url)), 'data/majors_seed.sql');
  const majorsSql = fs.readFileSync(majorsFile, 'utf8');
  await c.query(majorsSql);
  const { rows: majorCount } = await c.query('SELECT COUNT(*)::int AS n FROM major');
  console.log(`Seeded ${majorCount[0].n} majors with career tags.`);

  // Optional admin account for local development.
  const { ADMIN_EMAIL, ADMIN_PASSWORD } = process.env;
  if (ADMIN_EMAIL && ADMIN_PASSWORD) {
    await c.query(
      `INSERT INTO app_user (email, password_hash, display_name, role)
       VALUES ($1, $2, 'Administrator', 'admin') ON CONFLICT (email) DO NOTHING`,
      [ADMIN_EMAIL.toLowerCase(), await bcrypt.hash(ADMIN_PASSWORD, 10)],
    );
    console.log(`Admin account ensured: ${ADMIN_EMAIL}`);
  }
  console.log(`Seeded ${universities.length} universities and ${faculties} faculties/units.`);
});

await pool.end();
