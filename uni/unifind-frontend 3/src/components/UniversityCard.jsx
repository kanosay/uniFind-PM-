import { Link } from "react-router-dom";
import { averageRating, getReviews } from "../api.js";

export default function UniversityCard({ uni }) {
  const reviews = getReviews(uni.id);
  const avg = averageRating(reviews);
  return (
    <article className="card accent">
      <span className={`tag ${uni.type === "Public" ? "t0" : uni.type === "Private" ? "t1" : "t2"}`}>
        {uni.type}
      </span>
      <h2 style={{ marginTop: 14 }}>{uni.name}</h2>
      <p className="mut">{uni.category} · {uni.unit_count} {uni.unitLabel}</p>
      <div className="row between">
        <span className="star">
          {avg ? `★ ${avg.toFixed(1)}` : "No ratings yet"}{" "}
          <span className="mut">({reviews.length} reviews)</span>
        </span>
        <Link className="go" to={`/universities/${uni.id}`}>Details →</Link>
      </div>
    </article>
  );
}
