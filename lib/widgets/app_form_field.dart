import 'package:flutter/material.dart';

import '../validators/form_validators.dart';

class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  factory AppFormField.number({
    Key? key,
    required TextEditingController controller,
    required String label,
  }) {
    return AppFormField(
      key: key,
      controller: controller,
      label: label,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (String value) => FormValidators.number(value, label),
    );
  }

  final TextEditingController controller;
  final String label;
  final String? Function(String value)? validator;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (String? value) {
          final String text = value ?? '';
          return validator?.call(text) ?? FormValidators.required(text, label);
        },
      ),
    );
  }
}
