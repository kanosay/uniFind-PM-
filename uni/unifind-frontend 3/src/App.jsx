import { Routes, Route } from "react-router-dom";
import Header from "./components/Header.jsx";
import UniversityList from "./pages/UniversityList.jsx";
import UniversityDetail from "./pages/UniversityDetail.jsx";
import Compare from "./pages/Compare.jsx";
import CareerTest from "./pages/CareerTest.jsx";
import TestResults from "./pages/TestResults.jsx";

export default function App() {
  return (
    <>
      <Header />
      <Routes>
        <Route path="/" element={<UniversityList />} />
        <Route path="/universities/:id" element={<UniversityDetail />} />
        <Route path="/compare" element={<Compare />} />
        <Route path="/test" element={<CareerTest />} />
        <Route path="/test/results" element={<TestResults />} />
        <Route path="*" element={<main className="wrap"><h1>Page not found</h1></main>} />
      </Routes>
    </>
  );
}
