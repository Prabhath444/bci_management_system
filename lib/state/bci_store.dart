import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../models/employee.dart';
import '../models/student.dart';

class BciStore extends ChangeNotifier {
  final List<Student> _students = <Student>[
    const Student(
      id: 'BCI-2026-001',
      name: 'Ayesha Perera',
      email: 'ayesha@students.bci.lk',
      program: 'BSc Software Engineering',
      intake: 'February 2026',
      status: 'Active',
      courseIds: <String>['SE101', 'DB201'],
    ),
    const Student(
      id: 'BCI-2026-002',
      name: 'Nimal Fernando',
      email: 'nimal@students.bci.lk',
      program: 'BSc Information Technology',
      intake: 'February 2026',
      status: 'Active',
      courseIds: <String>['IT101'],
    ),
    const Student(
      id: 'BCI-2025-118',
      name: 'Tharushi Silva',
      email: 'tharushi@students.bci.lk',
      program: 'BSc Computer Science',
      intake: 'September 2025',
      status: 'Active',
      courseIds: <String>['SE101'],
    ),
  ];

  final List<Course> _courses = <Course>[
    const Course(
      id: 'SE101',
      name: 'Introduction to Software Engineering',
      duration: '12 weeks',
      description: 'Software development principles and team practices.',
    ),
    const Course(
      id: 'IT101',
      name: 'Information Technology Fundamentals',
      duration: '12 weeks',
      description: 'Core concepts in computer systems, networks and IT.',
    ),
    const Course(
      id: 'DB201',
      name: 'Database Management Systems',
      duration: '10 weeks',
      description: 'Relational database design, SQL and data management.',
    ),
  ];

  final List<Employee> _employees = <Employee>[
    const Employee(
      id: 'EMP-001',
      name: 'Dr. Amal Jayasinghe',
      department: 'School of Computing',
      designation: 'Senior Lecturer',
      basicSalary: 185000,
      allowances: 35000,
      overtime: 12000,
      deductions: 8500,
      tax: 17500,
    ),
    const Employee(
      id: 'EMP-002',
      name: 'Rashmi Perera',
      department: 'Finance',
      designation: 'Finance Officer',
      basicSalary: 125000,
      allowances: 22000,
      overtime: 6500,
      deductions: 5000,
      tax: 9500,
    ),
    const Employee(
      id: 'EMP-003',
      name: 'Kamal Fernando',
      department: 'Administration',
      designation: 'Management Assistant',
      basicSalary: 95000,
      allowances: 18000,
      overtime: 8000,
      deductions: 3500,
      tax: 4200,
    ),
  ];

  List<Student> get students => List<Student>.unmodifiable(_students);
  List<Course> get courses => List<Course>.unmodifiable(_courses);
  List<Employee> get employees => List<Employee>.unmodifiable(_employees);

  int get activeStudentCount =>
      _students.where((Student student) => student.status == 'Active').length;

  double get monthlyPayrollTotal => _employees.fold<double>(
        0,
        (double sum, Employee employee) => sum + employee.netSalary,
      );

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void updateStudent(String originalId, Student student) {
    final int index = _students.indexWhere(
      (Student current) => current.id == originalId,
    );
    if (index == -1) {
      return;
    }
    _students[index] = student;
    notifyListeners();
  }

  void removeStudent(String studentId) {
    _students.removeWhere((Student student) => student.id == studentId);
    notifyListeners();
  }

  void setStudentCourses(String studentId, List<String> courseIds) {
    final int index = _students.indexWhere(
      (Student student) => student.id == studentId,
    );
    if (index == -1) {
      return;
    }
    _students[index] = _students[index].copyWith(
      courseIds: List<String>.unmodifiable(courseIds),
    );
    notifyListeners();
  }

  void addCourse(Course course) {
    _courses.add(course);
    notifyListeners();
  }

  void updateCourse(String originalId, Course course) {
    final int index = _courses.indexWhere(
      (Course current) => current.id == originalId,
    );
    if (index == -1) {
      return;
    }

    _courses[index] = course;
    if (originalId != course.id) {
      for (int i = 0; i < _students.length; i++) {
        final Student student = _students[i];
        if (student.courseIds.contains(originalId)) {
          _students[i] = student.copyWith(
            courseIds: student.courseIds
                .map((String id) => id == originalId ? course.id : id)
                .toList(),
          );
        }
      }
    }
    notifyListeners();
  }

  void removeCourse(String courseId) {
    _courses.removeWhere((Course course) => course.id == courseId);
    for (int i = 0; i < _students.length; i++) {
      final Student student = _students[i];
      if (student.courseIds.contains(courseId)) {
        _students[i] = student.copyWith(
          courseIds:
              student.courseIds.where((String id) => id != courseId).toList(),
        );
      }
    }
    notifyListeners();
  }

  int studentCountForCourse(String courseId) => _students
      .where((Student student) => student.courseIds.contains(courseId))
      .length;

  void addEmployee(Employee employee) {
    _employees.add(employee);
    notifyListeners();
  }

  void removeEmployee(String employeeId) {
    _employees.removeWhere((Employee employee) => employee.id == employeeId);
    notifyListeners();
  }
}
