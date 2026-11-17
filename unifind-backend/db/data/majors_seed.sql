-- Seed majors for Prague universities with tags for career test matching
-- Tags: analytical, technical, research, creative, design, innovation, collaborative, communication, management,
-- practical, engineering, business, humanities, arts, medical, science, leadership, law, journalism,
-- entrepreneurship, teaching, social, international, architecture, computer_science, mathematics, economics, media

-- Charles University (id=1)
INSERT INTO major (university_id, faculty_id, name, degree_level, language, tuition_fee_eur_year, tags) VALUES
-- Faculty of Law (PF) - id from faculty table
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='PF'), 'Law', 'Master', 'Czech', 0, ARRAY['law', 'analytical', 'communication', 'research']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='PF'), 'Law and Economics', 'Master', 'Czech', 0, ARRAY['law', 'business', 'analytical', 'economics']),

-- First Faculty of Medicine (1. LF)
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='1. LF'), 'General Medicine', 'Master', 'Czech', 0, ARRAY['medical', 'science', 'research', 'analytical']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='1. LF'), 'Dentistry', 'Master', 'Czech', 0, ARRAY['medical', 'science', 'practical', 'engineering']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='1. LF'), 'Paramedics', 'Bachelor', 'Czech', 0, ARRAY['medical', 'practical', 'collaborative', 'communication']),

-- Faculty of Arts (FF)
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FF'), 'History', 'Bachelor', 'Czech', 0, ARRAY['humanities', 'research', 'analytical', 'communication']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FF'), 'Philosophy', 'Bachelor', 'Czech', 0, ARRAY['humanities', 'analytical', 'creative', 'research']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FF'), 'English Language and Literature', 'Bachelor', 'Czech', 0, ARRAY['humanities', 'communication', 'international', 'teaching']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FF'), 'Journalism and Media Studies', 'Bachelor', 'Czech', 0, ARRAY['journalism', 'communication', 'creative', 'media']),

-- Faculty of Science (PřF)
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='PřF'), 'Biology', 'Bachelor', 'Czech', 0, ARRAY['science', 'research', 'analytical', 'medical']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='PřF'), 'Chemistry', 'Bachelor', 'Czech', 0, ARRAY['science', 'research', 'analytical', 'engineering']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='PřF'), 'Physics', 'Bachelor', 'Czech', 0, ARRAY['science', 'research', 'analytical', 'technical', 'mathematics']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='PřF'), 'Geology', 'Bachelor', 'Czech', 0, ARRAY['science', 'research', 'analytical', 'practical']),

-- Faculty of Mathematics and Physics (MFF)
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='MFF'), 'Computer Science', 'Bachelor', 'Czech', 0, ARRAY['technical', 'analytical', 'computer_science', 'engineering', 'mathematics']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='MFF'), 'Mathematics', 'Bachelor', 'Czech', 0, ARRAY['mathematics', 'analytical', 'research', 'technical']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='MFF'), 'Physics', 'Bachelor', 'Czech', 0, ARRAY['science', 'research', 'analytical', 'technical', 'mathematics']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='MFF'), 'Software Engineering', 'Bachelor', 'Czech', 0, ARRAY['technical', 'engineering', 'computer_science', 'collaborative', 'practical']),

-- Faculty of Education (PedF)
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='PedF'), 'Primary Education', 'Bachelor', 'Czech', 0, ARRAY['teaching', 'communication', 'collaborative', 'social']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='PedF'), 'Special Education', 'Bachelor', 'Czech', 0, ARRAY['teaching', 'social', 'medical', 'communication']),

-- Faculty of Social Sciences (FSV)
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FSV'), 'Political Science', 'Bachelor', 'Czech', 0, ARRAY['humanities', 'analytical', 'international', 'law', 'communication']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FSV'), 'Sociology', 'Bachelor', 'Czech', 0, ARRAY['humanities', 'research', 'analytical', 'social']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FSV'), 'Media Studies', 'Bachelor', 'Czech', 0, ARRAY['journalism', 'communication', 'creative', 'media', 'international']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FSV'), 'International Relations', 'Bachelor', 'English', 0, ARRAY['international', 'law', 'communication', 'analytical', 'business']),

