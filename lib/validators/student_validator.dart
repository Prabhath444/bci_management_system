import '../models/student.dart';
import 'form_validators.dart';

/// Contains student form rules only (Single Responsibility Principle).
class StudentValidator {
  const StudentValidator();

  String? validateId(
    String value,
    Iterable<Student> students, {
    String? originalId,
  }) {
    final String? requiredError = FormValidators.required(value, 'Student ID');
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
    final String? requiredError = FormValidators.required(value, 'Full Name');
    if (requiredError != null) {
      return requiredError;
    }
    return value.trim().length < 3 ? 'Enter at least 3 characters.' : null;
  }

  String? validateEmail(String value) {
    return FormValidators.email(value, 'Email');
  }
}
