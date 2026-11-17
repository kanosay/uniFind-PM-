import { query } from '@unifind/shared/db';
import { escapeLike } from '@unifind/shared/validate';

// Derived columns shared by list / detail / compare.
const SUMMARY_COLS = `
  u.id, u.name, u.abbreviation, u.type, u.category, u.address, u.website, u.note,
  (SELECT COUNT(*)::int FROM faculty f WHERE f.university_id = u.id) AS "unitCount",
  (SELECT COUNT(*)::int FROM major m WHERE m.university_id = u.id)   AS "majorCount",
  (SELECT ROUND(AVG(r.rating), 2)::float FROM review r WHERE r.university_id = u.id) AS "averageRating",
  (SELECT COUNT(*)::int FROM review r WHERE r.university_id = u.id)  AS "reviewCount",
  (SELECT MIN(e.rank_position) FROM ranking_entry e WHERE e.university_id = u.id) AS "bestGlobalRank"`;

const SORTS = {
  name: 'u.name',
  units: '"unitCount"',
  rating: '"averageRating"',
  ranking: '"bestGlobalRank"',
};

/**
 * Filtered, sorted, paginated list. Filters: q, type, category, city, major, language, maxFee.
 * Sorting by ranking is ascending by default (rank 1 first), by rating/units descending.
 */
export async function list({ q, type, category, city, major, language, maxFee, sort = 'name', order, limit, offset }) {
  const params = [];
  const p = (v) => (params.push(v), `$${params.length}`);
  const where = [];

  if (q) where.push(`(u.name ILIKE ${p(`%${escapeLike(q)}%`)} OR u.abbreviation ILIKE $${params.length})`);
  if (type) where.push(`lower(u.type) = lower(${p(type)})`);
  if (category) where.push(`lower(u.category) = lower(${p(category)})`);
  if (city) where.push(`EXISTS (SELECT 1 FROM faculty f WHERE f.university_id = u.id AND f.city ILIKE ${p(`%${escapeLike(city)}%`)})`);

  const majorConds = [];
  if (major) majorConds.push(`m.name ILIKE ${p(`%${escapeLike(major)}%`)}`);
  if (language) majorConds.push(`lower(m.language) = lower(${p(language)})`);
  if (maxFee !== undefined) majorConds.push(`m.tuition_fee_eur_year <= ${p(maxFee)}`);
  if (majorConds.length) where.push(`EXISTS (SELECT 1 FROM major m WHERE m.university_id = u.id AND ${majorConds.join(' AND ')})`);

  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const total = (await query(`SELECT COUNT(*)::int AS n FROM university u ${whereSql}`, params)).rows[0].n;

  const defaultDir = sort === 'name' || sort === 'ranking' ? 'ASC' : 'DESC';
  const dir = order ? (order.toLowerCase() === 'desc' ? 'DESC' : 'ASC') : defaultDir;
  const { rows } = await query(
    `SELECT ${SUMMARY_COLS} FROM university u ${whereSql}
     ORDER BY ${SORTS[sort]} ${dir} NULLS LAST, u.name ASC
     LIMIT ${p(limit)} OFFSET ${p(offset)}`,
    params,
  );
  return { items: rows, total };
}

export const isValidSort = (s) => Object.hasOwn(SORTS, s);

export async function getById(id) {
  const { rows } = await query(`SELECT ${SUMMARY_COLS} FROM university u WHERE u.id = $1`, [id]);
  if (!rows[0]) return null;
  const [faculties, majors] = await Promise.all([
    query(
      `SELECT id, name, abbreviation, city, unit_type AS "unitType"
         FROM faculty WHERE university_id = $1 ORDER BY unit_type <> 'Faculty', name`, [id]),
    query(
      `SELECT id, name, degree_level AS "degreeLevel", language,
              tuition_fee_eur_year::float AS "tuitionFeeEurYear", faculty_id AS "facultyId"
         FROM major WHERE university_id = $1 ORDER BY name`, [id]),
  ]);
  return { ...rows[0], faculties: faculties.rows, majors: majors.rows };
}

/** Search by university name/abbreviation, faculty/unit name or major name. */
export async function search(term, { limit, offset }) {
  const like = `%${escapeLike(term)}%`;
  const where = `
    WHERE u.name ILIKE $1 OR u.abbreviation ILIKE $1
       OR EXISTS (SELECT 1 FROM faculty f WHERE f.university_id = u.id AND (f.name ILIKE $1 OR f.abbreviation ILIKE $1))
       OR EXISTS (SELECT 1 FROM major m   WHERE m.university_id = u.id AND m.name ILIKE $1)`;
  const total = (await query(`SELECT COUNT(*)::int AS n FROM university u ${where}`, [like])).rows[0].n;
  const { rows } = await query(
    `SELECT ${SUMMARY_COLS},
       ARRAY(SELECT f.name FROM faculty f WHERE f.university_id = u.id AND f.name ILIKE $1 ORDER BY f.name LIMIT 5) AS "matchedUnits",
       ARRAY(SELECT m.name FROM major m   WHERE m.university_id = u.id AND m.name ILIKE $1 ORDER BY m.name LIMIT 5) AS "matchedMajors"
     FROM university u ${where}
     ORDER BY (lower(u.name) = lower($2)) DESC, (u.name ILIKE $1) DESC, u.name
     LIMIT $3 OFFSET $4`,
    [like, term, limit, offset],
  );
  return { items: rows, total };
}

export async function getManyForCompare(ids) {
  const { rows } = await query(
    `SELECT ${SUMMARY_COLS},
       (SELECT COALESCE(jsonb_object_agg(unit_type, n), '{}') FROM
          (SELECT unit_type, COUNT(*)::int AS n FROM faculty f WHERE f.university_id = u.id GROUP BY unit_type) t) AS "unitTypes",
       (SELECT COALESCE(jsonb_agg(jsonb_build_object('source', s.code, 'year', e.year, 'rank', e.rank_position, 'band', e.rank_band)
                ORDER BY s.code, e.year DESC), '[]')
          FROM ranking_entry e JOIN ranking_source s ON s.id = e.source_id WHERE e.university_id = u.id) AS rankings
     FROM university u WHERE u.id = ANY($1::int[])`,
    [ids],
  );
  // keep the order requested by the client
  return ids.map((id) => rows.find((r) => r.id === id)).filter(Boolean);
}
