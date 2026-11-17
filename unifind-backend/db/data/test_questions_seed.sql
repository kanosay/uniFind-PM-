-- Seed data for the Career & Major Guidance Test
-- 15 questions assessing analytical vs creative, tech vs humanities, teamwork vs solo, business interest, etc.
TRUNCATE TABLE test_question RESTART IDENTITY CASCADE;

INSERT INTO test_question (position, text, options) VALUES
-- Question 1: Problem-solving style
(1, 'When facing a complex problem, you prefer to:', '[
  {"id": "a", "label": "Break it down logically and analyze each part systematically", "weights": {"analytical": 3, "technical": 2, "research": 2}},
  {"id": "b", "label": "Brainstorm creative approaches and think outside the box", "weights": {"creative": 3, "design": 2, "innovation": 2}},
  {"id": "c", "label": "Consult with others and gather different perspectives", "weights": {"collaborative": 3, "communication": 2, "management": 2}},
  {"id": "d", "label": "Look for practical, proven solutions that work quickly", "weights": {"practical": 3, "engineering": 2, "business": 1}}
]'),

-- Question 2: Work environment preference
(2, 'Your ideal work environment is:', '[
  {"id": "a", "label": "A quiet lab or office where you can focus deeply on research", "weights": {"research": 3, "analytical": 2, "technical": 2}},
  {"id": "b", "label": "A dynamic studio or workshop with creative energy", "weights": {"creative": 3, "design": 2, "arts": 2}},
  {"id": "c", "label": "A collaborative office with team projects and meetings", "weights": {"collaborative": 3, "management": 2, "communication": 2}},
  {"id": "d", "label": "A fast-paced setting with clients, negotiations, and deals", "weights": {"business": 3, "communication": 2, "law": 1}}
]'),

-- Question 3: Subject interest
(3, 'Which subject area fascinates you most?', '[
  {"id": "a", "label": "Mathematics, physics, computer science, or engineering", "weights": {"technical": 3, "analytical": 2, "engineering": 2}},
  {"id": "b", "label": "Literature, philosophy, history, languages, or arts", "weights": {"humanities": 3, "creative": 2, "communication": 2}},
  {"id": "c", "label": "Biology, chemistry, medicine, or environmental science", "weights": {"medical": 3, "research": 2, "science": 2}},
  {"id": "d", "label": "Economics, finance, marketing, or business strategy", "weights": {"business": 3, "analytical": 1, "management": 2}}
]'),

-- Question 4: Team vs solo work
(4, 'How do you prefer to work on projects?', '[
  {"id": "a", "label": "Independently, with full ownership and deep focus", "weights": {"research": 2, "technical": 2, "analytical": 2, "creative": 1}},
  {"id": "b", "label": "In a small team where everyone contributes expertise", "weights": {"collaborative": 3, "engineering": 2, "management": 1}},
  {"id": "c", "label": "Leading a team and coordinating different people", "weights": {"management": 3, "leadership": 2, "communication": 2}},
  {"id": "d", "label": "Working directly with clients, patients, or audiences", "weights": {"communication": 3, "medical": 1, "law": 1, "arts": 1}}
]'),

-- Question 5: Decision making
(5, 'When making important decisions, you rely most on:', '[
  {"id": "a", "label": "Data, evidence, and logical analysis", "weights": {"analytical": 3, "research": 2, "technical": 2}},
  {"id": "b", "label": "Intuition, creativity, and aesthetic judgment", "weights": {"creative": 3, "design": 2, "arts": 2}},
  {"id": "c", "label": "Consensus and input from stakeholders", "weights": {"collaborative": 3, "management": 2, "communication": 2}},
  {"id": "d", "label": "Cost-benefit analysis and strategic outcomes", "weights": {"business": 3, "management": 2, "law": 1}}
]'),

-- Question 6: Learning style
(6, 'You learn best by:', '[
  {"id": "a", "label": "Reading technical documentation and solving practice problems", "weights": {"technical": 3, "analytical": 2, "engineering": 1}},
  {"id": "b", "label": "Hands-on experimentation and creating things", "weights": {"creative": 2, "engineering": 2, "design": 2, "practical": 1}},
  {"id": "c", "label": "Discussing ideas with others and debating perspectives", "weights": {"communication": 3, "law": 2, "humanities": 1, "management": 1}},
  {"id": "d", "label": "Case studies, real-world examples, and internships", "weights": {"business": 2, "medical": 2, "practical": 2, "management": 1}}
]'),

-- Question 7: Impact motivation
(7, 'What motivates you most in a career?', '[
  {"id": "a", "label": "Discovering new knowledge and advancing science", "weights": {"research": 3, "science": 2, "analytical": 1}},
  {"id": "b", "label": "Creating beautiful, meaningful, or innovative work", "weights": {"creative": 3, "design": 2, "arts": 2}},
  {"id": "c", "label": "Helping people directly and improving lives", "weights": {"medical": 3, "social": 2, "communication": 1}},
  {"id": "d", "label": "Building successful ventures and driving growth", "weights": {"business": 3, "management": 2, "entrepreneurship": 2}}
]'),

