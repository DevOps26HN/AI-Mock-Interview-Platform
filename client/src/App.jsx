import { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [questions, setQuestions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [hints, setHints] = useState({});
  const [loadingHints, setLoadingHints] = useState({});

  useEffect(() => {
    const fetchQuestions = async () => {
      try {
        const apiUrl = import.meta.env.VITE_API_URL;
        // If VITE_API_URL is empty or points to localhost:8080 in production,
        // fall back to a relative path to query via the same host/ingress.
        const actualApiUrl = (apiUrl && apiUrl !== 'http://localhost:8080')
          ? apiUrl
          : (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1')
            ? 'http://localhost:8080'
            : '';

        const response = await fetch(`${actualApiUrl}/api/interview/questions`);
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        setQuestions(data);
      } catch (e) {
        console.error("Could not fetch questions:", e);
        setError("Failed to load interview questions. Please ensure the backend server is running.");
      } finally {
        setLoading(false);
      }
    };

    fetchQuestions();
  }, []);

  const fetchHint = async (id) => {
    setLoadingHints(prev => ({ ...prev, [id]: true }));
    try {
      const apiUrl = import.meta.env.VITE_API_URL;
      const actualApiUrl = (apiUrl && apiUrl !== 'http://localhost:8080')
        ? apiUrl
        : (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1')
          ? 'http://localhost:8080'
          : '';

      const response = await fetch(`${actualApiUrl}/api/interview/questions/${id}/hint`, {
        method: 'POST'
      });
      if (!response.ok) throw new Error("Failed to fetch hint");
      const data = await response.json();
      setHints(prev => ({ ...prev, [id]: data.hint }));
    } catch (e) {
      console.error("Hint error:", e);
      setHints(prev => ({ ...prev, [id]: "Could not generate hint at this time." }));
    } finally {
      setLoadingHints(prev => ({ ...prev, [id]: false }));
    }
  };

  const getDifficultyClass = (difficulty) => {
    if (!difficulty) return 'difficulty-medium';
    return `difficulty-${difficulty.toLowerCase()}`;
  };

  return (
    <div className="app-container">
      <header className="header">
        <h1 className="title">Mock Interview Platform</h1>
        <p className="subtitle">Practice with AI-curated questions tailored for your role and skill level. Elevate your interview game.</p>
      </header>

      <main>
        {loading && (
          <div className="loading-state">
            <div className="loader"></div>
            <p>Loading your questions...</p>
          </div>
        )}

        {error && (
          <div className="error-state">
            <p>{error}</p>
          </div>
        )}

        {!loading && !error && questions.length === 0 && (
          <div className="loading-state">
            <p>No questions found.</p>
          </div>
        )}

        {!loading && !error && questions.length > 0 && (
          <div className="questions-grid">
            {questions.map((q, index) => (
              <div
                className="question-card"
                key={q.id}
                style={{ animationDelay: `${index * 0.1}s` }}
              >
                <div className="card-header">
                  <span className="role-badge">{q.role}</span>
                  <span className={`difficulty-badge ${getDifficultyClass(q.difficulty)}`}>
                    {q.difficulty}
                  </span>
                </div>

                <h3 className="question-text">{q.question}</h3>

                {hints[q.id] && (
                  <div className="hint-container">
                    <strong>AI Hint:</strong>
                    <p className="hint-text">{hints[q.id]}</p>
                  </div>
                )}

                <div className="card-footer">
                  <div className="category-tag">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
                    </svg>
                    {q.category}
                  </div>
                  <button 
                    className="hint-btn" 
                    onClick={() => fetchHint(q.id)}
                    disabled={loadingHints[q.id]}
                  >
                    {loadingHints[q.id] ? "Thinking..." : (hints[q.id] ? "Refresh Hint" : "Get AI Hint")}
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
