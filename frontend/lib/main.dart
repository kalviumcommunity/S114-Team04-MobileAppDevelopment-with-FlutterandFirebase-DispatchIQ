import 'package:flutter/material.dart';

void main() {
  runApp(const DispatchIqApp());
}

class DispatchIqApp extends StatelessWidget {
  const DispatchIqApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF172A3A);
    const mint = Color(0xFF3EB489);
    return MaterialApp(
      title: 'DispatchIQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mint,
          brightness: Brightness.light,
          primary: mint,
          surface: const Color(0xFFF7F8F6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F6),
        fontFamily: 'Arial',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F8F6),
          foregroundColor: navy,
          elevation: 0,
        ),
      ),
      home: const DispatchHome(),
    );
  }
}

class DispatchHome extends StatefulWidget {
  const DispatchHome({super.key});

  @override
  State<DispatchHome> createState() => _DispatchHomeState();
}

class _DispatchHomeState extends State<DispatchHome> {
  int _selectedIndex = 0;
  String _filter = 'All jobs';

  void _showAssignSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => const AssignJobSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 820;
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (!isCompact) _SideRail(selectedIndex: _selectedIndex, onSelected: (index) => setState(() => _selectedIndex = index)),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(isCompact: isCompact, onAssign: _showAssignSheet),
                      Expanded(
                        child: _selectedIndex == 0
                            ? _DashboardBody(filter: _filter, onFilterChanged: (value) => setState(() => _filter = value), onAssign: _showAssignSheet)
                            : _PlaceholderView(index: _selectedIndex),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: isCompact
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Overview'),
                    NavigationDestination(icon: Icon(Icons.route_rounded), label: 'Jobs'),
                    NavigationDestination(icon: Icon(Icons.groups_rounded), label: 'Techs'),
                    NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Insights'),
                  ],
                )
              : null,
          floatingActionButton: isCompact && _selectedIndex == 0
              ? FloatingActionButton.extended(onPressed: _showAssignSheet, icon: const Icon(Icons.add_rounded), label: const Text('Assign job'))
              : null,
        );
      },
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xFF172A3A),
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: const Color(0xFF3EB489), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.bolt_rounded, color: Colors.white)),
            const SizedBox(width: 10),
            const Text('dispatchIQ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 19, letterSpacing: -0.5)),
          ]),
          const SizedBox(height: 52),
          const Text('WORKSPACE', style: TextStyle(color: Color(0xFF8093A4), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          _RailItem(icon: Icons.grid_view_rounded, label: 'Overview', active: selectedIndex == 0, onTap: () => onSelected(0)),
          _RailItem(icon: Icons.route_rounded, label: 'Jobs', active: selectedIndex == 1, onTap: () => onSelected(1), badge: '12'),
          _RailItem(icon: Icons.groups_rounded, label: 'Technicians', active: selectedIndex == 2, onTap: () => onSelected(2)),
          _RailItem(icon: Icons.bar_chart_rounded, label: 'Insights', active: selectedIndex == 3, onTap: () => onSelected(3)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF22394B), borderRadius: BorderRadius.circular(12)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.support_agent_rounded, color: Color(0xFF7BE0B4), size: 22),
              SizedBox(height: 10),
              Text('Need a hand?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('Open the dispatch playbook', style: TextStyle(color: Color(0xFF9FB0BC), fontSize: 11)),
            ]),
          ),
          const SizedBox(height: 20),
          const Row(children: [CircleAvatar(radius: 16, backgroundColor: Color(0xFFE9B872), child: Text('AM', style: TextStyle(color: Color(0xFF172A3A), fontSize: 11, fontWeight: FontWeight.bold))), SizedBox(width: 9), Expanded(child: Text('Alex Morgan\nDispatcher', style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4))), Icon(Icons.more_horiz_rounded, color: Color(0xFF8EA1AE))]),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem({required this.icon, required this.label, required this.active, required this.onTap, this.badge});
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        tileColor: active ? const Color(0xFF2D4B5A) : Colors.transparent,
        leading: Icon(icon, size: 19, color: active ? const Color(0xFF7BE0B4) : const Color(0xFF9AAAB7)),
        title: Text(label, style: TextStyle(color: active ? Colors.white : const Color(0xFFB5C0C8), fontWeight: active ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
        trailing: badge == null ? null : Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: const Color(0xFFE9B872), borderRadius: BorderRadius.circular(20)), child: Text(badge!, style: const TextStyle(color: Color(0xFF172A3A), fontWeight: FontWeight.w800, fontSize: 10))),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.isCompact, required this.onAssign});
  final bool isCompact;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isCompact ? 20 : 34, 20, isCompact ? 20 : 34, 10),
      child: Row(children: [
        if (isCompact) ...[const Icon(Icons.bolt_rounded, color: Color(0xFF3EB489), size: 28), const SizedBox(width: 8)],
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Monday, 18 March 2024', style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 4), const Text('Good morning, Alex', style: TextStyle(color: Color(0xFF172A3A), fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5))])),
        if (!isCompact) ...[
          SizedBox(width: 190, height: 38, child: TextField(decoration: InputDecoration(hintText: 'Search jobs...', hintStyle: const TextStyle(fontSize: 12), prefixIcon: const Icon(Icons.search_rounded, size: 19), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)), contentPadding: EdgeInsets.zero))),
          const SizedBox(width: 16),
        ],
        IconButton(onPressed: () {}, icon: const Badge(smallSize: 7, child: Icon(Icons.notifications_none_rounded, size: 23)), tooltip: 'Notifications'),
        if (!isCompact) ...[const SizedBox(width: 8), FilledButton.icon(onPressed: onAssign, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Assign job'))],
      ]),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.filter, required this.onFilterChanged, required this.onAssign});
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(34, 20, 34, 34),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _KpiRow(),
        const SizedBox(height: 28),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 930;
          final left = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_SectionTitle(title: 'Live dispatch board', action: 'View all jobs', onTap: () {}), const SizedBox(height: 12), _JobBoard(filter: filter, onFilterChanged: onFilterChanged, onAssign: onAssign)]);
          final right = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_SectionTitle(title: 'Technician pulse', action: 'Manage team', onTap: () {}), const SizedBox(height: 12), const _TechnicianPulse()]);
          if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 3, child: left), const SizedBox(width: 24), Expanded(flex: 2, child: right)]);
          return Column(children: [left, const SizedBox(height: 26), right]);
        }),
      ]),
    );
  }
}