-- Faculty of Humanities (FHS)
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FHS'), 'Humanities', 'Bachelor', 'Czech', 0, ARRAY['humanities', 'creative', 'analytical', 'communication', 'research']),
(1, (SELECT id FROM faculty WHERE university_id=1 AND abbreviation='FHS'), 'Liberal Arts and Humanities', 'Bachelor', 'English', 0, ARRAY['humanities', 'creative', 'international', 'communication', 'analytical']),

-- Czech Technical University in Prague (id=2)
-- Faculty of Civil Engineering (FSv)
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FSv'), 'Civil Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'analytical', 'practical', 'mathematics']),
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FSv'), 'Architecture and Civil Engineering', 'Bachelor', 'Czech', 0, ARRAY['architecture', 'engineering', 'creative', 'design', 'technical']),

-- Faculty of Mechanical Engineering (FS)
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FS'), 'Mechanical Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'analytical', 'practical', 'innovation']),
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FS'), 'Automotive Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'innovation', 'computer_science', 'business']),

-- Faculty of Electrical Engineering (FEL)
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FEL'), 'Electrical Engineering and Computer Science', 'Bachelor', 'Czech', 0, ARRAY['technical', 'computer_science', 'engineering', 'analytical', 'innovation']),
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FEL'), 'Cybernetics and Robotics', 'Bachelor', 'Czech', 0, ARRAY['technical', 'engineering', 'computer_science', 'innovation', 'research']),

-- Faculty of Nuclear Sciences and Physical Engineering (FJFI)
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FJFI'), 'Nuclear Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'science', 'research', 'analytical']),
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FJFI'), 'Physical Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'science', 'analytical', 'mathematics']),

-- Faculty of Architecture (FA)
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FA'), 'Architecture', 'Master', 'Czech', 0, ARRAY['architecture', 'design', 'creative', 'engineering', 'technical']),
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FA'), 'Urbanism', 'Master', 'Czech', 0, ARRAY['architecture', 'design', 'creative', 'management', 'social']),

-- Faculty of Transportation Sciences (FD)
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FD'), 'Transport Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'practical', 'management', 'innovation']),
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FD'), 'Intelligent Transport Systems', 'Bachelor', 'Czech', 0, ARRAY['technical', 'computer_science', 'engineering', 'innovation', 'business']),

-- Faculty of Information Technology (FIT)
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FIT'), 'Information Technology', 'Bachelor', 'Czech', 0, ARRAY['technical', 'computer_science', 'analytical', 'engineering', 'innovation']),
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FIT'), 'Computer Science', 'Bachelor', 'English', 0, ARRAY['technical', 'computer_science', 'analytical', 'research', 'international']),
(2, (SELECT id FROM faculty WHERE university_id=2 AND abbreviation='FIT'), 'Software Engineering', 'Bachelor', 'Czech', 0, ARRAY['technical', 'computer_science', 'engineering', 'collaborative', 'practical']),

-- Prague University of Economics and Business (id=3)
-- Faculty of Finance and Accounting (FFÚ)
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FFÚ'), 'Finance and Accounting', 'Bachelor', 'Czech', 0, ARRAY['business', 'analytical', 'economics', 'technical', 'management']),
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FFÚ'), 'Banking and Insurance', 'Bachelor', 'Czech', 0, ARRAY['business', 'analytical', 'economics', 'management', 'law']),

-- Faculty of International Relations (FMV)
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FMV'), 'International Business', 'Bachelor', 'English', 0, ARRAY['business', 'international', 'communication', 'management', 'economics']),
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FMV'), 'International Economic Relations', 'Bachelor', 'Czech', 0, ARRAY['business', 'international', 'economics', 'analytical', 'law']),

-- Faculty of Business Administration (FPH)
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FPH'), 'Business Administration', 'Bachelor', 'Czech', 0, ARRAY['business', 'management', 'entrepreneurship', 'communication', 'analytical']),
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FPH'), 'Marketing', 'Bachelor', 'Czech', 0, ARRAY['business', 'creative', 'communication', 'management', 'media']),