-- Question 8: Structure vs flexibility
(8, 'You prefer work that is:', '[
  {"id": "a", "label": "Highly structured with clear procedures and standards", "weights": {"engineering": 2, "technical": 2, "law": 2, "medical": 1}},
  {"id": "b", "label": "Flexible and open-ended, allowing creative freedom", "weights": {"creative": 3, "design": 2, "arts": 2, "research": 1}},
  {"id": "c", "label": "Organized but adaptive, with team coordination", "weights": {"management": 3, "collaborative": 2, "communication": 1}},
  {"id": "d", "label": "Fast-changing with new challenges daily", "weights": {"business": 2, "entrepreneurship": 2, "communication": 1, "journalism": 1}}
]'),

-- Question 9: Communication style
(9, 'Your communication strength is:', '[
  {"id": "a", "label": "Writing precise technical reports and documentation", "weights": {"technical": 3, "analytical": 2, "research": 1}},
  {"id": "b", "label": "Visual storytelling, design, and creative expression", "weights": {"creative": 3, "design": 2, "arts": 2, "media": 1}},
  {"id": "c", "label": "Persuasive speaking, negotiation, and public presentation", "weights": {"communication": 3, "law": 2, "business": 2, "management": 1}},
  {"id": "d", "label": "Empathetic listening and explaining complex ideas simply", "weights": {"medical": 2, "teaching": 2, "social": 2, "collaborative": 1}}
]'),

-- Question 10: Ethics and values
(10, 'In your career, you value most:', '[
  {"id": "a", "label": "Accuracy, rigor, and intellectual honesty", "weights": {"research": 3, "analytical": 2, "science": 2, "engineering": 1}},
  {"id": "b", "label": "Originality, authenticity, and artistic integrity", "weights": {"creative": 3, "arts": 2, "design": 2}},
  {"id": "c", "label": "Justice, fairness, and advocacy for others", "weights": {"law": 3, "social": 2, "humanities": 1}},
  {"id": "d", "label": "Efficiency, results, and sustainable value creation", "weights": {"business": 3, "management": 2, "entrepreneurship": 1}}
]'),

-- Question 11: Technology affinity
(11, 'Your relationship with technology:', '[
  {"id": "a", "label": "I love coding, building systems, and working with data", "weights": {"technical": 3, "engineering": 2, "analytical": 2, "computer_science": 2}},
  {"id": "b", "label": "I use tech as a tool for creative expression", "weights": {"design": 2, "creative": 2, "media": 2, "arts": 1}},
  {"id": "c", "label": "I prefer human-centered tech that solves real problems", "weights": {"medical": 1, "social": 2, "engineering": 1, "management": 1}},
  {"id": "d", "label": "I focus on tech strategy, products, and business applications", "weights": {"business": 2, "management": 2, "entrepreneurship": 2, "computer_science": 1}}
]'),

-- Question 12: International orientation
(12, 'Do you want an international career?', '[
  {"id": "a", "label": "Yes, research and science are globally collaborative", "weights": {"research": 2, "science": 2, "international": 2}},
  {"id": "b", "label": "Yes, arts/design/media transcend borders", "weights": {"creative": 2, "arts": 2, "design": 1, "media": 1}},
  {"id": "c", "label": "Yes, I want to work in diplomacy, NGOs, or global business", "weights": {"international": 3, "law": 1, "business": 2, "political_science": 1}},
  {"id": "d", "label": "I prefer to work locally in my community", "weights": {"medical": 1, "teaching": 1, "social": 1, "law": 1}}
]'),

-- Question 13: Academic challenge
(13, 'How much theoretical depth do you want in your studies?', '[
  {"id": "a", "label": "Deep theoretical foundations, proofs, and advanced math", "weights": {"analytical": 3, "technical": 2, "research": 2, "mathematics": 2}},
  {"id": "b", "label": "Balanced theory and practice with creative application", "weights": {"design": 2, "engineering": 2, "creative": 1, "architecture": 1}},
  {"id": "c", "label": "Strong professional knowledge with clinical/practical focus", "weights": {"medical": 3, "law": 2, "teaching": 1}},
  {"id": "d", "label": "Applied frameworks, case studies, and strategic tools", "weights": {"business": 3, "management": 2, "economics": 1}}
]'),

-- Question 14: Societal contribution
(14, 'How do you want to contribute to society?', '[
  {"id": "a", "label": "Through scientific discovery and technological innovation", "weights": {"research": 3, "science": 2, "engineering": 2, "technical": 1}},
  {"id": "b", "label": "Through culture, arts, and enriching human experience", "weights": {"creative": 3, "arts": 2, "design": 2, "media": 1}},
  {"id": "c", "label": "Through healthcare, justice, education, or social services", "weights": {"medical": 2, "law": 2, "teaching": 2, "social": 2}},
  {"id": "d", "label": "Through economic development, jobs, and innovation", "weights": {"business": 3, "management": 2, "entrepreneurship": 2, "economics": 1}}
]'),

-- Question 15: Study commitment
(15, 'Regarding study intensity and duration:', '[
  {"id": "a", "label": "I am ready for 5-6+ years of rigorous study (medicine, PhD track)", "weights": {"medical": 3, "research": 2, "law": 1}},
  {"id": "b", "label": "I want a 3-5 year program with strong portfolio outcomes", "weights": {"creative": 2, "design": 2, "architecture": 2, "engineering": 1}},
  {"id": "c", "label": "I prefer 3-4 years with practical skills and internships", "weights": {"business": 2, "technical": 1, "management": 1, "communication": 1}},
  {"id": "d", "label": "I want flexibility to combine study with work experience", "weights": {"entrepreneurship": 2, "practical": 2, "management": 1}}
]');


