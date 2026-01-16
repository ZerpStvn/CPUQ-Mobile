import 'package:cpuq/models/announcement.dart';
import 'package:cpuq/models/service_item.dart';
import 'package:cpuq/services/permission_service.dart';
import 'package:cpuq/utils/global_theme.dart';
import 'package:cpuq/view/alerts_page.dart';
import 'package:cpuq/view/check_queue_page.dart';
import 'package:cpuq/view/profile_page.dart';
import 'package:cpuq/view/queue_display_page.dart';
import 'package:cpuq/view/services_page.dart';
import 'package:cpuq/widgets/coming_soon_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(services: _services, announcements: _announcements),
      const ServicesPage(),
      const AlertsPage(),
      const ProfilePage(),
    ];

    // Check and request permissions after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  Future<void> _checkPermissions() async {
    await PermissionService.checkAndRequestPermissions(context);
  }

  List<ServiceItem> get _services => [
    ServiceItem(
      title: 'My Classes',
      icon: FontAwesomeIcons.bookOpen,
      iconColor: primaryColor,
    ),
    ServiceItem(
      title: 'Schedule',
      icon: FontAwesomeIcons.calendar,
      iconColor: primaryColor,
    ),
    ServiceItem(
      title: 'Grades',
      icon: FontAwesomeIcons.chartLine,
      iconColor: primaryColor,
    ),

    ServiceItem(
      title: 'Advising',
      icon: FontAwesomeIcons.userTie,
      iconColor: primaryColor,
    ),
    ServiceItem(
      title: 'Register',
      icon: FontAwesomeIcons.fileLines,
      iconColor: primaryColor,
    ),
    ServiceItem(
      title: 'PoolPass',
      icon: FontAwesomeIcons.ticket,
      iconColor: primaryColor,
    ),
    ServiceItem(
      title: 'Campus Map',
      icon: FontAwesomeIcons.mapLocationDot,
      iconColor: primaryColor,
    ),
  ];

  final List<Announcement> _announcements = [
    Announcement(
      title: 'Enrollment Advisory',
      description: 'Important Updates',
      icon: FontAwesomeIcons.triangleExclamation,
      iconBackground: const Color(0xFF3B82F6),
      date: DateTime.now(),
    ),
    Announcement(
      title: 'University Week',
      description: 'Join Activities & Events',
      icon: FontAwesomeIcons.calendar,
      iconBackground: const Color(0xFFFFB800),
      date: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: FontAwesomeIcons.house,
                label: 'Home',
                isSelected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.briefcase,
                label: 'Services',
                isSelected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.bell,
                label: 'Alerts',
                isSelected: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              _buildNavItem(
                icon: FontAwesomeIcons.user,
                label: 'Profile',
                isSelected: _selectedIndex == 3,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? neutralWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              size: 22,
              color: isSelected ? primaryColor : neutralWhite.withOpacity(0.6),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? primaryColor
                    : neutralWhite.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// HomeContent Widget - The main home screen content
class HomeContent extends StatelessWidget {
  final List<ServiceItem> services;
  final List<Announcement> announcements;

  const HomeContent({
    super.key,
    required this.services,
    required this.announcements,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildQuickActionsCard(context),
                  const SizedBox(height: 28),
                  _buildServicesSection(context),
                  const SizedBox(height: 28),
                  _buildAnnouncementsSection(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(color: neutralWhite),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textGray,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Centralians',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset('assets/icon/icon.png', fit: BoxFit.contain),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                title: 'Classes',
                subtitle: '0 active courses',
                icon: FontAwesomeIcons.bookOpen,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[400]!, Colors.grey[600]!],
                ),
                isDisabled: true,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                title: 'Schedule',
                subtitle: 'View timetable',
                icon: FontAwesomeIcons.calendar,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[400]!, Colors.grey[600]!],
                ),
                isDisabled: true,
                onTap: () {
                  ComingSoonDialog.show(
                    context,
                    title: 'Schedule',
                    icon: FontAwesomeIcons.calendar,
                    iconColor: const Color(0xFF06B6D4),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                title: 'Grades',
                subtitle: 'Check results',
                icon: FontAwesomeIcons.chartLine,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[400]!, Colors.grey[600]!],
                ),
                isDisabled: true,
                onTap: () {
                  ComingSoonDialog.show(
                    context,
                    title: 'Grades',
                    icon: FontAwesomeIcons.chartLine,
                    iconColor: const Color(0xFFFBBF24),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                context: context,
                title: 'CQueue',
                subtitle: 'Check Queue Number',
                icon: FontAwesomeIcons.listOl,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 62, 59, 226),
                    Color.fromARGB(255, 5, 8, 221),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QueueDisplayPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Opacity(
        opacity: isDisabled ? 0.7 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(icon, size: 24, color: neutralWhite),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: neutralWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Services',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
            childAspectRatio: 0.82,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceItem(context, service);
          },
        ),
      ],
    );
  }

  Widget _buildServiceItem(BuildContext context, ServiceItem service) {
    return InkWell(
      onTap: () {
        ComingSoonDialog.show(
          context,
          title: service.title,
          icon: service.icon,
          iconColor: service.iconColor,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: neutralWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: FaIcon(
                service.icon,
                size: 24,
                color: service.iconColor ?? primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              service.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: textDark,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Announcements',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View All',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: announcements.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return _buildAnnouncementCard(context, announcement);
          },
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    Announcement announcement,
  ) {
    return InkWell(
      onTap: () {
        ComingSoonDialog.show(
          context,
          title: announcement.title,
          icon: announcement.icon,
          iconColor: announcement.iconBackground,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: neutralWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: announcement.iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(announcement.icon, size: 22, color: neutralWhite),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    announcement.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textGray,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: textGray,
            ),
          ],
        ),
      ),
    );
  }
}
