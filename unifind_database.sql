--
-- PostgreSQL database dump
--

\restrict w2wOHyLyn5YraegxI1WNZy9FIV0GRqxQFVm2btp7ftYjeUmrOM0wfpVzldkuLiI

-- Dumped from database version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS '';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: app_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.app_user (
    id integer NOT NULL,
    email text NOT NULL,
    password_hash text,
    google_id text,
    display_name text NOT NULL,
    role text DEFAULT 'student'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT app_user_role_check CHECK ((role = ANY (ARRAY['student'::text, 'admin'::text]))),
    CONSTRAINT email_lowercase CHECK ((email = lower(email)))
);


--
-- Name: app_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.app_user ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.app_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_log (
    id bigint NOT NULL,
    actor_id integer,
    actor_role text,
    action text NOT NULL,
    entity_type text NOT NULL,
    entity_id text,
    details jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.audit_log ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: blog_comment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_comment (
    id integer NOT NULL,
    post_id integer NOT NULL,
    author_id integer NOT NULL,
    body text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: blog_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.blog_comment ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.blog_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: blog_post; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.blog_post (
    id integer NOT NULL,
    author_id integer NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    status text DEFAULT 'published'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT blog_post_status_check CHECK ((status = ANY (ARRAY['published'::text, 'hidden'::text])))
);


--
-- Name: blog_post_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.blog_post ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.blog_post_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: faculty; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.faculty (
    id integer NOT NULL,
    university_id integer NOT NULL,
    name text NOT NULL,
    abbreviation text,
    city text,
    unit_type text NOT NULL
);


--
-- Name: faculty_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.faculty ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.faculty_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: major; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.major (
    id integer NOT NULL,
    university_id integer NOT NULL,
    faculty_id integer,
    name text NOT NULL,
    degree_level text,
    language text,
    tuition_fee_eur_year numeric(10,2),
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    CONSTRAINT major_degree_level_check CHECK ((degree_level = ANY (ARRAY['Bachelor'::text, 'Master'::text, 'Doctoral'::text])))
);


--
-- Name: major_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.major ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.major_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ranking_entry; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ranking_entry (
    id integer NOT NULL,
    source_id integer NOT NULL,
    university_id integer NOT NULL,
    year smallint NOT NULL,
    rank_position integer NOT NULL,
    rank_band text,
    CONSTRAINT ranking_entry_rank_position_check CHECK ((rank_position > 0))
);


--
-- Name: ranking_entry_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ranking_entry ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ranking_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ranking_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ranking_source (
    id integer NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    url text
);


--
-- Name: ranking_source_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.ranking_source ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.ranking_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: review; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.review (
    id integer NOT NULL,
    user_id integer NOT NULL,
    university_id integer NOT NULL,
    rating smallint NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT review_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


--
-- Name: review_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.review ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    name text NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: test_question; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_question (
    id integer NOT NULL,
    "position" integer NOT NULL,
    text text NOT NULL,
    options jsonb NOT NULL
);


--
-- Name: test_question_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.test_question ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.test_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: test_result; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_result (
    id integer NOT NULL,
    user_id integer,
    answers jsonb NOT NULL,
    recommended jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: test_result_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.test_result ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.test_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: university; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.university (
    id integer NOT NULL,
    name text NOT NULL,
    abbreviation text,
    type text NOT NULL,
    category text NOT NULL,
    address text,
    website text,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT university_category_check CHECK ((category = ANY (ARRAY['University-type'::text, 'Non-university type'::text]))),
    CONSTRAINT university_type_check CHECK ((type = ANY (ARRAY['Public'::text, 'Private'::text, 'State'::text])))
);


--
-- Name: university_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

ALTER TABLE public.university ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.university_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.app_user (id, email, password_hash, google_id, display_name, role, created_at) FROM stdin;
\.


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audit_log (id, actor_id, actor_role, action, entity_type, entity_id, details, created_at) FROM stdin;
\.


--
-- Data for Name: blog_comment; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blog_comment (id, post_id, author_id, body, created_at) FROM stdin;
\.


--
-- Data for Name: blog_post; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blog_post (id, author_id, title, body, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: faculty; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.faculty (id, university_id, name, abbreviation, city, unit_type) FROM stdin;
1	1	Catholic Theological Faculty	KTF	Prague	Faculty
2	1	Protestant Theological Faculty	ETF	Prague	Faculty
3	1	Hussite Theological Faculty	HTF	Prague	Faculty
4	1	Faculty of Law	PF	Prague	Faculty
5	1	First Faculty of Medicine	1. LF	Prague	Faculty
6	1	Second Faculty of Medicine	2. LF	Prague	Faculty
7	1	Third Faculty of Medicine	3. LF	Prague	Faculty
8	1	Faculty of Medicine in Pilsen	LFP	Pilsen	Faculty
9	1	Faculty of Medicine in Hradec Králové	LFHK	Hradec Králové	Faculty
10	1	Faculty of Pharmacy in Hradec Králové	FaF	Hradec Králové	Faculty
11	1	Faculty of Arts	FF	Prague	Faculty
12	1	Faculty of Science	PřF	Prague	Faculty
13	1	Faculty of Mathematics and Physics	MFF	Prague	Faculty
14	1	Faculty of Education	PedF	Prague	Faculty
15	1	Faculty of Social Sciences	FSV	Prague	Faculty
16	1	Faculty of Physical Education and Sport	FTVS	Prague	Faculty
17	1	Faculty of Humanities	FHS	Prague	Faculty
18	2	Faculty of Civil Engineering	FSv	Prague	Faculty
19	2	Faculty of Mechanical Engineering	FS	Prague	Faculty
20	2	Faculty of Electrical Engineering	FEL	Prague	Faculty
21	2	Faculty of Nuclear Sciences and Physical Engineering	FJFI	Prague	Faculty
22	2	Faculty of Architecture	FA	Prague	Faculty
23	2	Faculty of Transportation Sciences	FD	Prague	Faculty
24	2	Faculty of Biomedical Engineering	FBMI	Kladno	Faculty
25	2	Faculty of Information Technology	FIT	Prague	Faculty
26	3	Faculty of Finance and Accounting	FFÚ	Prague	Faculty
27	3	Faculty of International Relations	FMV	Prague	Faculty
28	3	Faculty of Business Administration	FPH	Prague	Faculty
29	3	Faculty of Informatics and Statistics	FIS	Prague	Faculty
30	3	Faculty of Economics	NF	Prague	Faculty
31	3	Faculty of Management	FM	Jindřichův Hradec	Faculty
32	4	Faculty of Economics and Management	PEF	Prague	Faculty
33	4	Faculty of Agrobiology, Food and Natural Resources	FAPPZ	Prague	Faculty
34	4	Faculty of Engineering	TF	Prague	Faculty
35	4	Faculty of Forestry and Wood Sciences	FLD	Prague	Faculty
36	4	Faculty of Environmental Sciences	FŽP	Prague	Faculty
37	4	Faculty of Tropical AgriSciences	FTZ	Prague	Faculty
38	5	Faculty of Chemical Technology	FCHT	Prague	Faculty
39	5	Faculty of Environmental Technology	FTOP	Prague	Faculty
40	5	Faculty of Food and Biochemical Technology	FPBT	Prague	Faculty
41	5	Faculty of Chemical Engineering	FCHI	Prague	Faculty
42	6	Theatre Faculty	DAMU	Prague	Faculty
43	6	Film and TV School	FAMU	Prague	Faculty
44	6	Music and Dance Faculty	HAMU	Prague	Faculty
45	7	Painting Studio 1	MAL1	Prague	Studio
46	7	Painting Studio 2	MAL2	Prague	Studio
47	7	Painting Studio 3	MAL3	Prague	Studio
48	7	Painting Studio 4	MAL4	Prague	Studio
49	7	Sculpture Studio 1	SOCH1	Prague	Studio
50	7	Sculpture Studio 2	SOCH2	Prague	Studio
51	7	Figurative Sculpture and Medal Studio	SOCHF	Prague	Studio
52	7	Printmaking Studio 1	GRA1	Prague	Studio
53	7	Printmaking Studio 2	GRA2	Prague	Studio
54	7	Drawing Studio	KRES	Prague	Studio
55	7	Intermedia Studio 1	INTM1	Prague	Studio
56	7	Intermedia Studio 2	INTM2	Prague	Studio
57	7	Intermedia Studio 3	INTM3	Prague	Studio
58	7	New Media Studio 1	NOV1	Prague	Studio
59	7	New Media Studio 2	NOV2	Prague	Studio
60	7	Painting Restoration Studio	RESTM	Prague	Studio
61	7	Sculpture Restoration Studio	RESTS	Prague	Studio
62	7	Architecture Studio	ARCH	Prague	Studio
63	7	Art in Context (EN programme)	\N	Prague	Study programme
64	7	Department of Art History and Theory	KTDU	Prague	Department
65	8	Department of Architecture	\N	Prague	Department
66	8	Department of Design	\N	Prague	Department
67	8	Department of Fine Arts	\N	Prague	Department
68	8	Department of Applied Arts I	\N	Prague	Department
69	8	Department of Applied Arts II	\N	Prague	Department
70	8	Department of Graphic Design	\N	Prague	Department
71	8	Department of Art Theory and History	\N	Prague	Department
72	9	Faculty of Security and Law	FBP	Prague	Faculty
73	9	Faculty of Security Management	FBM	Prague	Faculty
74	10	Faculty of Business and Law	\N	Prague / Ostrava	Faculty
75	10	Faculty of Aviation and Transport	\N	Prague	Faculty
76	10	Faculty of Security Studies	\N	Prague	Faculty
77	11	Faculty of Economic Studies	FES	Prague	Faculty
78	11	Faculty of Legal and Administrative Studies	FPSS	Prague	Faculty
79	12	Department of Asian Studies	\N	Prague	Department
80	12	Department of Tourism	\N	Prague	Department
81	12	Department of Foreign Languages	\N	Prague	Department
82	12	Department of Financial Management	\N	Prague	Department
83	12	Department of International Relations and European Studies (EN)	\N	Prague	Department
84	12	Department of International Business	\N	Prague	Department
85	12	Department of Media Studies	\N	Prague	Department
86	12	Department of International Relations and European Studies	\N	Prague	Department
87	12	Department of Political Science and Anglophone Studies	\N	Prague	Department
88	12	Department of Law and Public Administration	\N	Prague	Department
89	13	Department of Public Law and Public Administration	\N	Prague	Department
90	13	Department of Private Law	\N	Prague	Department
91	13	Department of Security Studies	\N	Prague	Department
92	13	Department of Political Science	\N	Prague	Department
93	13	Department of Economics	\N	Prague	Department
94	14	Institute of Security Management	\N	Prague	Institute / Centre
95	14	Institute of Tourism	\N	Prague	Institute / Centre
96	14	Centre of Excellence CEDUT	CEDUT	Prague	Institute / Centre
97	15	School of Business	SBu	Prague	School
98	15	School of Arts, Humanities and Social Sciences	\N	Prague	School
99	15	School of International Relations and Diplomacy	SIRD	Prague	School
100	16	School of Business and IT	\N	Prague	School
101	16	School of Psychology	\N	Prague	School
102	16	School of International Relations and Media Studies	\N	Prague	School
103	17	Business Economics Department	\N	Prague	Department
104	17	Economics Department	\N	Prague	Department
105	17	Human Resources Department	\N	Prague	Department
106	17	Management Department	\N	Prague	Department
107	17	Marketing Department	\N	Prague	Department
108	18	Department of Marketing Communications	\N	Prague	Department
109	18	Department of Visual Arts	\N	Prague	Department
110	18	Graphic and Media Design Studio	\N	Prague	Studio
111	18	Animation and VFX Studio	\N	Prague	Studio
112	18	Photography and Audiovisual Studio	\N	Prague	Studio
113	19	Department of Nursing	\N	Prague	Department
114	19	Department of Midwifery	\N	Prague	Department
115	19	Department of Paramedic Science	\N	Prague	Department
116	19	Department of Physiotherapy	\N	Prague	Department
117	19	Department of Lifelong Learning	\N	Prague	Department
118	20	Department of Marketing	\N	Prague	Department
119	20	Department of Economics	\N	Prague	Department
120	20	Department of Political and Social Sciences	\N	Prague	Department
121	20	Department of International Relations and Diplomacy	\N	Prague	Department
122	20	Department of Management	\N	Prague	Department
123	20	Department of Languages	\N	Prague	Department
124	20	Institute of International Management and Marketing	\N	Prague	Institute / Centre
125	21	Department of Sport and Outdoor Activities	\N	Prague	Department
126	22	Architectural Design (AD) Studio – vertical studios	AD	Prague	Studio
127	22	Bachelor programme Architecture	\N	Prague	Study programme
128	22	Master programme Architecture and Urbanism	\N	Prague	Study programme
129	23	Painting	\N	Prague	Creative specialisation
130	23	Graphics	\N	Prague	Creative specialisation
131	23	Photography	\N	Prague	Creative specialisation
132	23	Space / Interior Design	\N	Prague	Creative specialisation
133	23	Intermedia	\N	Prague	Creative specialisation
134	23	Multimedia	\N	Prague	Creative specialisation
135	24	Psychology (BA + MA)	\N	Prague	Study programme
136	24	Social Work with focus on Communication and Applied Psychotherapy	\N	Prague	Study programme
137	25	Software Development (BA)	\N	Prague	Study programme
138	25	Business Management (BA)	\N	Prague	Study programme
139	25	Applied Economics and Data Analysis (MA)	\N	Prague	Study programme
140	26	Economics and Management (BA + MA)	\N	Prague / Brno	Study programme
141	26	Business Leadership (BA)	\N	Prague / Brno	Study programme
\.


--
-- Data for Name: major; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.major (id, university_id, faculty_id, name, degree_level, language, tuition_fee_eur_year, tags) FROM stdin;
\.


--
-- Data for Name: ranking_entry; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ranking_entry (id, source_id, university_id, year, rank_position, rank_band) FROM stdin;
\.


--
-- Data for Name: ranking_source; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ranking_source (id, code, name, url) FROM stdin;
1	QS	QS World University Rankings	https://www.topuniversities.com/world-university-rankings
2	THE	Times Higher Education World University Rankings	https://www.timeshighereducation.com/world-university-rankings
3	ARWU	Academic Ranking of World Universities (Shanghai)	https://www.shanghairanking.com/rankings/arwu
\.


--
-- Data for Name: review; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.review (id, user_id, university_id, rating, comment, created_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schema_migrations (name, applied_at) FROM stdin;
001_init.sql	2026-11-11 21:51:55.214053+00
\.


--
-- Data for Name: test_question; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.test_question (id, "position", text, options) FROM stdin;
\.


--
-- Data for Name: test_result; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.test_result (id, user_id, answers, recommended, created_at) FROM stdin;
\.


--
-- Data for Name: university; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.university (id, name, abbreviation, type, category, address, website, note, created_at, updated_at) FROM stdin;
1	Charles University	UK	Public	University-type	Ovocný trh 560/5, Prague 1	https://cuni.cz	17 faculties: 14 in Prague, 1 in Pilsen, 2 in Hradec Králové.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
2	Czech Technical University in Prague	ČVUT	Public	University-type	Jugoslávských partyzánů 1580/3, Prague 6	https://www.cvut.cz	Besides faculties it also has university institutes (e.g. Masaryk Institute of Advanced Studies, CIIRC, IEAP, Klokner Institute).	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
3	Prague University of Economics and Business	VŠE	Public	University-type	Square W. Churchilla 1938/4, Prague 3	https://www.vse.cz	The Faculty of Management is located in Jindřichův Hradec.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
4	Czech University of Life Sciences Prague	ČZU	Public	University-type	Kamýcká 129, Prague 6 – Suchdol	https://www.czu.cz	The Faculty of Economics and Management also runs regional consultation centres (Cheb, Most, Klatovy, etc.).	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
5	University of Chemistry and Technology, Prague	VŠCHT	Public	University-type	Technická 5, Prague 6	https://www.vscht.cz	\N	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
6	Academy of Performing Arts in Prague	AMU	Public	University-type	Malostranské Square 259/12, Prague 1	https://www.amu.cz	\N	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
7	Academy of Fine Arts in Prague	AVU	Public	University-type	U Akademie 172/4, Prague 7	https://www.avu.cz	Not divided into faculties. Teaching takes place in 18 studios plus the Department of Art History and Theory.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
8	Academy of Arts, Architecture and Design in Prague	UMPRUM	Public	University-type	Square Jana Palacha 80, Prague 1	https://www.umprum.cz	Not divided into faculties – departments group the studios (e.g. Architecture I–IV, Product Design, Glass, Ceramics and Porcelain, Textile, Illustration and Graphics, Animation and Film, Photography II).	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
9	Police Academy of the Czech Republic in Prague	PA ČR	State	University-type	Lhotecká 559/7, Prague 12 – Kamýk	https://www.polac.cz	State university under the Ministry of the Interior.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
10	Pan-European University	PEUNI	Private	University-type	U vinných sklepů 1062/11, Prague 9 – Vysočany	https://www.peuni.cz	Three faculties since 2025/26; previously two faculties (former College of Entrepreneurship and Law and former University College of Business in Prague). Also a site in Ostrava.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
11	University of Finance and Administration	VŠFS	Private	University-type	Estonská 500, Prague 10	https://www.vsfs.cz	Faculties listed in the VŠFS Annual Report 2025. Study centres also in Karlovy Vary and Most.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
12	Metropolitan University Prague	MUP	Private	University-type	Dubečská 900/10, Prague 10	https://www.mup.cz	No faculties – 10 departments (per MUP Annual Report 2023).	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
13	CEVRO University	CEVRO	Private	University-type	Jungmannova 17, Prague 1	https://www.cevro.cz	Called CEVRO Institute until 16 Jan 2025. No faculties – departments (per Annual Report 2024). Also a site in Český Krumlov.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
14	AMBIS University	AMBIS	Private	University-type	Lindnerova 575/1, Prague 8	https://www.ambis.cz	Called AMBIS College until 12 May 2026. No faculties – institutes (per Annual Report 2025). Branches in Brno and Bratislava.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
15	Anglo-American University	AAU	Private	Non-university type	Letenská 120/5, Prague 1	https://www.aauni.edu	Divided into 'Schools' (similar to faculties/departments), per Annual Report 2025.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
16	University of New York in Prague	UNYP	Private	Non-university type	Londýnská 41, Prague 2	https://www.unyp.cz	Divided into academic 'Schools'.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
17	University of Economics and Management	VŠEM	Private	Non-university type	Nárožní 2600/9a, Prague 5	https://www.vsem.cz	No faculties. Departments as listed on the VŠEM English website.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
18	Prague School of Creative Communication	VŠKK	Private	Non-university type	Na Pankráci 420/54, Prague 4	https://www.vskk.cz	No faculties – 2 departments and 3 studios (per Annual Report 2025).	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
19	Medical College	VŠZ	Private	Non-university type	Duškova 7, Prague 5	https://www.vszdrav.cz	No faculties – departments (per Annual Report 2024).	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
20	United University (Prague)	UCP	Private	Non-university type	Prague 5	https://www.ucp.cz	Formerly Institute of Hospitality Management in Prague 8 / University College Prague. Departments per Annual Report 2023 (under the former name). Very small number of students.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
21	College of Physical Education and Sport Palestra	PALESTRA	Private	Non-university type	Slovačíkova 400/1, Prague 9	https://www.palestra.cz	No faculties. Department taken from the Czech university sports association directory; no other departments found in public sources.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
22	Architectural Institute in Prague	ARCHIP	Private	Non-university type	Prague 2	https://www.archip.eu	Small school without faculties or departments – teaching in vertical design studios.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
23	Art & Design Institute	ADI	Private	Non-university type	Slezská 68, Prague 3	https://www.adi.cz	No faculties or departments – one bachelor's programme with 6 creative specialisations.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
24	Prague College of Psychosocial Studies	PVŠPS	Private	Non-university type	Hekrova 805, Prague 4	https://www.pvsps.cz	No faculties or departments published – study programmes listed instead (per National Accreditation Bureau report).	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
25	Unicorn University	UU	Private	Non-university type	V Kapslovně 2767/2, Prague 3	https://unicornuniversity.net	Called Unicorn College until 2020. No faculties or departments published – study programmes listed instead.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
26	NEWTON University	NU	Private	Non-university type	5. května 1640/65, Prague 4	https://www.newton.university	Formerly NEWTON College. No faculties or departments published – study programmes listed instead.	2026-11-11 21:51:55.322501+00	2026-11-11 21:51:55.322501+00
\.


--
-- Name: app_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.app_user_id_seq', 1, false);


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audit_log_id_seq', 1, false);


--
-- Name: blog_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.blog_comment_id_seq', 1, false);


--
-- Name: blog_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.blog_post_id_seq', 1, false);


--
-- Name: faculty_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.faculty_id_seq', 141, true);


--
-- Name: major_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.major_id_seq', 1, false);


--
-- Name: ranking_entry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ranking_entry_id_seq', 1, false);


--
-- Name: ranking_source_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ranking_source_id_seq', 3, true);


--
-- Name: review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.review_id_seq', 1, false);


--
-- Name: test_question_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.test_question_id_seq', 1, false);


--
-- Name: test_result_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.test_result_id_seq', 1, false);


--
-- Name: university_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.university_id_seq', 26, true);


--
-- Name: app_user app_user_google_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_google_id_key UNIQUE (google_id);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: blog_comment blog_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comment
    ADD CONSTRAINT blog_comment_pkey PRIMARY KEY (id);


--
-- Name: blog_post blog_post_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_post
    ADD CONSTRAINT blog_post_pkey PRIMARY KEY (id);


--
-- Name: faculty faculty_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.faculty
    ADD CONSTRAINT faculty_pkey PRIMARY KEY (id);


--
-- Name: faculty faculty_university_id_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.faculty
    ADD CONSTRAINT faculty_university_id_name_key UNIQUE (university_id, name);


--
-- Name: major major_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.major
    ADD CONSTRAINT major_pkey PRIMARY KEY (id);


--
-- Name: ranking_entry ranking_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranking_entry
    ADD CONSTRAINT ranking_entry_pkey PRIMARY KEY (id);


--
-- Name: ranking_entry ranking_entry_source_id_university_id_year_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranking_entry
    ADD CONSTRAINT ranking_entry_source_id_university_id_year_key UNIQUE (source_id, university_id, year);


--
-- Name: ranking_source ranking_source_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranking_source
    ADD CONSTRAINT ranking_source_code_key UNIQUE (code);


--
-- Name: ranking_source ranking_source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranking_source
    ADD CONSTRAINT ranking_source_pkey PRIMARY KEY (id);


--
-- Name: review review_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (id);


--
-- Name: review review_user_id_university_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_user_id_university_id_key UNIQUE (user_id, university_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (name);


--
-- Name: test_question test_question_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_question
    ADD CONSTRAINT test_question_pkey PRIMARY KEY (id);


--
-- Name: test_question test_question_position_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_question
    ADD CONSTRAINT test_question_position_key UNIQUE ("position");


--
-- Name: test_result test_result_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_result
    ADD CONSTRAINT test_result_pkey PRIMARY KEY (id);


--
-- Name: university university_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.university
    ADD CONSTRAINT university_name_key UNIQUE (name);


--
-- Name: university university_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.university
    ADD CONSTRAINT university_pkey PRIMARY KEY (id);


--
-- Name: app_user_email_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX app_user_email_key ON public.app_user USING btree (email);


--
-- Name: audit_log_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_log_created_idx ON public.audit_log USING btree (created_at DESC);


--
-- Name: audit_log_entity_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX audit_log_entity_idx ON public.audit_log USING btree (entity_type, entity_id);


--
-- Name: blog_comment_post_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX blog_comment_post_idx ON public.blog_comment USING btree (post_id, created_at);


--
-- Name: blog_post_created_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX blog_post_created_idx ON public.blog_post USING btree (created_at DESC) WHERE (status = 'published'::text);


--
-- Name: faculty_name_lower_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX faculty_name_lower_idx ON public.faculty USING btree (lower(name));


--
-- Name: faculty_university_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX faculty_university_idx ON public.faculty USING btree (university_id);


--
-- Name: major_name_lower_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX major_name_lower_idx ON public.major USING btree (lower(name));


--
-- Name: major_tags_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX major_tags_idx ON public.major USING gin (tags);


--
-- Name: major_university_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX major_university_idx ON public.major USING btree (university_id);


--
-- Name: ranking_entry_university_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ranking_entry_university_idx ON public.ranking_entry USING btree (university_id);


--
-- Name: review_university_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX review_university_idx ON public.review USING btree (university_id, created_at DESC);


--
-- Name: university_category_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX university_category_idx ON public.university USING btree (category);


--
-- Name: university_name_lower_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX university_name_lower_idx ON public.university USING btree (lower(name));


--
-- Name: university_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX university_type_idx ON public.university USING btree (type);


--
-- Name: audit_log audit_log_actor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- Name: blog_comment blog_comment_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comment
    ADD CONSTRAINT blog_comment_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: blog_comment blog_comment_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_comment
    ADD CONSTRAINT blog_comment_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.blog_post(id) ON DELETE CASCADE;


--
-- Name: blog_post blog_post_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.blog_post
    ADD CONSTRAINT blog_post_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: faculty faculty_university_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.faculty
    ADD CONSTRAINT faculty_university_id_fkey FOREIGN KEY (university_id) REFERENCES public.university(id) ON DELETE CASCADE;


--
-- Name: major major_faculty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.major
    ADD CONSTRAINT major_faculty_id_fkey FOREIGN KEY (faculty_id) REFERENCES public.faculty(id) ON DELETE SET NULL;


--
-- Name: major major_university_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.major
    ADD CONSTRAINT major_university_id_fkey FOREIGN KEY (university_id) REFERENCES public.university(id) ON DELETE CASCADE;


--
-- Name: ranking_entry ranking_entry_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranking_entry
    ADD CONSTRAINT ranking_entry_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.ranking_source(id) ON DELETE CASCADE;


--
-- Name: ranking_entry ranking_entry_university_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ranking_entry
    ADD CONSTRAINT ranking_entry_university_id_fkey FOREIGN KEY (university_id) REFERENCES public.university(id) ON DELETE CASCADE;


--
-- Name: review review_university_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_university_id_fkey FOREIGN KEY (university_id) REFERENCES public.university(id) ON DELETE CASCADE;


--
-- Name: review review_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE CASCADE;


--
-- Name: test_result test_result_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_result
    ADD CONSTRAINT test_result_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.app_user(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

\unrestrict w2wOHyLyn5YraegxI1WNZy9FIV0GRqxQFVm2btp7ftYjeUmrOM0wfpVzldkuLiI

