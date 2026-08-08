import '../models/student.dart';

/// Focused student storage contract. Other data sources can implement the
/// same contract without changing the application service.
abstract interface class StudentRepository {
  List<Student> getAll();

  void add(Student student);

  bool update(String originalId, Student student);

  bool remove(String studentId);
}

class InMemoryStudentRepository implements StudentRepository {
  InMemoryStudentRepository([Iterable<Student> students = const <Student>[]])
      : _students = List<Student>.of(students);

  factory InMemoryStudentRepository.withSampleData() {
    return InMemoryStudentRepository(const <Student>[
      Student(
        id: 'BCI-2026-001',
        name: 'Ayesha Perera',
        email: 'ayesha@students.bci.lk',
        program: 'BSc Software Engineering',
        intake: 'February 2026',
        status: 'Active',
        courseIds: <String>['SE101', 'DB201'],
      ),
      Student(
        id: 'BCI-2026-002',
        name: 'Nimal Fernando',
        email: 'nimal@students.bci.lk',
        program: 'BSc Information Technology',
        intake: 'February 2026',
        status: 'Active',
        courseIds: <String>['IT101'],
      ),
      Student(
        id: 'BCI-2025-118',
        name: 'Tharushi Silva',
        email: 'tharushi@students.bci.lk',
        program: 'BSc Computer Science',
        intake: 'September 2025',
        status: 'Active',
        courseIds: <String>['SE101'],
      ),
    ]);
  }

  final List<Student> _students;

  @override
  List<Student> getAll() => List<Student>.unmodifiable(_students);

  @override
  void add(Student student) => _students.add(student);

  @override
  bool update(String originalId, Student student) {
    final int index = _students.indexWhere(
      (Student current) => current.id == originalId,
    );
    if (index == -1) {
      return false;
    }
    _students[index] = student;
    return true;
  }

  @override
  bool remove(String studentId) {
    final int originalLength = _students.length;
    _students.removeWhere((Student student) => student.id == studentId);
    return _students.length != originalLength;
  }
}
