import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";

const API_BASE = "http://localhost:3000/api";

export default function CareerTest() {
  const navigate = useNavigate();
  const [questions, setQuestions] = useState([]);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    fetch(`${API_BASE}/test/questions`)
      .then((r) => {
        if (!r.ok) throw new Error("Failed to load questions");
        return r.json();
      })
      .then((data) => {
        setQuestions(data.questions);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  const currentQuestion = questions[currentIndex];
  const progress = questions.length > 0 ? ((currentIndex + 1) / questions.length) * 100 : 0;

  const handleOptionSelect = (optionId) => {
    setAnswers((prev) => ({
      ...prev,
      [currentQuestion.id]: optionId,
    }));
  };

  const handleNext = () => {
    if (!answers[currentQuestion.id]) {
      setError("Please select an answer before continuing");
      return;
    }
    setError("");
    if (currentIndex < questions.length - 1) {
      setCurrentIndex((i) => i + 1);
    }
  };

  const handleBack = () => {
    setError("");
    if (currentIndex > 0) {
      setCurrentIndex((i) => i - 1);
    }
  };

  const handleSubmit = async () => {
    if (Object.keys(answers).length < questions.length) {
      setError("Please answer all questions");
      return;
    }

    setSubmitting(true);
    setError("");

    const answerArray = Object.entries(answers).map(([questionId, optionId]) => ({
      questionId: Number(questionId),
      optionId,
    }));

    try {
      const res = await fetch(`${API_BASE}/test/submit`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ answers: answerArray }),
      });

      if (!res.ok) {
        const err = await res.json();
        throw new Error(err.error?.message || "Failed to submit test");
      }

      const data = await res.json();
      // Store results in sessionStorage for the results page
      sessionStorage.setItem("testResults", JSON.stringify(data.recommendedMajors));
      navigate("/test/results");
    } catch (err) {
      setError(err.message);
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <main className="wrap" style={{ textAlign: "center", paddingTop: 100 }}>
        <div className="btn" style={{ width: "auto", pointerEvents: "none" }}>Loading test…</div>
      </main>
    );
  }

  if (error && !currentQuestion) {
    return (
      <main className="wrap">
        <div className="card accent empty">
          <h2>Unable to load test</h2>
          <p className="mut">{error}</p>
          <Link className="btn" to="/" style={{ marginTop: 16 }}>
            Back to Universities
          </Link>
        </div>
      </main>
    );
  }

  return (
    <>
      <section className="hero">
        <h1>Career & Major Guidance Test</h1>
        <p className="mut lead">
          Answer 15 questions to discover which Prague university majors match your profile.
        </p>
        <div
          className="row"
          style={{ maxWidth: 760, marginTop: 16, height: 8, background: "#D5DDF2", borderRadius: 4, overflow: "hidden" }}
          role="progressbar"
          aria-valuenow={Math.round(progress)}
          aria-valuemin={0}
          aria-valuemax={100}
        >
          <div
            style={{
              width: `${progress}%`,
              height: "100%",
              background: "#2F6FED",
              transition: "width 0.3s ease",
            }}
          />
        </div>
        <p className="mut" style={{ marginTop: 8, fontSize: 14 }}>
          Question {currentIndex + 1} of {questions.length}
        </p>
      </section>

      <main className="wrap">
        {error && (
          <div className="card" style={{ background: "#FDE8E4", borderColor: "#E8A098", marginBottom: 20 }}>
            <p className="mut" style={{ color: "#8B2E1F", margin: 0 }}>{error}</p>
          </div>
        )}

        <div className="card accent" style={{ maxWidth: 760, margin: "0 auto" }}>
          <h2 style={{ marginBottom: 8 }}>{currentQuestion.text}</h2>
          <p className="mut" style={{ marginBottom: 20 }}>
            Select the option that best describes you.
          </p>

          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            {currentQuestion.options.map((option) => (
              <button
                key={option.id}
                type="button"
                className={`btn ${answers[currentQuestion.id] === option.id ? "accent" : "btn2"}`}
                style={{
                  textAlign: "left",
                  padding: "16px 20px",
                  height: "auto",
                  border: answers[currentQuestion.id] === option.id ? "2px solid #2F6FED" : "1px solid #C9D1E6",
                  background: answers[currentQuestion.id] === option.id ? "#E8EEFC" : "#fff",
                }}
                onClick={() => handleOptionSelect(option.id)}
              >
                {option.label}
              </button>
            ))}
          </div>

          <div className="row between" style={{ marginTop: 28 }}>
            <button
              className="btn btn2"
              type="button"
              onClick={handleBack}
              disabled={currentIndex === 0}
            >
              ← Back
            </button>
            <button
              className="btn"
              type="button"
              onClick={currentIndex === questions.length - 1 ? handleSubmit : handleNext}
              disabled={submitting}
            >
              {currentIndex === questions.length - 1
                ? submitting
                  ? "Submitting…"
                  : "See My Results →"
                : "Next →"}
            </button>
          </div>
        </div>
      </main>
    </>
  );
}