-- Faculty of Informatics and Statistics (FIS)
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FIS'), 'Informatics', 'Bachelor', 'Czech', 0, ARRAY['technical', 'computer_science', 'analytical', 'engineering', 'business']),
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FIS'), 'Data Science and Analytics', 'Bachelor', 'English', 0, ARRAY['technical', 'analytical', 'computer_science', 'business', 'research']),
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FIS'), 'Statistics', 'Bachelor', 'Czech', 0, ARRAY['analytical', 'mathematics', 'research', 'technical', 'business']),

-- Faculty of Economics (NF)
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='NF'), 'Economics', 'Bachelor', 'Czech', 0, ARRAY['economics', 'analytical', 'business', 'research', 'mathematics']),
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='NF'), 'Economic Policy', 'Bachelor', 'Czech', 0, ARRAY['economics', 'analytical', 'business', 'management', 'law']),

-- Faculty of Management (FM) - Jindřichův Hradec
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FM'), 'Management', 'Bachelor', 'Czech', 0, ARRAY['management', 'business', 'leadership', 'communication', 'entrepreneurship']),
(3, (SELECT id FROM faculty WHERE university_id=3 AND abbreviation='FM'), 'Tourism Management', 'Bachelor', 'Czech', 0, ARRAY['management', 'business', 'communication', 'international', 'social']),

-- Czech University of Life Sciences Prague (id=4)
-- Faculty of Economics and Management (PEF)
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='PEF'), 'Economics and Management', 'Bachelor', 'Czech', 0, ARRAY['business', 'management', 'economics', 'analytical', 'entrepreneurship']),
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='PEF'), 'Agribusiness', 'Bachelor', 'Czech', 0, ARRAY['business', 'management', 'economics', 'practical', 'social']),

-- Faculty of Agrobiology, Food and Natural Resources (FAPPZ)
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='FAPPZ'), 'Agrobiology', 'Bachelor', 'Czech', 0, ARRAY['science', 'research', 'analytical', 'practical', 'medical']),
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='FAPPZ'), 'Food Technology and Nutrition', 'Bachelor', 'Czech', 0, ARRAY['science', 'engineering', 'medical', 'analytical', 'practical']),

-- Faculty of Engineering (TF)
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='TF'), 'Agricultural Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'practical', 'innovation', 'analytical']),
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='TF'), 'Bioengineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'science', 'medical', 'innovation']),

-- Faculty of Forestry and Wood Sciences (FLD)
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='FLD'), 'Forestry', 'Bachelor', 'Czech', 0, ARRAY['science', 'practical', 'analytical', 'engineering', 'social']),
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='FLD'), 'Wood Technology', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'creative', 'design', 'practical']),

-- Faculty of Environmental Sciences (FŽP)
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='FŽP'), 'Environmental Science', 'Bachelor', 'Czech', 0, ARRAY['science', 'research', 'analytical', 'social', 'international']),
(4, (SELECT id FROM faculty WHERE university_id=4 AND abbreviation='FŽP'), 'Landscape Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'design', 'creative', 'science', 'practical']),

-- University of Chemistry and Technology, Prague (id=5)
-- Faculty of Chemical Technology (FCHT)
(5, (SELECT id FROM faculty WHERE university_id=5 AND abbreviation='FCHT'), 'Chemical Technology', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'science', 'analytical', 'innovation']),
(5, (SELECT id FROM faculty WHERE university_id=5 AND abbreviation='FCHT'), 'Chemistry and Technology of Materials', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'science', 'research', 'innovation']),

-- Faculty of Environmental Technology (FTOP)
(5, (SELECT id FROM faculty WHERE university_id=5 AND abbreviation='FTOP'), 'Environmental Technology', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'science', 'analytical', 'social', 'innovation']),
(5, (SELECT id FROM faculty WHERE university_id=5 AND abbreviation='FTOP'), 'Water Technology', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'science', 'practical', 'analytical']),

-- Faculty of Food and Biochemical Technology (FPBT)
(5, (SELECT id FROM faculty WHERE university_id=5 AND abbreviation='FPBT'), 'Food Technology', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'science', 'medical', 'practical']),
(5, (SELECT id FROM faculty WHERE university_id=5 AND abbreviation='FPBT'), 'Biochemistry', 'Bachelor', 'Czech', 0, ARRAY['science', 'research', 'analytical', 'medical', 'technical']),

