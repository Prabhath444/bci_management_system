import '../models/employee.dart';

/// Payroll clients depend only on the employee operations they require.
abstract interface class EmployeeRepository {
  List<Employee> getAll();

  void add(Employee employee);

  bool remove(String employeeId);
}

class InMemoryEmployeeRepository implements EmployeeRepository {
  InMemoryEmployeeRepository([
    Iterable<Employee> employees = const <Employee>[],
  ]) : _employees = List<Employee>.of(employees);

  factory InMemoryEmployeeRepository.withSampleData() {
    return InMemoryEmployeeRepository(const <Employee>[
      Employee(
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
      Employee(
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
      Employee(
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
    ]);
  }

  final List<Employee> _employees;

  @override
  List<Employee> getAll() => List<Employee>.unmodifiable(_employees);

  @override
  void add(Employee employee) => _employees.add(employee);

  @override
  bool remove(String employeeId) {
    final int originalLength = _employees.length;
    _employees.removeWhere((Employee employee) => employee.id == employeeId);
    return _employees.length != originalLength;
  }
}
