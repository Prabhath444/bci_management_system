import '../models/student.dart';

/// Contains student form rules only (Single Responsibility Principle).
class StudentValidator {
  const StudentValidator();

  String? validateId(
    String value,
    Iterable<Student> students, {
    String? originalId,
  }) {
    final String? requiredError = required(value, 'Student ID');
    if (requiredError != null) {
      return requiredError;
    }

    final bool duplicate = students.any(
      (Student student) =>
          student.id.toLowerCase() == value.trim().toLowerCase() &&
          student.id != originalId,
    );
    return duplicate ? 'Student ID already exists.' : null;
  }

  String? validateName(String value) {
    final String? requiredError = required(value, 'Full Name');
    if (requiredError != null) {
      return requiredError;
    }
    return value.trim().length < 3 ? 'Enter at least 3 characters.' : null;
  }

  String? validateEmail(String value) {
    final String? requiredError = required(value, 'Email');
    if (requiredError != null) {
      return requiredError;
    }
    final String email = value.trim();
    return email.contains('@') && email.contains('.')
        ? null
        : 'Enter a valid email address.';
  }

  String? required(String value, String label) {
    return value.trim().isEmpty ? '$label is required.' : null;
  }
}
