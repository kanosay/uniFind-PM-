-- UniFind MVP – initial schema (PostgreSQL 16)
-- Entities follow the PBS/WBS: University, Major, RankingSource, RankingEntry, Review,
-- TestQuestion, TestResult, BlogPost, Comment, User, AuditLog (+ Faculty from the Prague data set).

-- ───────────── Users & auth ─────────────
CREATE TABLE app_user (
  id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  email         TEXT NOT NULL,
  password_hash TEXT,                       -- NULL for Google-only accounts
  google_id     TEXT UNIQUE,
  display_name  TEXT NOT NULL,
  role          TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'admin')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT email_lowercase CHECK (email = lower(email))
);
CREATE UNIQUE INDEX app_user_email_key ON app_user (email);

-- ───────────── University catalogue ─────────────
CREATE TABLE university (
  id           INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name         TEXT NOT NULL UNIQUE,
  abbreviation TEXT,
  type         TEXT NOT NULL CHECK (type IN ('Public', 'Private', 'State')),
  category     TEXT NOT NULL CHECK (category IN ('University-type', 'Non-university type')),
  address      TEXT,
  website      TEXT,
  note         TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX university_type_idx     ON university (type);
CREATE INDEX university_category_idx ON university (category);
CREATE INDEX university_name_lower_idx ON university (lower(name));

-- Faculties / academic units (faculty, department, studio, school, ...)
CREATE TABLE faculty (
  id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  university_id INTEGER NOT NULL REFERENCES university(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  abbreviation  TEXT,
  city          TEXT,
  unit_type     TEXT NOT NULL,
  UNIQUE (university_id, name)
);
CREATE INDEX faculty_university_idx ON faculty (university_id);
CREATE INDEX faculty_name_lower_idx ON faculty (lower(name));

-- Majors / study programmes. The Prague data set has no programme-level data yet
-- (PBS task 7.1 "collect majors"), so this table starts empty and feeds the
-- major / fee / language filters once populated.
CREATE TABLE major (
  id                  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  university_id       INTEGER NOT NULL REFERENCES university(id) ON DELETE CASCADE,
  faculty_id          INTEGER REFERENCES faculty(id) ON DELETE SET NULL,
  name                TEXT NOT NULL,
  degree_level        TEXT CHECK (degree_level IN ('Bachelor', 'Master', 'Doctoral')),
  language            TEXT,                  -- e.g. 'English', 'Czech'
  tuition_fee_eur_year NUMERIC(10, 2),       -- NULL = unknown, 0 = free
  tags                TEXT[] NOT NULL DEFAULT '{}'  -- used by the Major finder scoring
);
CREATE INDEX major_university_idx ON major (university_id);
CREATE INDEX major_name_lower_idx ON major (lower(name));
CREATE INDEX major_tags_idx       ON major USING GIN (tags);

-- ───────────── Ratings & reviews ─────────────
CREATE TABLE ranking_source (
  id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code TEXT NOT NULL UNIQUE,     -- QS, THE, ARWU
  name TEXT NOT NULL,
  url  TEXT
);

CREATE TABLE ranking_entry (
  id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  source_id     INTEGER NOT NULL REFERENCES ranking_source(id) ON DELETE CASCADE,
  university_id INTEGER NOT NULL REFERENCES university(id) ON DELETE CASCADE,
  year          SMALLINT NOT NULL,
  rank_position INTEGER NOT NULL CHECK (rank_position > 0),  -- lower bound for banded ranks
  rank_band     TEXT,                                        -- e.g. '801-1000'
  UNIQUE (source_id, university_id, year)
);
CREATE INDEX ranking_entry_university_idx ON ranking_entry (university_id);

CREATE TABLE review (
  id            INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id       INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  university_id INTEGER NOT NULL REFERENCES university(id) ON DELETE CASCADE,
  rating        SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment       TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, university_id)          -- 1 review per user per university
);
CREATE INDEX review_university_idx ON review (university_id, created_at DESC);

-- ───────────── Major finder test ─────────────
CREATE TABLE test_question (
  id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  position INTEGER NOT NULL UNIQUE,
  text     TEXT NOT NULL,
  -- [{ "id": "a", "label": "...", "weights": { "<major tag>": 2, ... } }, ...]
  options  JSONB NOT NULL
);

CREATE TABLE test_result (
  id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id     INTEGER REFERENCES app_user(id) ON DELETE SET NULL,   -- anonymous allowed
  answers     JSONB NOT NULL,
  recommended JSONB NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ───────────── Blog ─────────────
CREATE TABLE blog_post (
  id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  author_id  INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  title      TEXT NOT NULL,
  body       TEXT NOT NULL,
  status     TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('published', 'hidden')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX blog_post_created_idx ON blog_post (created_at DESC) WHERE status = 'published';

CREATE TABLE blog_comment (
  id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  post_id    INTEGER NOT NULL REFERENCES blog_post(id) ON DELETE CASCADE,
  author_id  INTEGER NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  body       TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX blog_comment_post_idx ON blog_comment (post_id, created_at);

-- ───────────── Audit log ─────────────
CREATE TABLE audit_log (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  actor_id    INTEGER REFERENCES app_user(id) ON DELETE SET NULL,
  actor_role  TEXT,
  action      TEXT NOT NULL,            -- e.g. 'review.create', 'user.register'
  entity_type TEXT NOT NULL,
  entity_id   TEXT,
  details     JSONB NOT NULL DEFAULT '{}',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX audit_log_created_idx ON audit_log (created_at DESC);
CREATE INDEX audit_log_entity_idx  ON audit_log (entity_type, entity_id);
