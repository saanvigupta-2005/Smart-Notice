class NoticeParserService {
  /// Categories supported across the app
  static const List<String> categories = [
    'Examination',
    'Placement',
    'Events',
    'Academics',
    'General',
  ];

  /// Departments supported across the app
  static const List<String> departments = [
    'All Departments',
    'Computer Science',
    'Information Technology',
    'Electronics',
    'Mechanical',
    'Civil',
  ];

  /// Academic years supported across the app
  static const List<String> academicYears = [
    'All Years',
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  /// Comprehensive keyword dictionary with weighted relevance
  static const Map<String, List<String>> _categoryKeywords = {
    'Examination': [
      'exam',
      'examination',
      'timetable',
      'time-table',
      'hall ticket',
      'admit card',
      'result',
      'revaluation',
      'marksheet',
      'grade',
      'mid sem',
      'midsem',
      'end sem',
      'endsem',
      'semester end',
      'viva',
      'backlog',
      'kt exam',
      'practical exam',
      'internal assessment',
      'supplementary',
    ],
    'Placement': [
      'placement',
      'internship',
      'job offer',
      'recruitment',
      'campus drive',
      'interview',
      'package',
      'ctc',
      'stipend',
      'hr round',
      'aptitude test',
      'resume',
      'shortlisted',
      'hiring',
      'company visit',
      'pre-placement',
      'eligibility criteria',
    ],
    'Events': [
      'event',
      'fest',
      'cultural',
      'workshop',
      'seminar',
      'webinar',
      'conference',
      'hackathon',
      'competition',
      'guest lecture',
      'annual day',
      'sports meet',
      'celebration',
      'inauguration',
      'gathering',
      'symposium',
    ],
    'Academics': [
      'academic',
      'lecture',
      'class',
      'syllabus',
      'curriculum',
      'assignment',
      'submission',
      'attendance',
      'timetable',
      'schedule',
      'holiday',
      'vacation',
      'lab manual',
      'practical session',
      'semester',
      'faculty',
      'coursework',
    ],
  };

  /// 1. Detects notice category by analyzing keyword frequencies and relevance
  static String detectCategory(String text) {
    if (text.trim().isEmpty) return 'General';

    final normalized = text.toLowerCase();
    final Map<String, int> scores = {
      'Examination': 0,
      'Placement': 0,
      'Events': 0,
      'Academics': 0,
    };

    for (final entry in _categoryKeywords.entries) {
      final category = entry.key;
      final keywords = entry.value;

      for (final keyword in keywords) {
        if (normalized.contains(keyword)) {
          scores[category] =
              (scores[category] ?? 0) + (keyword.contains(' ') ? 2 : 1);
        }
      }
    }

    String topCategory = 'General';
    int maxScore = 0;

    for (final entry in scores.entries) {
      if (entry.value > maxScore) {
        maxScore = entry.value;
        topCategory = entry.key;
      }
    }

    return topCategory;
  }

  /// 2. Detects deadline date from notice text
  static DateTime? detectDeadline(String text) {
    if (text.trim().isEmpty) return null;

    final lower = text.toLowerCase();

    // Context patterns: prioritize dates near deadline keywords
    final contextPatterns = [
      r'(?:last\s+date|deadline|due\s+date|submission\s+(?:date|by|before)|on\s+or\s+before|apply\s+by|before|till|upto)[\s\:\-\=]*([0-9]{1,2}[\/\-\.][0-9]{1,2}[\/\-\.][0-9]{2,4})',
      r'(?:last\s+date|deadline|due\s+date|submission\s+(?:date|by|before)|on\s+or\s+before|apply\s+by|before|till|upto)[\s\:\-\=]*([0-9]{1,2}(?:st|nd|rd|th)?\s+(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*(?:\s+[0-9]{4})?)',
    ];

    for (final pattern in contextPatterns) {
      final match = RegExp(pattern, caseSensitive: false).firstMatch(lower);
      if (match != null && match.groupCount >= 1) {
        final parsed = _parseDateString(match.group(1)!);
        if (parsed != null) return parsed;
      }
    }

    // General date regex: DD/MM/YYYY or DD-MM-YYYY
    final numericDateRegex = RegExp(
      r'\b([0-3]?[0-9])[\/\-\.]([0-1]?[0-9])[\/\-\.](20[2-3][0-9]|[2-3][0-9])\b',
    );
    final numericMatch = numericDateRegex.firstMatch(text);
    if (numericMatch != null) {
      final parsed = _parseDateString(numericMatch.group(0)!);
      if (parsed != null) return parsed;
    }

    // Word month regex: 15th August 2026, 12 March, etc.
    final wordMonthRegex = RegExp(
      r'\b([0-3]?[0-9])(?:st|nd|rd|th)?\s+(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)(?:\s+(20[2-3][0-9]))?\b',
      caseSensitive: false,
    );
    final wordMatch = wordMonthRegex.firstMatch(text);
    if (wordMatch != null) {
      final parsed = _parseDateString(wordMatch.group(0)!);
      if (parsed != null) return parsed;
    }

    return null;
  }

  /// 3. Detects target department from notice text
  static String detectDepartment(String text) {
    if (text.trim().isEmpty) return 'All Departments';

    final lower = text.toLowerCase();

    // Computer Science
    if (RegExp(r'\b(cse|cs|computer\s+science|computer\s+engineering|software\s+engineering)\b', caseSensitive: false).hasMatch(lower)) {
      return 'Computer Science';
    }

    // Information Technology
    if (RegExp(r'\b(it\s+department|information\s+technology)\b', caseSensitive: false).hasMatch(lower) ||
        RegExp(r'\bIT\b').hasMatch(text)) {
      return 'Information Technology';
    }

    // Electronics
    if (RegExp(r'\b(ece|etc|entc|extc|electronics|electrical|ee\s+dept)\b', caseSensitive: false).hasMatch(lower)) {
      return 'Electronics';
    }

    // Mechanical
    if (RegExp(r'\b(mechanical|mech|automobile)\b', caseSensitive: false).hasMatch(lower)) {
      return 'Mechanical';
    }

    // Civil
    if (RegExp(r'\b(civil|civil\s+engineering|construction)\b', caseSensitive: false).hasMatch(lower)) {
      return 'Civil';
    }

    return 'All Departments';
  }

  /// 4. Detects target academic year from notice text
  static String detectAcademicYear(String text) {
    if (text.trim().isEmpty) return 'All Years';

    final lower = text.toLowerCase();

    // 1st Year
    if (RegExp(r'\b(1st\s+year|first\s+year|\bfe\b|1st\s+sem|first\s+sem|2nd\s+sem|second\s+sem|freshers?)\b', caseSensitive: false).hasMatch(lower)) {
      return '1st Year';
    }

    // 2nd Year
    if (RegExp(r'\b(2nd\s+year|second\s+year|\bse\b|3rd\s+sem|third\s+sem|4th\s+sem|fourth\s+sem|sophomore)\b', caseSensitive: false).hasMatch(lower)) {
      return '2nd Year';
    }

    // 3rd Year
    if (RegExp(r'\b(3rd\s+year|third\s+year|\bte\b|5th\s+sem|fifth\s+sem|6th\s+sem|sixth\s+sem|pre-?final)\b', caseSensitive: false).hasMatch(lower)) {
      return '3rd Year';
    }

    // 4th Year
    if (RegExp(r'\b(4th\s+year|fourth\s+year|final\s+year|\bbe\b|7th\s+sem|seventh\s+sem|8th\s+sem|eighth\s+sem|graduating)\b', caseSensitive: false).hasMatch(lower)) {
      return '4th Year';
    }

    return 'All Years';
  }

  /// Helper to parse flexible date formats
  static DateTime? _parseDateString(String raw) {
    try {
      final clean = raw.trim().toLowerCase();

      // Formats: DD/MM/YYYY or DD-MM-YYYY or DD.MM.YYYY
      final parts = clean.split(RegExp(r'[\/\-\.]'));
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        if (year < 100) year += 2000;
        if (day > 0 && day <= 31 && month > 0 && month <= 12) {
          return DateTime(year, month, day);
        }
      }

      // Format: 15th August 2026 or 15 Aug
      final monthMap = {
        'jan': 1, 'january': 1,
        'feb': 2, 'february': 2,
        'mar': 3, 'march': 3,
        'apr': 4, 'april': 4,
        'may': 5,
        'jun': 6, 'june': 6,
        'jul': 7, 'july': 7,
        'aug': 8, 'august': 8,
        'sep': 9, 'september': 9,
        'oct': 10, 'october': 10,
        'nov': 11, 'november': 11,
        'dec': 12, 'december': 12,
      };

      final wordParts = clean.replaceAll(RegExp(r'(st|nd|rd|th)'), '').split(RegExp(r'\s+'));
      if (wordParts.isNotEmpty) {
        int? day = int.tryParse(wordParts[0]);
        int? month;
        int year = DateTime.now().year;

        for (int i = 1; i < wordParts.length; i++) {
          final part = wordParts[i];
          if (monthMap.containsKey(part)) {
            month = monthMap[part];
          } else if (int.tryParse(part) != null && part.length == 4) {
            year = int.parse(part);
          }
        }

        if (day != null && month != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (_) {}

    return null;
  }
}
