// All data access lives here. Data comes from src/data/prague_universities_en.json
// (source: MŠMT register, as of 2026-11-11). When the backend is ready, replace the
// bodies with fetch("/api/...") calls – the pages do not need to change.
import raw from "./data/prague_universities_en.json";

export const meta = raw.meta;

const universities = raw.universities.map((u, i) => ({
  ...u,
  id: i + 1,
  // Faculty or generic "unit" (department, studio, school...) – depends on the university
  unitLabel: u.has_faculties ? "faculties" : "units",
}));

// Reviews are kept in memory until the backend exists (lost on page reload).
// TODO(backend): GET/POST /api/universities/:id/reviews
const reviewStore = new Map();
export const getReviews = (id) => reviewStore.get(Number(id)) ?? [];
export const postReview = (id, review) => {
  reviewStore.set(Number(id), [review, ...getReviews(id)]);
  return Promise.resolve(review);
};

export const getUniversities = () => Promise.resolve(universities);
export const getUniversity = (id) =>
  Promise.resolve(universities.find((u) => u.id === Number(id)) ?? null);

export const averageRating = (reviews) =>
  reviews.length ? reviews.reduce((s, r) => s + r.rating, 0) / reviews.length : null;
