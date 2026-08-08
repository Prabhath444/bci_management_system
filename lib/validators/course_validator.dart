import '../models/course.dart';

/// Contains course form rules only (Single Responsibility Principle).
class CourseValidator {
  const CourseValidator();

  String? validateId(
    String value,
    Iterable<Course> courses, {
    String? originalId,
  }) {
    final String? requiredError = required(value, 'Course Code');
    if (requiredError != null) {
      return requiredError;
    }

    final bool duplicate = courses.any(
      (Course course) =>
          course.id.toLowerCase() == value.trim().toLowerCase() &&
          course.id != originalId,
    );
    return duplicate ? 'Course code already exists.' : null;
  }

  String? required(String value, String label) {
    return value.trim().isEmpty ? '$label is required.' : null;
  }
}
