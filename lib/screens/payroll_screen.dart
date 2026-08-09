import 'package:flutter/material.dart';

import '../models/employee.dart';
import '../state/bci_store.dart';
import '../widgets/app_form_field.dart';
import '../widgets/screen_title.dart';

class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key, required this.store});

  final BciStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: <Widget>[
          const ScreenTitle('Payroll Management'),
          const SizedBox(height: 6),
          Text(
            'Monthly salary calculation for BCI employees',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.payments_outlined, size: 38),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Total Net Payroll'),
                        Text(
                          _money(store.monthlyPayrollTotal),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...store.employees.map(
            (Employee employee) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: ExpansionTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.badge_outlined)),
                  title: Text(
                    employee.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${employee.id} • ${employee.designation}\n${employee.department}',
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  children: <Widget>[
                    _SalaryRow(
                        label: 'Basic Salary', value: employee.basicSalary),
                    _SalaryRow(label: 'Allowances', value: employee.allowances),
                    _SalaryRow(label: 'Overtime', value: employee.overtime),
                    const Divider(),
                    _SalaryRow(
                      label: 'Gross Salary',
                      value: employee.grossSalary,
                      bold: true,
                    ),
                    _SalaryRow(
                        label: 'Other Deductions', value: employee.deductions),
                    _SalaryRow(label: 'Tax', value: employee.tax),
                    const Divider(),
                    _SalaryRow(
                      label: 'Net Salary',
                      value: employee.netSalary,
                      bold: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _confirmDelete(context, employee),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove Employee'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEmployeeDialog(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Employee'),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Employee employee) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Remove employee'),
        content: Text('Remove ${employee.name} and the payroll record?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      store.removeEmployee(employee.id);
    }
  }

  Future<void> _showAddEmployeeDialog(BuildContext context) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController id = TextEditingController();
    final TextEditingController name = TextEditingController();
    final TextEditingController department = TextEditingController();
    final TextEditingController designation = TextEditingController();
    final TextEditingController basic = TextEditingController();
    final TextEditingController allowances = TextEditingController(text: '0');
    final TextEditingController overtime = TextEditingController(text: '0');
    final TextEditingController deductions = TextEditingController(text: '0');
    final TextEditingController tax = TextEditingController(text: '0');

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Add Employee and Payroll'),
        content: SizedBox(
          width: 520,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AppFormField(controller: id, label: 'Employee ID'),
                  AppFormField(controller: name, label: 'Full Name'),
                  AppFormField(controller: department, label: 'Department'),
                  AppFormField(controller: designation, label: 'Designation'),
                  AppFormField.number(
                    controller: basic,
                    label: 'Basic Salary (LKR)',
                  ),
                  AppFormField.number(
                    controller: allowances,
                    label: 'Allowances (LKR)',
                  ),
                  AppFormField.number(
                    controller: overtime,
                    label: 'Overtime (LKR)',
                  ),
                  AppFormField.number(
                    controller: deductions,
                    label: 'Other Deductions (LKR)',
                  ),
                  AppFormField.number(
                    controller: tax,
                    label: 'Tax (LKR)',
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                store.addEmployee(
                  Employee(
                    id: id.text.trim(),
                    name: name.text.trim(),
                    department: department.text.trim(),
                    designation: designation.text.trim(),
                    basicSalary: double.parse(basic.text.trim()),
                    allowances: double.parse(allowances.text.trim()),
                    overtime: double.parse(overtime.text.trim()),
                    deductions: double.parse(deductions.text.trim()),
                    tax: double.parse(tax.text.trim()),
                  ),
                );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Calculate and Save'),
          ),
        ],
      ),
    );

    for (final TextEditingController controller in <TextEditingController>[
      id,
      name,
      department,
      designation,
      basic,
      allowances,
      overtime,
      deductions,
      tax,
    ]) {
      controller.dispose();
    }
  }

  static String _money(double value) => 'LKR ${value.toStringAsFixed(2)}';
}

class _SalaryRow extends StatelessWidget {
  const _SalaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = bold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: style)),
          Text('LKR ${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
