import { NavLink, Link } from "react-router-dom";

export default function Header() {
  return (
    <header className="hd">
      <Link className="logo" to="/">Uni<span>Find</span></Link>
      <NavLink to="/" end>Universities</NavLink>
      <NavLink to="/test">Major Test</NavLink>
      <NavLink to="/compare">Compare</NavLink>
      {/* TODO: Major finder and Blog pages */}
      <button className="btn" type="button" onClick={() => alert("TODO: Google login (backend)")}>
        Log in with Google
      </button>
    </header>
  );
}
