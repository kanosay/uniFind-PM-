import { Router } from 'express';
import { badRequest, notFound } from '@unifind/shared/errors';
import { query } from '@unifind/shared/db';

export const router = Router();

/**
 * GET /test/questions
 * Returns all 15 test questions with their options and weights.
 */
router.get('/questions', async (_req, res) => {
  const { rows } = await query(
    `SELECT id, position, text, options
     FROM test_question
     ORDER BY position`
  );
  res.json({ questions: rows });
});

/**
 * POST /test/submit
 * Body: { answers: [{ questionId: number, optionId: string }] }
 * Returns: { recommendedMajors: [{ majorId, majorName, universityId, universityName, universityAbbreviation, matchPercentage, explanation }] }
 */
router.post('/submit', async (req, res) => {
  const { answers } = req.body;

  if (!Array.isArray(answers) || answers.length === 0) {
    throw badRequest('answers must be a non-empty array');
  }

  // Fetch all questions with their options to validate answers and calculate weights
  const { rows: questions } = await query(
    `SELECT id, options FROM test_question ORDER BY position`
  );

  if (questions.length === 0) {
    throw notFound('Test questions not found');
  }

  // Build a map for quick lookup
  const questionMap = new Map(questions.map(q => [q.id, q]));

  // Accumulate scores per major tag
  const tagScores = new Map(); // tag -> score

  for (const answer of answers) {
    const { questionId, optionId } = answer;
    const question = questionMap.get(Number(questionId));

    if (!question) {
      throw badRequest(`Question ${questionId} not found`);
    }

    const option = question.options.find(opt => opt.id === optionId);
    if (!option) {
      throw badRequest(`Option ${optionId} not found for question ${questionId}`);
    }

    // Add weights to tag scores
    for (const [tag, weight] of Object.entries(option.weights || {})) {
      tagScores.set(tag, (tagScores.get(tag) || 0) + weight);
    }
  }

  // Convert to sorted array of tags by score
  const sortedTags = Array.from(tagScores.entries())
    .sort((a, b) => b[1] - a[1])
    .map(([tag]) => tag);

  if (sortedTags.length === 0) {
    return res.json({ recommendedMajors: [] });
  }

  // Find majors that match the top tags
  // We'll search for majors where tags array overlaps with user's top tags
  const topTags = sortedTags.slice(0, 8); // Use top 8 tags for matching

  const placeholders = topTags.map((_, i) => `$${i + 1}`).join(',');
  const { rows: majors } = await query(
    `SELECT m.id AS "majorId", m.name AS "majorName", m.tags, m.university_id AS "universityId",
            u.name AS "universityName", u.abbreviation AS "universityAbbreviation"
     FROM major m
     JOIN university u ON u.id = m.university_id
     WHERE m.tags && $1::text[]
     ORDER BY (SELECT COUNT(*) FROM unnest(m.tags) AS t(tag) WHERE t.tag = ANY($1::text[])) DESC,
              m.name
     LIMIT 20`,
    [topTags]
  );


  // Calculate match percentage for each major
  const totalUserScore = Array.from(tagScores.values()).reduce((a, b) => a + b, 0);

  const recommendedMajors = majors.map(major => {
    // Calculate overlap score
    let overlapScore = 0;
    for (const tag of major.tags) {
      if (tagScores.has(tag)) {
        overlapScore += tagScores.get(tag);
      }
    }
    const matchPercentage = totalUserScore > 0
      ? Math.round((overlapScore / totalUserScore) * 100)
      : 0;

    // Generate explanation based on matching tags
    const matchingTags = major.tags.filter(tag => tagScores.has(tag));
    const topMatchingTags = matchingTags
      .sort((a, b) => (tagScores.get(b) || 0) - (tagScores.get(a) || 0))
      .slice(0, 3);

    const tagLabels = {
      analytical: 'analytical thinking',
      technical: 'technical skills',
      research: 'research orientation',
      creative: 'creative thinking',
      design: 'design sensibility',
      innovation: 'innovation drive',
      collaborative: 'teamwork',
      communication: 'communication skills',
      management: 'management potential',
      practical: 'practical problem-solving',
      engineering: 'engineering mindset',
      business: 'business acumen',
      humanities: 'humanities interest',
      arts: 'artistic expression',
      medical: 'healthcare calling',
      science: 'scientific curiosity',
      leadership: 'leadership qualities',
      law: 'legal reasoning',
      journalism: 'journalistic instinct',
      entrepreneurship: 'entrepreneurial spirit',
      teaching: 'teaching aptitude',
      social: 'social impact focus',
      international: 'global perspective',
      architecture: 'architectural vision',
      computer_science: 'computer science affinity',
      mathematics: 'mathematical rigor',
      economics: 'economic understanding',
      media: 'media literacy'
    };

    const explanationParts = topMatchingTags.map(tag => tagLabels[tag] || tag);
    const explanation = explanationParts.length > 0
      ? `Strong match in ${explanationParts.join(', ')}.`
      : 'Good overall alignment with your profile.';

    return {
      majorId: major.majorId,
      majorName: major.majorName,
      universityId: major.universityId,
      universityName: major.universityName,
      universityAbbreviation: major.universityAbbreviation,
      matchPercentage,
      explanation,
      matchingTags: topMatchingTags
    };
  });

  // Sort by match percentage and take top 3
  recommendedMajors.sort((a, b) => b.matchPercentage - a.matchPercentage);
  const top3 = recommendedMajors.slice(0, 3);

  res.json({ recommendedMajors: top3 });
});