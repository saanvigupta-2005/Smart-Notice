import 'package:flutter_test/flutter_test.dart';
import 'package:smart_notice/services/notice_parser_service.dart';

void main() {
  group('Member 4 - Parser & Intelligence Tests', () {
    test('Task 1: Detects Notice Categories', () {
      expect(
        NoticeParserService.detectCategory('Mid semester end semester exam timetable and hall ticket release'),
        'Examination',
      );
      expect(
        NoticeParserService.detectCategory('Campus recruitment drive for TCS. Eligible students submit resume for interview round. CTC 7 LPA'),
        'Placement',
      );
      expect(
        NoticeParserService.detectCategory('Annual cultural fest and national level hackathon 2026. Register now for the workshop'),
        'Events',
      );
      expect(
        NoticeParserService.detectCategory('Submission of assignment 3 for lecture and revised syllabus'),
        'Academics',
      );
      expect(
        NoticeParserService.detectCategory('College will remain closed this Friday.'),
        'General',
      );
    });

    test('Task 2: Detects Deadlines from Text', () {
      final d1 = NoticeParserService.detectDeadline('Assignment submission deadline: 25/11/2026 for all students.');
      expect(d1, isNotNull);
      expect(d1!.day, 25);
      expect(d1.month, 11);
      expect(d1.year, 2026);

      final d2 = NoticeParserService.detectDeadline('Apply on or before 15-12-2026 to be considered.');
      expect(d2, isNotNull);
      expect(d2!.day, 15);
      expect(d2.month, 12);
      expect(d2.year, 2026);

      final d3 = NoticeParserService.detectDeadline('No deadline mentioned in this general circular.');
      expect(d3, isNull);
    });

    test('Task 3: Detects Target Departments', () {
      expect(
        NoticeParserService.detectDepartment('All CSE and Computer Science students must report to Lab 2.'),
        'Computer Science',
      );
      expect(
        NoticeParserService.detectDepartment('Notice for Information Technology students regarding project.'),
        'Information Technology',
      );
      expect(
        NoticeParserService.detectDepartment('Workshop arranged for ECE and Electronics students.'),
        'Electronics',
      );
      expect(
        NoticeParserService.detectDepartment('Industrial visit for Mechanical department students.'),
        'Mechanical',
      );
      expect(
        NoticeParserService.detectDepartment('Survey camp notice for Civil engineering students.'),
        'Civil',
      );
      expect(
        NoticeParserService.detectDepartment('All college students are requested to attend the flag hoisting.'),
        'All Departments',
      );
    });

    test('Task 4: Detects Academic Years', () {
      expect(
        NoticeParserService.detectAcademicYear('Notice for all 1st Year and FE students regarding orientation.'),
        '1st Year',
      );
      expect(
        NoticeParserService.detectAcademicYear('SE students 2nd year practical exam timetable.'),
        '2nd Year',
      );
      expect(
        NoticeParserService.detectAcademicYear('Mini project submission guidelines for 3rd Year and TE students.'),
        '3rd Year',
      );
      expect(
        NoticeParserService.detectAcademicYear('Placement drive strictly for 4th Year and Final Year students.'),
        '4th Year',
      );
      expect(
        NoticeParserService.detectAcademicYear('Library holiday circular for all college students.'),
        'All Years',
      );
    });
  });
}