-- Faculty of Chemical Engineering (FCHI)
(5, (SELECT id FROM faculty WHERE university_id=5 AND abbreviation='FCHI'), 'Chemical Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'analytical', 'innovation', 'business']),
(5, (SELECT id FROM faculty WHERE university_id=5 AND abbreviation='FCHI'), 'Process Engineering', 'Bachelor', 'Czech', 0, ARRAY['engineering', 'technical', 'analytical', 'practical', 'management']),

-- Academy of Performing Arts in Prague (id=6)
-- Theatre Faculty (DAMU)
(6, (SELECT id FROM faculty WHERE university_id=6 AND abbreviation='DAMU'), 'Acting', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'communication', 'collaborative', 'design']),
(6, (SELECT id FROM faculty WHERE university_id=6 AND abbreviation='DAMU'), 'Directing', 'Master', 'Czech', 0, ARRAY['arts', 'creative', 'leadership', 'management', 'design']),

-- Film and TV School (FAMU)
(6, (SELECT id FROM faculty WHERE university_id=6 AND abbreviation='FAMU'), 'Film and TV Directing', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'design', 'management', 'technical']),
(6, (SELECT id FROM faculty WHERE university_id=6 AND abbreviation='FAMU'), 'Cinematography', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'technical', 'design', 'innovation']),
(6, (SELECT id FROM faculty WHERE university_id=6 AND abbreviation='FAMU'), 'Screenwriting', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'communication', 'journalism', 'humanities']),

-- Music and Dance Faculty (HAMU)
(6, (SELECT id FROM faculty WHERE university_id=6 AND abbreviation='HAMU'), 'Music Performance', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'communication', 'collaborative', 'teaching']),
(6, (SELECT id FROM faculty WHERE university_id=6 AND abbreviation='HAMU'), 'Composition', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'design', 'innovation', 'analytical']),

-- Academy of Fine Arts in Prague (id=7)
(7, (SELECT id FROM faculty WHERE university_id=7 AND abbreviation='MAL1'), 'Painting', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'design', 'innovation', 'communication']),
(7, (SELECT id FROM faculty WHERE university_id=7 AND abbreviation='SOCH1'), 'Sculpture', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'design', 'engineering', 'innovation']),
(7, (SELECT id FROM faculty WHERE university_id=7 AND abbreviation='GRA1'), 'Printmaking', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'design', 'technical', 'innovation']),
(7, (SELECT id FROM faculty WHERE university_id=7 AND abbreviation='INTM1'), 'Intermedia', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'design', 'media', 'innovation', 'technical']),
(7, (SELECT id FROM faculty WHERE university_id=7 AND abbreviation='ARCH'), 'Architecture', 'Bachelor', 'Czech', 0, ARRAY['architecture', 'design', 'creative', 'engineering', 'technical']),
(7, (SELECT id FROM faculty WHERE university_id=7 AND abbreviation='KTDU'), 'Art History and Theory', 'Bachelor', 'Czech', 0, ARRAY['humanities', 'arts', 'research', 'analytical', 'communication']),

-- Academy of Arts, Architecture and Design in Prague (id=8)
(8, (SELECT id FROM faculty WHERE university_id=8 AND name='Department of Architecture'), 'Architecture', 'Bachelor', 'Czech', 0, ARRAY['architecture', 'design', 'creative', 'engineering', 'technical']),
(8, (SELECT id FROM faculty WHERE university_id=8 AND name='Department of Design'), 'Design', 'Bachelor', 'Czech', 0, ARRAY['design', 'creative', 'arts', 'technical', 'innovation']),
(8, (SELECT id FROM faculty WHERE university_id=8 AND name='Department of Fine Arts'), 'Fine Arts', 'Bachelor', 'Czech', 0, ARRAY['arts', 'creative', 'design', 'innovation', 'communication']),
(8, (SELECT id FROM faculty WHERE university_id=8 AND name='Department of Graphic Design'), 'Graphic Design', 'Bachelor', 'Czech', 0, ARRAY['design', 'creative', 'arts', 'technical', 'media']),
(8, (SELECT id FROM faculty WHERE university_id=8 AND name='Department of Applied Arts I'), 'Product Design', 'Bachelor', 'Czech', 0, ARRAY['design', 'creative', 'engineering', 'innovation', 'technical']),

