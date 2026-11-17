import { createContext, useContext, useState } from "react";

const CompareContext = createContext(null);
export const useCompare = () => useContext(CompareContext);

// Three slots; "" means empty.
export function CompareProvider({ children }) {
  const [slots, setSlots] = useState(["", "", ""]);
  const setSlot = (i, id) => setSlots((s) => s.map((v, k) => (k === i ? id : v)));
  const add = (id) =>
    setSlots((s) => {
      if (s.includes(String(id))) return s;
      const i = s.indexOf("");
      return i === -1 ? s : s.map((v, k) => (k === i ? String(id) : v));
    });
  return <CompareContext.Provider value={{ slots, setSlot, add }}>{children}</CompareContext.Provider>;
}
