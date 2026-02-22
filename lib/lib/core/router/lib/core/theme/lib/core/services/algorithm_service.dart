import 'dart:math';
import '../../domain/entities/word_entity.dart';

class AlgorithmService {
  static const double kMasteryUpThreshold = 85.0;
  static const double kMasteryDownThreshold = 50.0;
  static const int kDailySessionSize = 20;
  static const double kWeightSuccessRate = 0.40;
  static const double kWeightResponseTime = 0.20;
  static const double kWeightRepetition = 0.20;
  static const double kWeightSpacing = 0.20;
  static const double kIdealResponseTime = 3.0;
  static const double kMaxResponseTime = 15.0;

  WordEntity processAnswer({
    required WordEntity word,
    required bool isCorrect,
    required double responseTimeSeconds,
  }) {
    final now = DateTime.now();
    final newTimesSeen = word.timesSeen + 1;
    final newTimesCorrect = word.timesCorrect + (isCorrect ? 1 : 0);
    final newTimesWrong = word.timesWrong + (isCorrect ? 0 : 1);
    final newAvgResponseTime = word.timesSeen == 0
        ? responseTimeSeconds
        : (word.responseTimeAverage * 0.7) + (responseTimeSeconds * 0.3);
    final newSuccessRate = newTimesSeen > 0 ? newTimesCorrect / newTimesSeen : 0.0;
    final newMastery = _calculateMasteryScore(
      successRate: newSuccessRate,
      responseTime: newAvgResponseTime,
      timesSeen: newTimesSeen,
      difficultyLevel: word.difficultyLevel,
      lastReviewed: word.lastReviewed,
      now: now,
      isCurrentAnswerCorrect: isCorrect,
    );
    final newStudyLevel = _calculateStudyLevel(
      currentLevel: word.studyLevel,
      masteryScore: newMastery,
    );
    final nextReview = _calculateNextReviewDate(
      masteryScore: newMastery,
      studyLevel: newStudyLevel,
      isCorrect: isCorrect,
      now: now,
    );
    return word.copyWith(
      timesSeen: newTimesSeen,
      timesCorrect: newTimesCorrect,
      timesWrong: newTimesWrong,
      responseTimeAverage: newAvgResponseTime,
      successRate: newSuccessRate,
      masteryScore: newMastery,
      studyLevel: newStudyLevel,
      lastReviewed: now,
      nextReviewDate: nextReview,
    );
  }

  double _calculateMasteryScore({
    required double successRate,
    required double responseTime,
    required int timesSeen,
    required int difficultyLevel,
    required DateTime? lastReviewed,
    required DateTime now,
    required bool isCurrentAnswerCorrect,
  }) {
    double successComponent = successRate * 100.0;
    double responseScore;
    if (responseTime <= kIdealResponseTime) {
      responseScore = 100.0;
    } else if (responseTime >= kMaxResponseTime) {
      responseScore = 0.0;
    } else {
      responseScore = 100.0 * (1 - (responseTime - kIdealResponseTime) /
          (kMaxResponseTime - kIdealResponseTime));
    }
    double repetitionComponent = min(100.0, (timesSeen / 5.0) * 100.0);
    double spacingComponent = 50.0;
    if (lastReviewed != null && isCurrentAnswerCorrect) {
      final daysSinceLastReview = now.difference(lastReviewed).inHours / 24.0;
      if (daysSinceLastReview >= 1 && daysSinceLastReview <= 7) {
        spacingComponent = 80.0 + (daysSinceLastReview / 7.0) * 20.0;
      } else if (daysSinceLastReview > 7) {
        spacingComponent = 100.0;
      } else {
        spacingComponent = 40.0;
      }
    } else if (!isCurrentAnswerCorrect) {
      spacingComponent = 0.0;
    }
    double rawScore = (successComponent * kWeightSuccessRate) +
        (responseScore * kWeightResponseTime) +
        (repetitionComponent * kWeightRepetition) +
        (spacingComponent * kWeightSpacing);
    double difficultyPenalty = (difficultyLevel - 1) * 2.0;
    rawScore = max(0.0, rawScore - difficultyPenalty);
    if (!isCurrentAnswerCorrect) rawScore *= 0.7;
    return rawScore.clamp(0.0, 100.0);
  }

  int _calculateStudyLevel({
    required int currentLevel,
    required double masteryScore,
  }) {
    if (masteryScore > kMasteryUpThreshold && currentLevel < 5) return currentLevel + 1;
    if (masteryScore < kMasteryDownThreshold && c
