import 'package:flutter/material.dart';

import '../models/course.dart';
import '../state/bci_store.dart';
import '../validators/course_validator.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key, required this.store});

  final BciStore store;

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final String search = _query.toLowerCase();
    final List<Course> courses = widget.store.courses.where((Course course) {
      return course.id.toLowerCase().contains(search) ||
          course.name.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Course Management',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 14),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search courses',
                    hintText: 'Search by course code or name',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) => setState(() => _query = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: courses.isEmpty
                ? const Center(child: Text('No courses found.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final Course course = courses[index];
                      final int studentCount =
                          widget.store.studentCountForCourse(course.id);
                      return Card(
                        child: ListTile(
                          onTap: () => _showCourseDetails(course),
                          leading: const CircleAvatar(
                            child: Icon(Icons.menu_book_outlined),
                          ),
                          title: Text(
                            course.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${course.id} • ${course.duration}\n'
                            '$studentCount enrolled '
                            '${studentCount == 1 ? 'student' : 'students'}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (String value) {
                              if (value == 'view') {
                                _showCourseDetails(course);
                              } else if (value == 'edit') {
                                _showCourseForm(course: course);
                              } else if (value == 'delete') {
                                _confirmDelete(course);
                              }
                            },
                            itemBuilder: (_) => const <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'view',
                                child: Text('View'),
                              ),
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCourseForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }

  Future<void> _showCourseDetails(Course course) async {
    final List<String> studentNames = widget.store.students
        .where((student) => student.courseIds.contains(course.id))
        .map((student) => student.name)
        .toList();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(course.name),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _DetailRow(label: 'Course code', value: course.id),
              _DetailRow(label: 'Duration', value: course.duration),
              _DetailRow(label: 'Description', value: course.description),
              const SizedBox(height: 12),
              Text(
                'Enrolled students',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                studentNames.isEmpty
                    ? 'No students are enrolled.'
                    : studentNames.join(', '),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Course course) async {
    final int studentCount = widget.store.studentCountForCourse(course.id);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete course'),
        content: Text(
          studentCount == 0
              ? 'Delete ${course.name} from the system?'
              : 'Delete ${course.name}? It will also be removed from '
                  '$studentCount student ${studentCount == 1 ? 'record' : 'records'}.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.store.removeCourse(course.id);
    }
  }

  Future<void> _showCourseForm({Course? course}) async {
    final Course? updatedCourse = await showDialog<Course>(
      context: context,
      builder: (BuildContext context) => _CourseFormDialog(
        store: widget.store,
        course: course,
      ),
    );

    if (updatedCourse == null || !mounted) {
      return;
    }
    if (course == null) {
      widget.store.addCourse(updatedCourse);
    } else {
      widget.store.updateCourse(course.id, updatedCourse);
    }
  }
}

class _CourseFormDialog extends StatefulWidget {
  const _CourseFormDialog({required this.store, this.course});

  final BciStore store;
  final Course? course;

  @override
  State<_CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<_CourseFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CourseValidator _validator = const CourseValidator();
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _durationController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.course?.id);
    _nameController = TextEditingController(text: widget.course?.name);
    _durationController = TextEditingController(text: widget.course?.duration);
    _descriptionController = TextEditingController(
      text: widget.course?.description,
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.course == null ? 'Add Course' : 'Edit Course'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _CourseField(
                  controller: _idController,
                  label: 'Course Code',
                  validator: (String value) => _validator.validateId(
                    value,
                    widget.store.courses,
                    originalId: widget.course?.id,
                  ),
                ),
                _CourseField(
                  controller: _nameController,
                  label: 'Course Name',
                  validator: (String value) =>
                      _validator.required(value, 'Course Name'),
                ),
                _CourseField(
                  controller: _durationController,
                  label: 'Duration',
                  validator: (String value) =>
                      _validator.required(value, 'Duration'),
                ),
                _CourseField(
                  controller: _descriptionController,
                  label: 'Description',
                  validator: (String value) =>
                      _validator.required(value, 'Description'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop(
      context,
      Course(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        duration: _durationController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }
}

class _CourseField extends StatelessWidget {
  const _CourseField({
    required this.controller,
    required this.label,
    required this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String value) validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (String? value) => validator(value ?? ''),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
