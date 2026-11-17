import { useEffect, useMemo, useState } from "react";
import { getUniversities, getReviews, averageRating } from "../api.js";
import UniversityCard from "../components/UniversityCard.jsx";

const initial = { q: "", type: "All", category: "All", sort: "name" };

export default function UniversityList() {
  const [all, setAll] = useState([]);
  const [f, setF] = useState(initial);
  useEffect(() => { getUniversities().then(setAll); }, []);
  const set = (key) => (e) => setF({ ...f, [key]: e.target.value });

  const types = useMemo(() => [...new Set(all.map((u) => u.type))], [all]);
  const categories = useMemo(() => [...new Set(all.map((u) => u.category))], [all]);

  const shown = useMemo(() => {
    const q = f.q.trim().toLowerCase();
    const matches = (u) =>
      u.name.toLowerCase().includes(q) ||
      u.abbreviation.toLowerCase().includes(q) ||
      u.faculties.some((x) => x.name.toLowerCase().includes(q));
    const list = all.filter(
      (u) => (!q || matches(u)) &&
        (f.type === "All" || u.type === f.type) &&
        (f.category === "All" || u.category === f.category)
    );
    const sorters = {
      name: (a, b) => a.name.localeCompare(b.name),
      units: (a, b) => b.unit_count - a.unit_count,
      rating: (a, b) => (averageRating(getReviews(b.id)) ?? 0) - (averageRating(getReviews(a.id)) ?? 0),
    };
    return [...list].sort(sorters[f.sort]);
  }, [all, f]);

  return (
    <>
      <section className="hero">
        <h1>Find your university in Prague</h1>
        <p className="mut lead">{all.length} universities. Search, filter and compare to find your match.</p>
        <div className="row end" style={{ maxWidth: 760 }}>
          <div className="grow">
            <label className="lbl" htmlFor="q">Search</label>
            <input className="inp" id="q" placeholder="University, abbreviation or faculty" value={f.q} onChange={set("q")} />
          </div>
          <div style={{ width: 220 }}>
            <label className="lbl" htmlFor="sort">Sort by</label>
            <select className="inp" id="sort" value={f.sort} onChange={set("sort")}>
              <option value="name">Name (A–Z)</option>
              <option value="units">Number of faculties / units</option>
              <option value="rating">Student rating</option>
            </select>
          </div>
        </div>
      </section>

      <main className="wrap layout">
        <aside className="card accent filters">
          <h2>Filters</h2>
          <label className="lbl" htmlFor="type">Type</label>
          <select className="inp" id="type" value={f.type} onChange={set("type")}>
            <option>All</option>
            {types.map((x) => <option key={x}>{x}</option>)}
          </select>
          <label className="lbl" htmlFor="cat">Category</label>
          <select className="inp" id="cat" value={f.category} onChange={set("category")}>
            <option>All</option>
            {categories.map((x) => <option key={x}>{x}</option>)}
          </select>
          <button className="btn btn2 full" type="button" onClick={() => setF(initial)}>Reset filters</button>
        </aside>

        {shown.length ? (
          <div className="grid3 grow">{shown.map((u) => <UniversityCard key={u.id} uni={u} />)}</div>
        ) : (
          <div className="card grow empty">
            <h2>No universities match your filters</h2>
            <p className="mut">Try a different search or reset the filters.</p>
            <button className="btn" type="button" onClick={() => setF(initial)}>Reset filters</button>
          </div>
        )}
      </main>
    </>
  );
}
