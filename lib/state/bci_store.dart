import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../models/employee.dart';
import '../models/student.dart';
import '../repositories/course_repository.dart';
import '../repositories/employee_repository.dart';
import '../repositories/student_repository.dart';

/// Coordinates application state and cross-record rules. Storage is delegated
/// to focused repository abstractions supplied through constructor injection.
class BciStore extends ChangeNotifier {
  BciStore({
    required StudentRepository studentRepository,
    required CourseRepository courseRepository,
    required EmployeeRepository employeeRepository,
  })  : _studentRepository = studentRepository,
        _courseRepository = courseRepository,
        _employeeRepository = employeeRepository;

  final StudentRepository _studentRepository;
  final CourseRepository _courseRepository;
  final EmployeeRepository _employeeRepository;

  List<Student> get students => _studentRepository.getAll();
  List<Course> get courses => _courseRepository.getAll();
  List<Employee> get employees => _employeeRepository.getAll();

  int get activeStudentCount =>
      students.where((Student student) => student.status == 'Active').length;

  double get monthlyPayrollTotal => employees.fold<double>(
        0,
        (double sum, Employee employee) => sum + employee.netSalary,
      );

  void addStudent(Student student) {
    _studentRepository.add(student);
    notifyListeners();
  }

  void updateStudent(String originalId, Student student) {
    if (_studentRepository.update(originalId, student)) {
      notifyListeners();
    }
  }

  void removeStudent(String studentId) {
    if (_studentRepository.remove(studentId)) {
      notifyListeners();
    }
  }

  void setStudentCourses(String studentId, List<String> courseIds) {
    final Student? student = _findStudent(studentId);
    if (student == null) {
      return;
    }

    final Set<String> availableCourseIds =
        courses.map((Course course) => course.id).toSet();
    final List<String> validCourseIds =
        courseIds.where(availableCourseIds.contains).toList(growable: false);
    final Student updatedStudent = student.copyWith(
      courseIds: List<String>.unmodifiable(validCourseIds),
    );

    if (_studentRepository.update(studentId, updatedStudent)) {
      notifyListeners();
    }
  }

  void addCourse(Course course) {
    _courseRepository.add(course);
    notifyListeners();
  }

  void updateCourse(String originalId, Course course) {
    if (!_courseRepository.update(originalId, course)) {
      return;
    }

    if (originalId != course.id) {
      for (final Student student in students) {
        if (student.courseIds.contains(originalId)) {
          _studentRepository.update(
            student.id,
            student.copyWith(
              courseIds: student.courseIds
                  .map((String id) => id == originalId ? course.id : id)
                  .toList(growable: false),
            ),
          );
        }
      }
    }
    notifyListeners();
  }

  void removeCourse(String courseId) {
    if (!_courseRepository.remove(courseId)) {
      return;
    }

    for (final Student student in students) {
      if (student.courseIds.contains(courseId)) {
        _studentRepository.update(
          student.id,
          student.copyWith(
            courseIds: student.courseIds
                .where((String id) => id != courseId)
                .toList(growable: false),
          ),
        );
      }
    }
    notifyListeners();
  }

  int studentCountForCourse(String courseId) => students
      .where((Student student) => student.courseIds.contains(courseId))
      .length;

  void addEmployee(Employee employee) {
    _employeeRepository.add(employee);
    notifyListeners();
  }

  void removeEmployee(String employeeId) {
    if (_employeeRepository.remove(employeeId)) {
      notifyListeners();
    }
  }

  Student? _findStudent(String studentId) {
    for (final Student student in students) {
      if (student.id == studentId) {
        return student;
      }
    }
    return null;
  }
}
