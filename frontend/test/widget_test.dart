// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dispatch_iq/app/app.dart';
import 'package:dispatch_iq/services/assignment_service.dart';
import 'package:dispatch_iq/models/job.dart';
import 'package:dispatch_iq/screens/analytics/analytics_screen.dart';
import 'package:dispatch_iq/screens/dashboard/dashboard_screen.dart';
import 'package:dispatch_iq/screens/jobs/jobs_screen.dart';
import 'package:dispatch_iq/screens/login/login_screen.dart';
import 'package:dispatch_iq/screens/notifications/notifications_screen.dart';
import 'package:dispatch_iq/screens/profile/profile_screen.dart';
import 'package:dispatch_iq/screens/technicians/technicians_screen.dart';
import 'package:dispatch_iq/services/job_service.dart';
import 'package:dispatch_iq/services/technician_service.dart';
import 'package:dispatch_iq/widgets/summary_card.dart';

void main() {
  testWidgets('DispatchIQ launches the sign-in screen', (tester) async {
    await tester.pumpWidget(const DispatchIQApp());

    expect(find.text('DispatchIQ'), findsOneWidget);
  });

  testWidgets('login rejects invalid user input', (tester) async {
    await tester.pumpWidget(const DispatchIQApp());
    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    expect(find.byType(DashboardScreen), findsNothing);
  });

  testWidgets('profile account settings save user edits', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.tap(find.text('Account settings'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Nisha Rao');
    await tester.enterText(
        find.byType(TextField).at(1), 'nisha@dispatchiq.com');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nisha Rao'), findsOneWidget);
    expect(find.text('nisha@dispatchiq.com'), findsOneWidget);
  });

  testWidgets('profile logout returns to sign-in', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  test('assigning a technician updates the shared job data', () {
    final originalJob = JobService.allJobs.first;
    final originalTechnician = TechnicianService.getById('TECH-101')!;
    addTearDown(() {
      JobService.updateJob(originalJob);
      TechnicianService.updateTechnician(originalTechnician);
    });

    JobService.assignTechnician(originalJob.id, 'TECH-101');

    final updatedJob =
        JobService.allJobs.firstWhere((job) => job.id == originalJob.id);
    expect(updatedJob.technicianId, 'TECH-101');
    expect(updatedJob.status, JobStatus.assigned);
  });

  test('assignment updates technician workload and active schedule', () {
    final job = JobService.allJobs.firstWhere(
      (job) => job.status == JobStatus.unassigned,
    );
    final technician = TechnicianService.getById('TECH-101')!;
    final originalJob = job;
    final originalTechnician = technician;
    addTearDown(() {
      JobService.updateJob(originalJob);
      TechnicianService.updateTechnician(originalTechnician);
    });

    JobService.assignTechnician(job.id, technician.id);

    final updatedTechnician = TechnicianService.getById(technician.id)!;
    expect(updatedTechnician.currentWorkload, technician.currentWorkload + 1);
    expect(updatedTechnician.currentAssignedJobs, contains(job.id));
  });

  test('reassignment moves workload from previous to new technician', () {
    final job = JobService.allJobs.firstWhere(
      (job) =>
          job.technicianId == 'TECH-101' && job.status != JobStatus.completed,
    );
    final previous = TechnicianService.getById('TECH-101')!;
    final next = TechnicianService.getById('TECH-104')!;
    addTearDown(() {
      JobService.updateJob(job);
      TechnicianService.updateTechnician(previous);
      TechnicianService.updateTechnician(next);
    });

    JobService.assignTechnician(job.id, next.id);

    expect(TechnicianService.getById(previous.id)!.currentWorkload,
        (previous.currentWorkload - 1).clamp(0, previous.maxWorkload));
    expect(TechnicianService.getById(next.id)!.currentWorkload,
        next.currentWorkload + 1);
  });

  test('technician recommendations match the appliance expertise', () {
    final unassignedJob = JobService.allJobs.firstWhere(
      (job) => job.status == JobStatus.unassigned,
    );
    final recommendations =
        AssignmentService.getRecommendedTechnicians(unassignedJob);

    expect(recommendations, isNotEmpty);
    expect(
      recommendations.first.expertise,
      contains(unassignedJob.applianceType),
    );
  });

  test('repeat visit detection matches recent same-appliance faults', () {
    final seed = JobService.allJobs.firstWhere((job) => job.id == 'JOB-1001');
    final unflagged = seed.copyWith(
      isRepeatVisit: false,
      status: JobStatus.assigned,
    );

    expect(
      JobService.isRepeatVisit(unflagged, asOf: DateTime(2026, 9, 28)),
      isTrue,
    );
    expect(
      JobService.isRepeatVisit(unflagged, asOf: DateTime(2026, 11, 1)),
      isFalse,
    );
  });

  test('At Risk filter excludes jobs without a risk status', () {
    final atRiskJobs = JobService.getFilteredJobs(filter: 'At Risk');

    expect(
      atRiskJobs.every(
        (job) =>
            job.status == JobStatus.delayed || JobService.isRepeatVisit(job),
      ),
      isTrue,
    );
  });

  test('sample dispatch always includes jobs scheduled for today', () {
    expect(JobService.getTodayJobs(), isNotEmpty);
    expect(
      JobService.getTodayJobs().every((job) {
        final now = DateTime.now();
        return job.scheduledDate.year == now.year &&
            job.scheduledDate.month == now.month &&
            job.scheduledDate.day == now.day;
      }),
      isTrue,
    );
  });

  testWidgets('job search filters using entered customer text', (tester) async {
    final job = JobService.allJobs.first;
    await tester.pumpWidget(const MaterialApp(home: JobsScreen()));
    await tester.enterText(find.byType(TextField).first, job.customer.name);
    await tester.pumpAndSettle();

    expect(find.text(job.fault), findsOneWidget);
  });

  testWidgets('dashboard at-risk metric displays a numeric count', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    expect(find.textContaining("Instance of 'Job'"), findsNothing);
    expect(find.text('At Risk'), findsOneWidget);
  });

  testWidgets('dispatcher can assign a technician from job details',
      (tester) async {
    final originalJob = JobService.allJobs.first;
    final technician = TechnicianService.allTechnicians.first;
    addTearDown(() => JobService.updateJob(originalJob));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => JobDetailScreen(job: originalJob),
                ),
              ),
              child: const Text('Open job'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open job'));
    await tester.pumpAndSettle();
    final assignmentAction = find.text(
      originalJob.technicianId == null ? 'Assign Technician' : 'Reassign',
    );
    await tester.scrollUntilVisible(assignmentAction, 400);
    await tester.tap(assignmentAction);
    await tester.pumpAndSettle();
    await tester.tap(find.text(technician.name).last);
    await tester.pumpAndSettle();

    final updatedJob =
        JobService.allJobs.firstWhere((job) => job.id == originalJob.id);
    expect(updatedJob.technicianId, technician.id);
    expect(updatedJob.status, JobStatus.assigned);
  });

  final screens = <({String name, Widget Function() build})>[
    (name: 'Login', build: () => const LoginScreen()),
    (name: 'Dashboard', build: () => const DashboardScreen()),
    (name: 'Jobs', build: () => const JobsScreen()),
    (name: 'Team', build: () => const TechniciansScreen()),
    (name: 'Insights', build: () => const AnalyticsScreen()),
    (name: 'Notifications', build: () => const NotificationsScreen()),
    (name: 'Profile', build: () => const ProfileScreen()),
    (
      name: 'Job details',
      build: () => JobDetailScreen(job: JobService.allJobs.first),
    ),
    (
      name: 'Technician details',
      build: () => TechnicianDetailScreen(
            technician: TechnicianService.allTechnicians.first,
          ),
    ),
  ];

  for (final viewport in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(768, 1024),
    const Size(1492, 768),
  ]) {
    for (final screen in screens) {
      testWidgets('${screen.name} fits ${viewport.width}px viewport',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = viewport;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(MaterialApp(home: screen.build()));

        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('summary card fits a narrow dashboard tile', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 160,
            height: 84,
            child: SummaryCard(
              title: 'Technicians Available',
              value: '3',
              icon: Icons.engineering_rounded,
              delta: 'Ready to assign',
              accent: Color(0xFF2AA77E),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom navigation responds to tab selections', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DashboardScreen()));

    for (final destination in [
      (icon: Icons.assignment_rounded, index: 1),
      (icon: Icons.groups_rounded, index: 2),
      (icon: Icons.insights_rounded, index: 3),
      (icon: Icons.person_rounded, index: 4),
      (icon: Icons.home_rounded, index: 0),
    ]) {
      final destinationIcon = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(destination.icon),
      );
      await tester.tap(destinationIcon);
      await tester.pumpAndSettle();

      final navigationBar =
          tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, destination.index);
    }
  });
}
