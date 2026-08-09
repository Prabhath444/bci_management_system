import 'package:flutter/material.dart';

import '../models/course.dart';
import '../models/student.dart';
import '../state/bci_store.dart';
import '../validators/student_validator.dart';
import '../widgets/app_form_field.dart';
import '../widgets/screen_title.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, required this.store});

  final BciStore store;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final String search = _query.toLowerCase();
    final List<Student> students =
        widget.store.students.where((Student student) {
      return student.id.toLowerCase().contains(search) ||
          student.name.toLowerCase().contains(search) ||
          student.program.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const ScreenTitle('Student Management'),
                const SizedBox(height: 14),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search students',
                    hintText: 'Search by ID, name or programme',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) => setState(() => _query = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text('No students found.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final Student student = students[index];
                      final String courseNames = _courseNames(student);
                      return Card(
                        child: ListTile(
                          onTap: () => _showStudentDetails(student),
                          leading: CircleAvatar(
                            child: Text(
                              student.name.isEmpty
                                  ? '?'
                                  : student.name[0].toUpperCase(),
                            ),
                          ),
                          title: Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${student.id} • ${student.program}\n'
                            'Courses: $courseNames',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (String value) {
                              if (value == 'view') {
                                _showStudentDetails(student);
                              } else if (value == 'edit') {
                                _showStudentForm(student: student);
                              } else if (value == 'enrol') {
                                _showEnrolmentDialog(student);
                              } else if (value == 'delete') {
                                _confirmDelete(student);
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
                                value: 'enrol',
                                child: Text('Manage Courses'),
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
        onPressed: _showStudentForm,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Student'),
      ),
    );
  }

  String _courseNames(Student student) {
    final List<String> names = widget.store.courses
        .where((Course course) => student.courseIds.contains(course.id))
        .map((Course course) => course.name)
        .toList();
    return names.isEmpty ? 'Not enrolled' : names.join(', ');
  }

  Future<void> _showStudentDetails(Student student) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(student.name),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _StudentDetailRow(label: 'Student ID', value: student.id),
              _StudentDetailRow(label: 'Email', value: student.email),
              _StudentDetailRow(label: 'Programme', value: student.program),
              _StudentDetailRow(label: 'Intake', value: student.intake),
              _StudentDetailRow(label: 'Status', value: student.status),
              _StudentDetailRow(
                label: 'Courses',
                value: _courseNames(student),
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

  Future<void> _confirmDelete(Student student) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete student'),
        content: Text('Delete ${student.name} from the system?'),
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
      widget.store.removeStudent(student.id);
    }
  }

  Future<void> _showEnrolmentDialog(Student student) async {
    final Set<String> selectedCourses = student.courseIds.toSet();

    final List<String>? courseIds = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('Courses for ${student.name}'),
            content: SizedBox(
              width: 480,
              child: widget.store.courses.isEmpty
                  ? const Text(
                      'No courses are available. Add a course first from the '
                      'Courses section.',
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: widget.store.courses.map((Course course) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(course.name),
                          subtitle: Text('${course.id} • ${course.duration}'),
                          value: selectedCourses.contains(course.id),
                          onChanged: (bool? selected) {
                            setDialogState(() {
                              if (selected == true) {
                                selectedCourses.add(course.id);
                              } else {
                                selectedCourses.remove(course.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: widget.store.courses.isEmpty
                    ? null
                    : () {
                        final List<String> orderedIds = widget.store.courses
                            .where(
                              (Course course) =>
                                  selectedCourses.contains(course.id),
                            )
                            .map((Course course) => course.id)
                            .toList();
                        Navigator.pop(dialogContext, orderedIds);
                      },
                child: const Text('Save Enrolment'),
              ),
            ],
          );
        },
      ),
    );

    if (courseIds != null && mounted) {
      widget.store.setStudentCourses(student.id, courseIds);
    }
  }

  Future<void> _showStudentForm({Student? student}) async {
    final Student? updatedStudent = await showDialog<Student>(
      context: context,
      builder: (BuildContext context) => _StudentFormDialog(
        store: widget.store,
        student: student,
      ),
    );

    if (updatedStudent == null || !mounted) {
      return;
    }
    if (student == null) {
      widget.store.addStudent(updatedStudent);
    } else {
      widget.store.updateStudent(student.id, updatedStudent);
    }
  }
}

class _StudentFormDialog extends StatefulWidget {
  const _StudentFormDialog({required this.store, this.student});

  final BciStore store;
  final Student? student;

  @override
  State<_StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<_StudentFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final StudentValidator _validator = const StudentValidator();
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _programmeController;
  late final TextEditingController _intakeController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.student?.id);
    _nameController = TextEditingController(text: widget.student?.name);
    _emailController = TextEditingController(text: widget.student?.email);
    _programmeController = TextEditingController(
      text: widget.student?.program,
    );
    _intakeController = TextEditingController(text: widget.student?.intake);
    _status = widget.student?.status ?? 'Active';
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _programmeController.dispose();
    _intakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.student == null ? 'Register Student' : 'Edit Student'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AppFormField(
                  controller: _idController,
                  label: 'Student ID',
                  validator: (String value) => _validator.validateId(
                    value,
                    widget.store.students,
                    originalId: widget.student?.id,
                  ),
                ),
                AppFormField(
                  controller: _nameController,
                  label: 'Full Name',
                  validator: _validator.validateName,
                ),
                AppFormField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validator.validateEmail,
                ),
                AppFormField(
                  controller: _programmeController,
                  label: 'Programme',
                ),
                AppFormField(
                  controller: _intakeController,
                  label: 'Intake',
                ),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'Active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Inactive',
                      child: Text('Inactive'),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
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
      Student(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        program: _programmeController.text.trim(),
        intake: _intakeController.text.trim(),
        status: _status,
        courseIds: widget.student?.courseIds ?? const <String>[],
      ),
    );
  }
}

class _StudentDetailRow extends StatelessWidget {
  const _StudentDetailRow({required this.label, required this.value});

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
            width: 100,
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
