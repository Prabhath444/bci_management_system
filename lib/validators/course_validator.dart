import '../models/course.dart';
import 'form_validators.dart';

/// Contains course form rules only (Single Responsibility Principle).
class CourseValidator {
  const CourseValidator();

  String? validateId(
    String value,
    Iterable<Course> courses, {
    String? originalId,
  }) {
    final String? requiredError = FormValidators.required(value, 'Course Code');
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
}
