class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.designation,
    required this.basicSalary,
    required this.allowances,
    required this.overtime,
    required this.deductions,
    required this.tax,
  });

  final String id;
  final String name;
  final String department;
  final String designation;
  final double basicSalary;
  final double allowances;
  final double overtime;
  final double deductions;
  final double tax;

  double get grossSalary => basicSalary + allowances + overtime;

  double get totalDeductions => deductions + tax;

  double get netSalary => grossSalary - totalDeductions;
}
