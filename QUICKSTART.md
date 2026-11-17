# Quick Start Guide - Career Test Feature

## Prerequisites
- Node.js 20+ installed
- PostgreSQL running (localhost:5432)
- Database `unifind` created with user `unifind`/password `unifind`

## Option 1: Automated Setup (Recommended)

### Windows (PowerShell)
```powershell
cd C:\Users\olegk\Desktop\Ufind\unifind-backend
.\setup-career-test.ps1
```

### Linux/Mac (Bash)
```bash
cd /path/to/Ufind/unifind-backend
bash setup-career-test.sh
```

This script will:
1. ✓ Check PostgreSQL connection
2. ✓ Install dependencies
3. ✓ Run database migrations
4. ✓ Seed universities, test questions, and majors
5. ✓ Verify data integrity
6. ✓ Test API endpoints

## Option 2: Manual Setup

### Backend Setup

```bash
cd unifind-backend

# 1. Install dependencies
npm install

# 2. Ensure PostgreSQL is running
# Check docker-compose.yml or start PostgreSQL service

# 3. Run migrations
npm run db:migrate

# 4. Seed database
npm run db:seed

# 5. Start backend services
npm start
```

Backend will start on:
- Gateway: http://localhost:3000
- Test Service: http://localhost:3004

### Frontend Setup

```bash
cd "uni/unifind-frontend 3"

# 1. Install dependencies
npm install

# 2. Start development server
npm run dev
```

Frontend will start on: http://localhost:5173

## Verify Installation

### Check Database
```sql
-- Connect to database
psql -h localhost -U unifind -d unifind

-- Verify test questions (should be 15)
SELECT COUNT(*) FROM test_question;

-- Verify majors with tags (should be 100+)
SELECT COUNT(*) FROM major WHERE array_length(tags, 1) > 0;

-- Verify universities (should be 24)
SELECT COUNT(*) FROM university;

-- View sample test question
SELECT id, text, options FROM test_question WHERE position = 1;

-- View sample major with tags
SELECT name, tags FROM major LIMIT 5;
```

### Test API Endpoints

```bash
# Get test questions
curl http://localhost:3000/api/test/questions

# Submit test (sample analytical profile)
curl -X POST http://localhost:3000/api/test/submit \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [
      {"questionId": 1, "optionId": "a"},
      {"questionId": 2, "optionId": "a"},
      {"questionId": 3, "optionId": "a"},
      {"questionId": 4, "optionId": "a"},
      {"questionId": 5, "optionId": "a"},
      {"questionId": 6, "optionId": "a"},
      {"questionId": 7, "optionId": "a"},
      {"questionId": 8, "optionId": "a"},
      {"questionId": 9, "optionId": "a"},
      {"questionId": 10, "optionId": "a"},
      {"questionId": 11, "optionId": "a"},
      {"questionId": 12, "optionId": "a"},
      {"questionId": 13, "optionId": "a"},
      {"questionId": 14, "optionId": "a"},
      {"questionId": 15, "optionId": "a"}
    ]
  }'
```

Expected response: 3 recommended majors with match percentages

## Using the Feature

1. **Open the app**: Navigate to http://localhost:5173
2. **Click "Major Test"** in the header navigation
3. **Answer 15 questions** about your preferences
4. **View results**: See your top 3 recommended majors
5. **Click university links** to explore programs

## Troubleshooting

### PostgreSQL Not Running
```bash
# Check if PostgreSQL is installed
psql --version

# Check if service is running (Windows)
Get-Service -Name "*postgres*"

# Start with Docker (if docker-compose.yml exists)
docker-compose up -d

# Or use the docker-compose.yml content
docker run -d \
  -e POSTGRES_DB=unifind \
  -e POSTGRES_USER=unifind \
  -e POSTGRES_PASSWORD=unifind \
  -p 5432:5432 \
  postgres:16
```

### CORS Errors
Check that:
- Backend `.env` has `CORS_ORIGIN=http://localhost:5173`
- Frontend is running on port 5173
- Both servers are running

### Empty Results
If test returns no recommendations:
```sql
-- Check if majors have tags
SELECT COUNT(*) FROM major WHERE array_length(tags, 1) > 0;

-- Re-run major seeding if needed
\i db/data/majors_seed.sql
```

### Port Already in Use
```bash
# Find process using port 3000
netstat -ano | findstr :3000  # Windows
lsof -i :3000                  # Linux/Mac

# Kill process or change port in .env
```

## Testing Different Profiles

### Analytical/Technical Profile
Answer "a" to most questions → Should recommend Computer Science, Mathematics, Engineering majors

### Creative/Arts Profile
Answer "b" to most questions → Should recommend Design, Arts, Architecture, Media majors

### Medical/Healthcare Profile
Answer "c" to questions 3, 7, 9, 13 → Should recommend Medicine, Nursing, Biochemistry majors

### Business/Management Profile
Answer "d" to most questions → Should recommend Business Administration, Economics, Management majors

## File Locations

### Backend
- Questions: `db/data/test_questions_seed.sql`
- Majors: `db/data/majors_seed.sql`
- API Routes: `services/test-service/src/routes.js`
- Seeding: `db/seed.js`

### Frontend
- Test UI: `src/pages/CareerTest.jsx`
- Results: `src/pages/TestResults.jsx`
- Navigation: `src/components/Header.jsx`
- Routes: `src/App.jsx`

## API Reference

### GET /api/test/questions
Returns all 15 test questions.

**Response:**
```json
{
  "questions": [
    {
      "id": 1,
      "position": 1,
      "text": "When facing a complex problem, you prefer to:",
      "options": [
        {
          "id": "a",
          "label": "Break it down logically and analyze each part systematically",
          "weights": {
            "analytical": 3,
            "technical": 2,
            "research": 2
          }
        }
      ]
    }
  ]
}
```

### POST /api/test/submit
Submits test answers and returns top 3 major recommendations.

**Request:**
```json
{
  "answers": [
    { "questionId": 1, "optionId": "a" },
    { "questionId": 2, "optionId": "b" }
  ]
}
```

**Response:**
```json
{
  "recommendedMajors": [
    {
      "majorId": 13,
      "majorName": "Computer Science",
      "universityId": 1,
      "universityName": "Charles University",
      "universityAbbreviation": "UK",
      "matchPercentage": 87,
      "explanation": "Strong match in analytical thinking, technical skills, computer science affinity.",
      "matchingTags": ["analytical", "technical", "computer_science"]
    }
  ]
}
```

## Next Steps After Setup

1. **Test all user flows**:
   - Take the test with different answer combinations
   - Verify university links work correctly
   - Test "Retake Test" functionality
   - Check mobile responsiveness

2. **Customize** (optional):
   - Adjust question weights in `test_questions_seed.sql`
   - Add more majors in `majors_seed.sql`
   - Modify styling in `styles.css`

3. **Deploy**:
   - Set production `JWT_SECRET` in `.env`
   - Configure production database
   - Update `CORS_ORIGIN` for production domain
   - Build frontend: `npm run build`

## Support

For issues or questions, refer to:
- Full implementation details: `CAREER_TEST_IMPLEMENTATION.md`
- Database schema: `db/migrations/001_init.sql`
- Backend README: `unifind-backend/README.md`

Last updated: 2026-11-17
