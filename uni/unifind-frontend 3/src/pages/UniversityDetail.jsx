import { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { getUniversity, getReviews, postReview, averageRating } from "../api.js";
import { useCompare } from "../CompareContext.jsx";

export default function UniversityDetail() {
  const { id } = useParams();
  const { add } = useCompare();
  const [uni, setUni] = useState(undefined); // undefined = loading, null = not found
  const [reviews, setReviews] = useState([]);
  const [form, setForm] = useState({ rating: 5, text: "" });
  const [msg, setMsg] = useState("");

  useEffect(() => {
    getUniversity(id).then((u) => { setUni(u); setReviews(u ? getReviews(u.id) : []); });
  }, [id]);

  // Group faculties/units by their type (Faculty, Department, Studio...)
  const groups = useMemo(() => {
    const g = {};
    (uni?.faculties ?? []).forEach((x) => (g[x.unit_type] ??= []).push(x));
    return Object.entries(g);
  }, [uni]);

  if (uni === undefined) return <main className="wrap"><p>Loading…</p></main>;
  if (uni === null) return <main className="wrap"><h1>University not found</h1><Link to="/">Back to list</Link></main>;

  const avg = averageRating(reviews);

  const submit = async (e) => {
    e.preventDefault();
    if (!form.text.trim()) { setMsg("Write a short review first."); return; }
    await postReview(uni.id, { author: "You", rating: Number(form.rating), text: form.text.trim() });
    setReviews(getReviews(uni.id));
    setForm({ rating: 5, text: "" });
    setMsg("Review published.");
  };

  return (
    <>
      <section className="hero">
        <p className="mut"><Link to="/">← Universities</Link></p>
        <span className="tag t0">{uni.type} · {uni.category}</span>
        <h1 style={{ marginTop: 14 }}>{uni.name} ({uni.abbreviation})</h1>
        <p className="mut lead">
          {uni.address} ·{" "}
          <a href={uni.website} target="_blank" rel="noopener noreferrer">{uni.website.replace(/^https?:\/\//, "")}</a>
        </p>
      </section>

      <main className="wrap two">
        <div className="grow">
          <div className="grid3" style={{ marginBottom: 20 }}>
            <div className="stat t0"><b>{uni.unit_count}</b>{uni.unitLabel}</div>
            <div className="stat t1"><b>{uni.type}</b>type</div>
            <div className="stat t2"><b>{avg ? avg.toFixed(1) : "–"}</b>student rating</div>
          </div>

          <section className="card accent">
            <h2>{uni.has_faculties ? "Faculties" : "Departments and programmes"}</h2>
            {groups.map(([type, items]) => (
              <div key={type} style={{ marginBottom: 14 }}>
                <p className="mut" style={{ margin: "8px 0" }}><b>{type} ({items.length})</b></p>
                <ul className="units">
                  {items.map((x) => (
                    <li key={x.name}>{x.name}{x.abbreviation ? ` (${x.abbreviation})` : ""}{x.city !== "Prague" ? ` – ${x.city}` : ""}</li>
                  ))}
                </ul>
              </div>
            ))}
            {uni.note && <p className="mut">{uni.note}</p>}
          </section>

          <section className="card accent" style={{ marginTop: 20 }}>
            <h2>Student reviews</h2>
            {reviews.length === 0 && <p className="mut">No reviews yet. Be the first to write one.</p>}
            {reviews.map((r, i) => (
              <div className="rk" key={i}>
                <span><b>{r.author}</b> <span className="star">★ {r.rating}/5</span><br />{r.text}</span>
              </div>
            ))}
          </section>
        </div>

        <aside className="side">
          <form className="card accent" onSubmit={submit}>
            <h2>Rate this university</h2>
            <label className="lbl" htmlFor="rating">Rating</label>
            <select className="inp" id="rating" value={form.rating} onChange={(e) => setForm({ ...form, rating: e.target.value })}>
              {[5, 4, 3, 2, 1].map((n) => <option key={n}>{n}</option>)}
            </select>
            <label className="lbl" htmlFor="text">Your review</label>
            <textarea className="inp area" id="text" value={form.text} onChange={(e) => setForm({ ...form, text: e.target.value })} />
            <button className="btn full" type="submit" style={{ marginTop: 16 }}>Publish review</button>
            {msg && <p className="mut" role="status">{msg}</p>}
          </form>
          <Link className="btn btn3 full center" to="/compare" onClick={() => add(uni.id)} style={{ marginTop: 20 }}>
            Add to compare
          </Link>
        </aside>
      </main>
    </>
  );
}
