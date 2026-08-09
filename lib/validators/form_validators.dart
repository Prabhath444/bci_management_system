class FormValidators {
  const FormValidators._();

  static String? required(String value, String label) {
    return value.trim().isEmpty ? '$label is required.' : null;
  }

  static String? email(String value, String label) {
    final String? requiredError = required(value, label);
    if (requiredError != null) {
      return requiredError;
    }
    final String email = value.trim();
    return email.contains('@') && email.contains('.')
        ? null
        : 'Enter a valid email address.';
  }

  static String? number(String value, String label) {
    final String? requiredError = required(value, label);
    if (requiredError != null) {
      return requiredError;
    }
    return double.tryParse(value.trim()) == null
        ? 'Enter a valid numerical amount.'
        : null;
  }
}