-- Anglo-American University (id=14)
(14, (SELECT id FROM faculty WHERE university_id=14 AND abbreviation='SBu'), 'Business Administration', 'Bachelor', 'English', 0, ARRAY['business', 'management', 'international', 'entrepreneurship', 'communication']),
(14, (SELECT id FROM faculty WHERE university_id=14 AND abbreviation='SBu'), 'International Finance', 'Bachelor', 'English', 0, ARRAY['business', 'analytical', 'economics', 'international', 'management']),
(14, (SELECT id FROM faculty WHERE university_id=14 AND name='School of Arts, Humanities and Social Sciences'), 'Humanities', 'Bachelor', 'English', 0, ARRAY['humanities', 'communication', 'international', 'creative', 'analytical']),
(14, (SELECT id FROM faculty WHERE university_id=14 AND name='School of Arts, Humanities and Social Sciences'), 'Journalism and Communications', 'Bachelor', 'English', 0, ARRAY['journalism', 'communication', 'creative', 'media', 'international']),
(14, (SELECT id FROM faculty WHERE university_id=14 AND abbreviation='SIRD'), 'International Relations and Diplomacy', 'Bachelor', 'English', 0, ARRAY['international', 'law', 'communication', 'analytical', 'business']),

-- University of New York in Prague (id=15)
(15, (SELECT id FROM faculty WHERE university_id=15 AND name='School of Business and IT'), 'Business Administration', 'Bachelor', 'English', 0, ARRAY['business', 'management', 'international', 'entrepreneurship', 'technical']),
(15, (SELECT id FROM faculty WHERE university_id=15 AND name='School of Business and IT'), 'Information Technology', 'Bachelor', 'English', 0, ARRAY['technical', 'computer_science', 'business', 'innovation', 'analytical']),
(15, (SELECT id FROM faculty WHERE university_id=15 AND name='School of Psychology'), 'Psychology', 'Bachelor', 'English', 0, ARRAY['medical', 'science', 'research', 'analytical', 'communication']),
(15, (SELECT id FROM faculty WHERE university_id=15 AND name='School of International Relations and Media Studies'), 'International Relations', 'Bachelor', 'English', 0, ARRAY['international', 'law', 'communication', 'business', 'analytical']),
(15, (SELECT id FROM faculty WHERE university_id=15 AND name='School of International Relations and Media Studies'), 'Media Studies', 'Bachelor', 'English', 0, ARRAY['journalism', 'communication', 'creative', 'media', 'international']),

-- Unicorn University (id=21)
(21, (SELECT id FROM faculty WHERE university_id=21 AND name='Software Development (BA)'), 'Software Development', 'Bachelor', 'Czech', 0, ARRAY['technical', 'computer_science', 'engineering', 'innovation', 'analytical']),
(21, (SELECT id FROM faculty WHERE university_id=21 AND name='Business Management (BA)'), 'Business Management', 'Bachelor', 'Czech', 0, ARRAY['business', 'management', 'entrepreneurship', 'communication', 'analytical']),
(21, (SELECT id FROM faculty WHERE university_id=21 AND name='Applied Economics and Data Analysis (MA)'), 'Applied Economics and Data Analysis', 'Master', 'Czech', 0, ARRAY['economics', 'analytical', 'technical', 'business', 'research']),

-- NEWTON University (id=22)
(22, (SELECT id FROM faculty WHERE university_id=22 AND name='Economics and Management (BA + MA)'), 'Economics and Management', 'Bachelor', 'Czech', 0, ARRAY['economics', 'business', 'management', 'analytical', 'entrepreneurship']),
(22, (SELECT id FROM faculty WHERE university_id=22 AND name='Business Leadership (BA)'), 'Business Leadership', 'Bachelor', 'Czech', 0, ARRAY['business', 'leadership', 'management', 'communication', 'entrepreneurship'])

ON CONFLICT DO NOTHING;