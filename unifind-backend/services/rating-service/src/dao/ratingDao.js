import { query } from '@unifind/shared/db';

export async function universityExists(id) {
  return (await query('SELECT 1 FROM university WHERE id = $1', [id])).rowCount > 0;
}

export async function getRating(universityId) {
  const [rankings, agg] = await Promise.all([
    query(
      `SELECT s.code AS source, s.name AS "sourceName", e.year, e.rank_position AS rank, e.rank_band AS band
         FROM ranking_entry e JOIN ranking_source s ON s.id = e.source_id
        WHERE e.university_id = $1 ORDER BY s.code, e.year DESC`, [universityId]),
    query(
      `SELECT COUNT(*)::int AS "reviewCount", ROUND(AVG(rating), 2)::float AS "averageRating"
         FROM review WHERE university_id = $1`, [universityId]),
  ]);
  return {
    universityId,
    rankings: rankings.rows,
    rankedGlobally: rankings.rowCount > 0,   // UI: "Not ranked globally" when false
    averageRating: agg.rows[0].averageRating, // null when there are no reviews ("No reviews yet")
    reviewCount: agg.rows[0].reviewCount,
  };
}

export async function listReviews(universityId, { limit, offset }) {
  const { rows } = await query(
    `SELECT r.id, r.rating, r.comment, r.created_at AS "createdAt", u.display_name AS "author"
       FROM review r JOIN app_user u ON u.id = r.user_id
      WHERE r.university_id = $1 ORDER BY r.created_at DESC LIMIT $2 OFFSET $3`,
    [universityId, limit, offset]);
  return rows;
}

export async function createReview(client, { userId, universityId, rating, comment }) {
  const { rows } = await client.query(
    `INSERT INTO review (user_id, university_id, rating, comment) VALUES ($1,$2,$3,$4)
     RETURNING id, university_id AS "universityId", rating, comment, created_at AS "createdAt"`,
    [userId, universityId, rating, comment]);
  return rows[0];
}