class _KpiRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cards = [
      ('Open jobs', '12', '+3 today', Icons.assignment_outlined, const Color(0xFFE3F5EC), const Color(0xFF23845D)),
      ('On the road', '08', 'of 14 techs', Icons.near_me_rounded, const Color(0xFFEAF0FA), const Color(0xFF416A9A)),
      ('Avg. arrival', '31 min', '-8 min vs last week', Icons.timer_outlined, const Color(0xFFFFF1D9), const Color(0xFF9B6A21)),
      ('First-time fix', '84%', '+6.2% this month', Icons.check_circle_outline_rounded, const Color(0xFFF5E9F1), const Color(0xFF9C4772)),
    ];
    return LayoutBuilder(builder: (context, constraints) {
      final count = constraints.maxWidth > 900 ? 4 : constraints.maxWidth > 560 ? 2 : 1;
      return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: cards.length, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: count, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: constraints.maxWidth > 560 ? 2.1 : 3.3), itemBuilder: (context, index) {
        final card = cards[index];
        return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE6EAE8))), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: card.$5, borderRadius: BorderRadius.circular(10)), child: Icon(card.$4, color: card.$6, size: 21)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(card.$1, style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(card.$2, style: const TextStyle(color: Color(0xFF172A3A), fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(width: 7), Flexible(child: Text(card.$3, overflow: TextOverflow.ellipsis, style: TextStyle(color: card.$6, fontSize: 10, fontWeight: FontWeight.w700)))]),]))]));
      });
    });
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.action, required this.onTap});
  final String title;
  final String action;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Row(children: [Text(title, style: const TextStyle(color: Color(0xFF172A3A), fontSize: 16, fontWeight: FontWeight.w800)), const Spacer(), TextButton(onPressed: onTap, child: Text(action, style: const TextStyle(color: Color(0xFF23845D), fontWeight: FontWeight.w700, fontSize: 12)))]);
}

