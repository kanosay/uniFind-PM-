import { useEffect, useState } from "react";
import { Link } from "react-router-dom";

export default function TestResults() {
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const stored = sessionStorage.getItem("testResults");
    if (stored) {
      try {
        setResults(JSON.parse(stored));
      } catch {
        setResults([]);
      }
    }
    setLoading(false);
  }, []);

  if (loading) {
    return (
      <main className="wrap" style={{ textAlign: "center", paddingTop: 100 }}>
        <div className="btn" style={{ width: "auto", pointerEvents: "none" }}>Loading results…</div>
      </main>
    );
  }

  if (!results.length) {
    return (
      <main className="wrap">
        <div className="card accent empty">
          <h2>No results found</h2>
          <p className="mut">It looks like you haven't taken the test yet, or your session expired.</p>
          <Link className="btn" to="/test" style={{ marginTop: 16 }}>
            Take the Test
          </Link>
        </div>
      </main>
    );
  }

  return (
    <>
      <section className="hero">
        <h1>Your Top 3 Recommended Majors</h1>
        <p className="mut lead">
          Based on your answers, these programs at Prague universities best match your profile.
        </p>
      </section>

      <main className="wrap">
        <div className="grid3">
          {results.map((major, index) => (
            <article key={major.majorId} className="card accent" style={{ display: "flex", flexDirection: "column" }}>
              <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
                <span className="tag t0">#{index + 1} Match</span>
                <span className="tag t1" style={{ fontSize: 16, padding: "6px 14px" }}>
                  {major.matchPercentage}% Match
                </span>
              </div>

              <h2 style={{ margin: "8px 0 4px", fontSize: 20 }}>{major.majorName}</h2>
              <p className="mut" style={{ marginBottom: 12 }}>
                <Link to={`/universities/${major.universityId}`} style={{ color: "#2F6FED", fontWeight: 600 }}>
                  {major.universityName} {major.universityAbbreviation && `(${major.universityAbbreviation})`}
                </Link>
              </p>

              <p className="mut" style={{ marginBottom: 16, lineHeight: 1.5, flex: 1 }}>{major.explanation}</p>

              <div style={{ marginTop: "auto", paddingTop: 16, borderTop: "1px solid #DDE2F0" }}>
                <Link
                  className="btn"
                  to={`/universities/${major.universityId}`}
                  style={{ width: "100%", textAlign: "center" }}
                >
                  View University Details →
                </Link>
              </div>
            </article>
          ))}
        </div>

        <div style={{ textAlign: "center", marginTop: 32 }}>
          <Link className="btn btn2" to="/test" style={{ minWidth: 200 }}>
            Retake Test
          </Link>
        </div>

        <section className="card accent" style={{ marginTop: 32 }}>
          <h2>How this works</h2>
          <p className="mut" style={{ marginBottom: 12 }}>
            The test evaluates your preferences across 15 dimensions including problem-solving style, work environment,
            subject interests, teamwork preferences, and career motivations. Your answers are weighted against
            academic program tags (like <code>analytical</code>, <code>creative</code>, <code>medical</code>,
            <code>business</code>, <code>engineering</code>, etc.) to calculate match percentages.
          </p>
          <p className="mut">
            The universities and majors shown are sourced from the official MŠMT register of Prague higher education
            institutions. Click any university to explore its faculties, programs, and student reviews.
          </p>
        </section>
      </main>
    </>
  );
}