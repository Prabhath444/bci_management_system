# BCI Integrated Management System - Flutter MVP

This starter application contains three working modules:

1. Student Management
2. Course and Enrolment Management
3. Employee and Payroll Management

It uses only the Flutter SDK, so there are no third-party package dependencies.
Data is currently stored in memory for demonstration and teaching. Closing the
application clears newly entered records. The next production step is to connect
this UI to a Spring Boot REST API and PostgreSQL database.

## Features

- Responsive dashboard for mobile and desktop/web widths
- Student search, registration, viewing, editing and deletion
- Course search, creation, viewing, editing and deletion
- Student enrolment in one or more courses
- Employee registration and removal
- Gross salary, deductions and net salary calculation
- Sample data for classroom demonstrations
- Form validation
- Material 3 interface

## Project setup on macOS

### Option A: Create platform folders inside this project

1. Extract the ZIP file.
2. Open Terminal in the extracted folder.
3. Run:

```bash
flutter create --project-name bci_management_system .
flutter pub get
flutter run
```

`flutter create --project-name bci_management_system .` generates the Android, iOS, web and desktop folders while
keeping the supplied `lib` source code.

### Option B: Create a new Flutter project

```bash
flutter create bci_management_system
cd bci_management_system
```

Replace its `lib` folder and `pubspec.yaml` with the files from this starter.
Then run:

```bash
flutter pub get
flutter run
```

## Run targets

List devices:

```bash
flutter devices
```

Run Android emulator or phone:

```bash
flutter run
```

Run in Chrome:

```bash
flutter run -d chrome
```

## Payroll formula

- Gross Salary = Basic Salary + Allowances + Overtime
- Total Deductions = Other Deductions + Tax
- Net Salary = Gross Salary - Total Deductions

## Recommended production improvements

- Spring Boot REST API
- PostgreSQL database
- JWT authentication and role permissions
- Student attendance, results and fees
- Employee attendance and leave
- Monthly payroll periods and approval workflow
- PDF payslip generation
- Audit logs and database backups