class _JobBoard extends StatelessWidget {
  const _JobBoard({required this.filter, required this.onFilterChanged, required this.onAssign});
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final VoidCallback onAssign;
  @override
  Widget build(BuildContext context) {
    const jobs = [
      ('#J-1048', 'Washing machine not draining', 'Oakwood · 2.4 mi', '10:00 - 11:00', 'High', 'Maya Chen', 'MC', Color(0xFFE9B872)),
      ('#J-1047', 'Refrigerator making noise', 'Northgate · 4.1 mi', '11:30 - 12:30', 'Normal', 'Jordan Bell', 'JB', Color(0xFF9FC7E5)),
      ('#J-1046', 'Oven temperature issue', 'Riverside · 1.8 mi', '12:00 - 13:00', 'Normal', 'Unassigned', '--', Color(0xFFE7EBE9)),
      ('#J-1045', 'Dryer not heating', 'Westview · 3.7 mi', '13:30 - 14:30', 'Repeat visit', 'Sam Rivera', 'SR', Color(0xFFD5B6E5)),
    ];
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE6EAE8))), child: Column(children: [
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['All jobs', 'Unassigned', 'At risk', 'Repeat visits'].map((item) => Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(item, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)), selected: filter == item, onSelected: (_) => onFilterChanged(item)))).toList())),
      const SizedBox(height: 10),
      ...jobs.map((job) => _JobRow(data: job, onAssign: onAssign)),
    ]));
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.data, required this.onAssign});
  final (String, String, String, String, String, String, String, Color) data;
  final VoidCallback onAssign;
  @override
  Widget build(BuildContext context) {
    final isUnassigned = data.$6 == 'Unassigned';
    final isRepeat = data.$5 == 'Repeat visit';
    return Container(padding: const EdgeInsets.symmetric(vertical: 13), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F2F1)))), child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: data.$8, shape: BoxShape.circle), child: Center(child: Text(data.$7, style: const TextStyle(color: Color(0xFF172A3A), fontSize: 10, fontWeight: FontWeight.w800)))),
      const SizedBox(width: 10),
      Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data.$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF172A3A), fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text('${data.$1}  ·  ${data.$3}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10))])),
      if (MediaQuery.sizeOf(context).width > 600) Expanded(child: Text(data.$4, style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 11, fontWeight: FontWeight.w600))),
      if (MediaQuery.sizeOf(context).width > 500) Padding(padding: const EdgeInsets.only(right: 10), child: _StatusPill(label: data.$5, alert: data.$5 == 'High' || isRepeat)),
      if (isUnassigned) SizedBox(height: 30, child: OutlinedButton(onPressed: onAssign, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10), side: const BorderSide(color: Color(0xFF3EB489))), child: const Text('Assign', style: TextStyle(fontSize: 10, color: Color(0xFF23845D), fontWeight: FontWeight.w700)))) else SizedBox(width: 74, child: Text(data.$6, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF172A3A), fontSize: 10, fontWeight: FontWeight.w600))),
    ]));
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.alert});
  final String label;
  final bool alert;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: alert ? const Color(0xFFFFF0E9) : const Color(0xFFEAF5EF), borderRadius: BorderRadius.circular(5)), child: Text(label, style: TextStyle(color: alert ? const Color(0xFFB45031) : const Color(0xFF23845D), fontSize: 9, fontWeight: FontWeight.w800)));
}

