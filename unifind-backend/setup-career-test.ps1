# Career Test Feature - Setup and Verification Script (Windows PowerShell)

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "UniFind Career Test - Setup & Verification" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "package.json")) {
    Write-Host "Error: Must be run from unifind-backend directory" -ForegroundColor Red
    exit 1
}

Write-Host "Step 1: Checking PostgreSQL connection..." -ForegroundColor Yellow
Write-Host "----------------------------------------"
$env:PGPASSWORD = "unifind"
$pgTest = & psql -h localhost -U unifind -d unifind -c "SELECT version();" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PostgreSQL is running and accessible" -ForegroundColor Green
} else {
    Write-Host "✗ Cannot connect to PostgreSQL" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please ensure PostgreSQL is running with:"
    Write-Host "  - Host: localhost:5432"
    Write-Host "  - Database: unifind"
    Write-Host "  - User: unifind"
    Write-Host "  - Password: unifind"
    Write-Host ""
    Write-Host "You can start it with: docker-compose up -d"
    Write-Host "Or check if docker-compose.yml exists in this directory"
    exit 1
}

Write-Host ""
Write-Host "Step 2: Installing dependencies..." -ForegroundColor Yellow
Write-Host "----------------------------------------"
npm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "✗ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 3: Running database migrations..." -ForegroundColor Yellow
Write-Host "----------------------------------------"
npm run db:migrate
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Migrations completed" -ForegroundColor Green
} else {
    Write-Host "✗ Migrations failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 4: Seeding database (universities, questions, majors)..." -ForegroundColor Yellow
Write-Host "----------------------------------------"
npm run db:seed
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Database seeded successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Seeding failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 5: Verifying test data..." -ForegroundColor Yellow
Write-Host "----------------------------------------"

# Check test questions
$questionCount = & psql -h localhost -U unifind -d unifind -t -c "SELECT COUNT(*) FROM test_question;" 2>$null
$questionCount = $questionCount.Trim()
if ($questionCount -eq 15) {
    Write-Host "✓ Test questions: $questionCount/15" -ForegroundColor Green
} else {
    Write-Host "⚠ Test questions: $questionCount/15 (expected 15)" -ForegroundColor Yellow
}

# Check majors
$majorCount = & psql -h localhost -U unifind -d unifind -t -c "SELECT COUNT(*) FROM major;" 2>$null
$majorCount = $majorCount.Trim()
if ([int]$majorCount -gt 0) {
    Write-Host "✓ Majors with tags: $majorCount" -ForegroundColor Green
} else {
    Write-Host "⚠ Majors: $majorCount" -ForegroundColor Yellow
}

# Check universities
$uniCount = & psql -h localhost -U unifind -d unifind -t -c "SELECT COUNT(*) FROM university;" 2>$null
$uniCount = $uniCount.Trim()
if ($uniCount -eq 24) {
    Write-Host "✓ Prague universities: $uniCount/24" -ForegroundColor Green
} else {
    Write-Host "⚠ Universities: $uniCount/24" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Step 6: Testing API endpoints..." -ForegroundColor Yellow
Write-Host "----------------------------------------"
Write-Host "Starting backend services in background..."

# Start backend in background
$backendProcess = Start-Process -FilePath "npm" -ArgumentList "start" -PassThru -NoNewWindow -RedirectStandardOutput "backend.log" -RedirectStandardError "backend-error.log"

# Wait for services to start
Write-Host "Waiting for services to initialize (15 seconds)..."
Start-Sleep -Seconds 15

try {
    # Test health endpoint
    Write-Host -NoNewline "Testing gateway health... "
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/health" -Method Get -ErrorAction Stop
    if ($healthResponse.gateway -eq "ok") {
        Write-Host "✓" -ForegroundColor Green
    } else {
        Write-Host "✗" -ForegroundColor Red
        Write-Host "Response: $($healthResponse | ConvertTo-Json)"
    }

    # Test questions endpoint
    Write-Host -NoNewline "Testing GET /api/test/questions... "
    $questionsResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/test/questions" -Method Get -ErrorAction Stop
    if ($questionsResponse.questions) {
        $fetchedQuestions = $questionsResponse.questions.Count
        Write-Host "✓ ($fetchedQuestions questions)" -ForegroundColor Green
    } else {
        Write-Host "✗" -ForegroundColor Red
    }

    # Test submit endpoint with sample data
    Write-Host -NoNewline "Testing POST /api/test/submit... "
    $sampleAnswers = @{
        answers = @(
            @{questionId = 1; optionId = "a"},
            @{questionId = 2; optionId = "a"},
            @{questionId = 3; optionId = "a"},
            @{questionId = 4; optionId = "a"},
            @{questionId = 5; optionId = "a"},
            @{questionId = 6; optionId = "a"},
            @{questionId = 7; optionId = "a"},
            @{questionId = 8; optionId = "a"},
            @{questionId = 9; optionId = "a"},
            @{questionId = 10; optionId = "a"},
            @{questionId = 11; optionId = "a"},
            @{questionId = 12; optionId = "a"},
            @{questionId = 13; optionId = "a"},
            @{questionId = 14; optionId = "a"},
            @{questionId = 15; optionId = "a"}
        )
    }

    $submitResponse = Invoke-RestMethod -Uri "http://localhost:3000/api/test/submit" -Method Post -Body ($sampleAnswers | ConvertTo-Json -Depth 10) -ContentType "application/json" -ErrorAction Stop

    if ($submitResponse.recommendedMajors) {
        $recommendedCount = $submitResponse.recommendedMajors.Count
        Write-Host "✓ (returned $recommendedCount recommendations)" -ForegroundColor Green

        # Show sample recommendation
        Write-Host ""
        Write-Host "Sample recommendation:"
        Write-Host ($submitResponse.recommendedMajors[0] | ConvertTo-Json)
    } else {
        Write-Host "✗" -ForegroundColor Red
    }
} catch {
    Write-Host "Error testing endpoints: $_" -ForegroundColor Red
} finally {
    # Stop backend
    Write-Host ""
    Write-Host "Stopping backend services..."
    Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Start backend: npm start"
Write-Host "2. Start frontend: cd ..\uni\`"unifind-frontend 3`" ; npm run dev"
Write-Host "3. Open browser: http://localhost:5173"
Write-Host "4. Click 'Major Test' in the navigation"
Write-Host ""
Write-Host "API Endpoints:" -ForegroundColor Yellow
Write-Host "  GET  http://localhost:3000/api/test/questions"
Write-Host "  POST http://localhost:3000/api/test/submit"
Write-Host ""
Write-Host "Database contains:" -ForegroundColor Yellow
Write-Host "  - $uniCount universities"
Write-Host "  - $majorCount majors with career tags"
Write-Host "  - $questionCount test questions"
Write-Host ""
