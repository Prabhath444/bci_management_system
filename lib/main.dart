import 'package:flutter/material.dart';

import 'repositories/course_repository.dart';
import 'repositories/employee_repository.dart';
import 'repositories/student_repository.dart';
import 'screens/home_shell.dart';
import 'state/bci_store.dart';

void main() {
  runApp(const BciManagementApp());
}

class BciManagementApp extends StatefulWidget {
  const BciManagementApp({super.key});

  @override
  State<BciManagementApp> createState() => _BciManagementAppState();
}

class _BciManagementAppState extends State<BciManagementApp> {
  // Composition root: concrete data sources are injected from outside the
  // high-level store (Dependency Inversion Principle).
  final BciStore _store = BciStore(
    studentRepository: InMemoryStudentRepository.withSampleData(),
    courseRepository: InMemoryCourseRepository.withSampleData(),
    employeeRepository: InMemoryEmployeeRepository.withSampleData(),
  );

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BCI Management System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF173B63)),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
        ),
      ),
      home: HomeShell(store: _store),
    );
  }
}
