import '../models/course.dart';

/// Course persistence is kept separate from student and payroll operations.
abstract interface class CourseRepository {
  List<Course> getAll();

  void add(Course course);

  bool update(String originalId, Course course);

  bool remove(String courseId);
}

class InMemoryCourseRepository implements CourseRepository {
  InMemoryCourseRepository([Iterable<Course> courses = const <Course>[]])
      : _courses = List<Course>.of(courses);

  factory InMemoryCourseRepository.withSampleData() {
    return InMemoryCourseRepository(const <Course>[
      Course(
        id: 'SE101',
        name: 'Introduction to Software Engineering',
        duration: '12 weeks',
        description: 'Software development principles and team practices.',
      ),
      Course(
        id: 'IT101',
        name: 'Information Technology Fundamentals',
        duration: '12 weeks',
        description: 'Core concepts in computer systems, networks and IT.',
      ),
      Course(
        id: 'DB201',
        name: 'Database Management Systems',
        duration: '10 weeks',
        description: 'Relational database design, SQL and data management.',
      ),
    ]);
  }

  final List<Course> _courses;

  @override
  List<Course> getAll() => List<Course>.unmodifiable(_courses);

  @override
  void add(Course course) => _courses.add(course);

  @override
  bool update(String originalId, Course course) {
    final int index = _courses.indexWhere(
      (Course current) => current.id == originalId,
    );
    if (index == -1) {
      return false;
    }
    _courses[index] = course;
    return true;
  }

  @override
  bool remove(String courseId) {
    final int originalLength = _courses.length;
    _courses.removeWhere((Course course) => course.id == courseId);
    return _courses.length != originalLength;
  }
}