class _TechnicianPulse extends StatelessWidget {
  const _TechnicianPulse();
  @override
  Widget build(BuildContext context) {
    const techs = [('Maya Chen', 'En route to Oakwood', 'On route', Color(0xFF3EB489), 'MC', Color(0xFFE9B872)), ('Jordan Bell', 'Finishing in Northgate', 'On job', Color(0xFF416A9A), 'JB', Color(0xFF9FC7E5)), ('Sam Rivera', 'Available · 3 jobs today', 'Available', Color(0xFF9B6A21), 'SR', Color(0xFFD5B6E5)), ('Priya Shah', 'Break until 12:45', 'On break', Color(0xFF8C6A9B), 'PS', Color(0xFFF1C6D6))];
    final technicianRows = techs.map((tech) => Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(children: [
        CircleAvatar(radius: 17, backgroundColor: tech.$6, child: Text(tech.$5, style: const TextStyle(color: Color(0xFF172A3A), fontSize: 10, fontWeight: FontWeight.w800))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tech.$1, style: const TextStyle(color: Color(0xFF172A3A), fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(tech.$2, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 10))])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(tech.$3, style: TextStyle(color: tech.$4, fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Container(width: 7, height: 7, decoration: BoxDecoration(color: tech.$4, shape: BoxShape.circle))]),
      ]),
    )).toList();
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE6EAE8))), child: Column(children: technicianRows));
  }
}

class AssignJobSheet extends StatelessWidget {
  const AssignJobSheet({super.key});
  @override
  Widget build(BuildContext context) {
    final technicianOptions = ['Sam Rivera · 1.8 mi away · 2 jobs', 'Maya Chen · 4.2 mi away · 3 jobs', 'Priya Shah · 5.1 mi away · 1 job'];
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 0, 22, MediaQuery.viewInsetsOf(context).bottom + 22),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Assign a technician', style: TextStyle(color: Color(0xFF172A3A), fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Choose the best fit using location, workload and expertise.', style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 12)),
        const SizedBox(height: 18),
        const Text('JOB TO ASSIGN', style: TextStyle(color: Color(0xFF8093A4), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        const SizedBox(height: 8),
        Container(width: double.infinity, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFF3F7F5), borderRadius: BorderRadius.circular(9)), child: const Row(children: [Icon(Icons.local_laundry_service_outlined, color: Color(0xFF23845D)), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Oven temperature issue', style: TextStyle(color: Color(0xFF172A3A), fontWeight: FontWeight.w700, fontSize: 13)), SizedBox(height: 3), Text('Riverside · 12:00 - 13:00', style: TextStyle(color: Color(0xFF8093A4), fontSize: 11))])])),
        const SizedBox(height: 18),
        RadioGroup<int>(groupValue: 0, onChanged: (_) {}, child: Column(children: technicianOptions.asMap().entries.map((entry) => RadioListTile<int>(value: entry.key, contentPadding: EdgeInsets.zero, title: Text(entry.value, style: const TextStyle(color: Color(0xFF172A3A), fontSize: 12, fontWeight: FontWeight.w600)), subtitle: const Text('Appliance specialist · Good fit', style: TextStyle(fontSize: 10)), activeColor: const Color(0xFF3EB489))).toList())),
        const SizedBox(height: 6),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Confirm assignment'))),
      ]),
    );
  }
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    final labels = ['Overview', 'Jobs', 'Technicians', 'Insights'];
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon([Icons.grid_view_rounded, Icons.route_rounded, Icons.groups_rounded, Icons.bar_chart_rounded][index], size: 52, color: const Color(0xFF3EB489)), const SizedBox(height: 16), Text('${labels[index]} view', style: const TextStyle(color: Color(0xFF172A3A), fontSize: 24, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text('This workspace is ready for the next workflow.', style: TextStyle(color: Colors.blueGrey.shade500))]));
  }
}
