#!/bin/bash
# Career Test Feature - Setup and Verification Script

echo "=================================================="
echo "UniFind Career Test - Setup & Verification"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: Must be run from unifind-backend directory${NC}"
    exit 1
fi

echo "Step 1: Checking PostgreSQL connection..."
echo "----------------------------------------"
if psql -h localhost -U unifind -d unifind -c "SELECT version();" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PostgreSQL is running and accessible${NC}"
else
    echo -e "${RED}✗ Cannot connect to PostgreSQL${NC}"
    echo ""
    echo "Please ensure PostgreSQL is running with:"
    echo "  - Host: localhost:5432"
    echo "  - Database: unifind"
    echo "  - User: unifind"
    echo "  - Password: unifind"
    echo ""
    echo "You can check docker-compose.yml or start PostgreSQL manually."
    exit 1
fi

echo ""
echo "Step 2: Installing dependencies..."
echo "----------------------------------------"
npm install
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to install dependencies${NC}"
    exit 1
fi

echo ""
echo "Step 3: Running database migrations..."
echo "----------------------------------------"
npm run db:migrate
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Migrations completed${NC}"
else
    echo -e "${RED}✗ Migrations failed${NC}"
    exit 1
fi

echo ""
echo "Step 4: Seeding database (universities, questions, majors)..."
echo "----------------------------------------"
npm run db:seed
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database seeded successfully${NC}"
else
    echo -e "${RED}✗ Seeding failed${NC}"
    exit 1
fi

echo ""
echo "Step 5: Verifying test data..."
echo "----------------------------------------"

# Check test questions
QUESTION_COUNT=$(psql -h localhost -U unifind -d unifind -t -c "SELECT COUNT(*) FROM test_question;" 2>/dev/null | tr -d ' ')
if [ "$QUESTION_COUNT" -eq 15 ]; then
    echo -e "${GREEN}✓ Test questions: $QUESTION_COUNT/15${NC}"
else
    echo -e "${YELLOW}⚠ Test questions: $QUESTION_COUNT/15 (expected 15)${NC}"
fi

# Check majors
MAJOR_COUNT=$(psql -h localhost -U unifind -d unifind -t -c "SELECT COUNT(*) FROM major;" 2>/dev/null | tr -d ' ')
if [ "$MAJOR_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Majors with tags: $MAJOR_COUNT${NC}"
else
    echo -e "${YELLOW}⚠ Majors: $MAJOR_COUNT${NC}"
fi

# Check universities
UNI_COUNT=$(psql -h localhost -U unifind -d unifind -t -c "SELECT COUNT(*) FROM university;" 2>/dev/null | tr -d ' ')
if [ "$UNI_COUNT" -eq 24 ]; then
    echo -e "${GREEN}✓ Prague universities: $UNI_COUNT/24${NC}"
else
    echo -e "${YELLOW}⚠ Universities: $UNI_COUNT/24${NC}"
fi

echo ""
echo "Step 6: Testing API endpoints..."
echo "----------------------------------------"
echo "Starting backend services in background..."

# Start backend in background
npm start > backend.log 2>&1 &
BACKEND_PID=$!

# Wait for services to start
echo "Waiting for services to initialize (10 seconds)..."
sleep 10

# Test health endpoint
echo -n "Testing gateway health... "
HEALTH_RESPONSE=$(curl -s http://localhost:3000/api/health)
if echo "$HEALTH_RESPONSE" | grep -q '"gateway":"ok"'; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Response: $HEALTH_RESPONSE"
fi

# Test questions endpoint
echo -n "Testing GET /api/test/questions... "
QUESTIONS_RESPONSE=$(curl -s http://localhost:3000/api/test/questions)
if echo "$QUESTIONS_RESPONSE" | grep -q '"questions"'; then
    FETCHED_QUESTIONS=$(echo "$QUESTIONS_RESPONSE" | grep -o '"position"' | wc -l)
    echo -e "${GREEN}✓ ($FETCHED_QUESTIONS questions)${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Response: $QUESTIONS_RESPONSE"
fi

# Test submit endpoint with sample data
echo -n "Testing POST /api/test/submit... "
SUBMIT_RESPONSE=$(curl -s -X POST http://localhost:3000/api/test/submit \
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
  }')

if echo "$SUBMIT_RESPONSE" | grep -q '"recommendedMajors"'; then
    RECOMMENDED_COUNT=$(echo "$SUBMIT_RESPONSE" | grep -o '"majorId"' | wc -l)
    echo -e "${GREEN}✓ (returned $RECOMMENDED_COUNT recommendations)${NC}"

    # Show sample recommendation
    echo ""
    echo "Sample recommendation:"
    echo "$SUBMIT_RESPONSE" | python3 -m json.tool 2>/dev/null | head -20 || echo "$SUBMIT_RESPONSE"
else
    echo -e "${RED}✗${NC}"
    echo "Response: $SUBMIT_RESPONSE"
fi

# Stop backend
echo ""
echo "Stopping backend services..."
kill $BACKEND_PID 2>/dev/null
sleep 2

echo ""
echo "=================================================="
echo "Setup Complete!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Start backend: npm start"
echo "2. Start frontend: cd ../uni/unifind-frontend\ 3 && npm run dev"
echo "3. Open browser: http://localhost:5173"
echo "4. Click 'Major Test' in the navigation"
echo ""
echo "API Endpoints:"
echo "  GET  http://localhost:3000/api/test/questions"
echo "  POST http://localhost:3000/api/test/submit"
echo ""
echo "Database contains:"
echo "  - $UNI_COUNT universities"
echo "  - $MAJOR_COUNT majors with career tags"
echo "  - $QUESTION_COUNT test questions"
echo ""
