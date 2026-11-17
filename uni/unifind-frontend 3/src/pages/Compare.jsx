import { useEffect, useState } from "react";
import { getUniversities, getReviews, averageRating } from "../api.js";
import { useCompare } from "../CompareContext.jsx";

export default function Compare() {
  const { slots, setSlot } = useCompare();
  const [all, setAll] = useState([]);
  useEffect(() => { getUniversities().then(setAll); }, []);
  const find = (id) => all.find((u) => String(u.id) === id);

  const rows = [
    ["Type", (u) => u.type],
    ["Category", (u) => u.category],
    ["Faculties / units", (u) => `${u.unit_count} ${u.unitLabel}`],
    ["Address", (u) => u.address],
    ["Website", (u) => u.website.replace(/^https?:\/\//, "")],
    ["Student rating", (u) => { const a = averageRating(getReviews(u.id)); return a ? `★ ${a.toFixed(1)}` : "No ratings yet"; }],
  ];

  return (
    <>
      <section className="hero">
        <h1>Compare universities</h1>
        <p className="mut lead">Pick up to three universities side by side.</p>
      </section>
      <main className="wrap">
        <div className="grid3">
          {slots.map((id, i) => {
            const u = find(id);
            return (
              <section className="card accent" key={i}>
                <label className="lbl first" htmlFor={`c${i}`}>University {i + 1}</label>
                <select className="inp" id={`c${i}`} value={id} onChange={(e) => setSlot(i, e.target.value)}>
                  <option value="">Choose a university</option>
                  {all.map((x) => <option key={x.id} value={x.id}>{x.name}</option>)}
                </select>
                <div style={{ marginTop: 14 }}>
                  {u ? rows.map(([label, get]) => (
                    <div className="rk" key={label}><span>{label}</span><b style={{ textAlign: "right" }}>{get(u)}</b></div>
                  )) : <p className="mut">Select a university to see its details.</p>}
                </div>
              </section>
            );
          })}
        </div>
      </main>
    </>
  );
}
