import 'dart:async';
import 'package:cpuq/models/queue/department.dart';
import 'package:cpuq/models/queue/queue_ticket.dart';
import 'package:cpuq/providers/queue_providers.dart';
import 'package:cpuq/services/notification_service.dart';
import 'package:cpuq/services/saved_ticket_service.dart';
import 'package:cpuq/utils/global_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QueueDisplayPage extends ConsumerStatefulWidget {
  const QueueDisplayPage({super.key});

  @override
  ConsumerState<QueueDisplayPage> createState() => _QueueDisplayPageState();
}

class _QueueDisplayPageState extends ConsumerState<QueueDisplayPage> {
  final _ticketInputController = TextEditingController();
  String? _savedTicketNumber;
  QueueTicket? _myTicket;

  // Notification tracking
  String? _lastNotifiedStatus;
  int? _lastNotifiedPosition;
  Timer? _ticketWatchTimer;

  @override
  void initState() {
    super.initState();
    _loadSavedTicket();
    _startTicketWatcher();
  }

  @override
  void dispose() {
    _ticketInputController.dispose();
    _ticketWatchTimer?.cancel();
    super.dispose();
  }

  void _startTicketWatcher() {
    // Watch for ticket status changes every 5 seconds
    _ticketWatchTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_savedTicketNumber != null) {
        _checkTicketStatusForNotification();
      }
    });
  }

  Future<void> _checkTicketStatusForNotification() async {
    if (_savedTicketNumber == null) return;

    final repository = ref.read(queueRepositoryProvider);

    try {
      // Check if ticket is being served
      final servingTickets = await repository.streamServingTickets(departmentId: null).first;
      final servingTicket = servingTickets.where((t) => t.ticketNumber == _savedTicketNumber).firstOrNull;

      if (servingTicket != null) {
        // Ticket is now being served!
        if (_lastNotifiedStatus != 'serving') {
          _lastNotifiedStatus = 'serving';
          await NotificationService().showNowServingNotification(
            ticketNumber: _savedTicketNumber!,
            windowName: servingTicket.windowName ?? 'Counter',
          );
        }
        return;
      }

      // Check position in waiting queue
      final waitingTickets = await repository.streamWaitingTickets(departmentId: null).first;
      final position = waitingTickets.indexWhere((t) => t.ticketNumber == _savedTicketNumber);

      if (position != -1) {
        final queuePosition = position + 1; // 1-based position

        // Notify if position is 1 (next in line) and we haven't notified yet
        if (queuePosition == 1 && _lastNotifiedPosition != 1) {
          _lastNotifiedPosition = 1;
          await NotificationService().showNextInLineNotification(
            ticketNumber: _savedTicketNumber!,
          );
        }
        // Notify for positions 2-3 if we haven't notified for those
        else if (queuePosition <= 3 && _lastNotifiedPosition != queuePosition) {
          _lastNotifiedPosition = queuePosition;
          await NotificationService().showPositionUpdateNotification(
            ticketNumber: _savedTicketNumber!,
            position: queuePosition,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking ticket status: $e');
    }
  }

  Future<void> _loadSavedTicket() async {
    final savedTicket = await SavedTicketService.getSavedTicketNumber();
    if (mounted) {
      setState(() {
        _savedTicketNumber = savedTicket;
      });
      if (savedTicket != null) {
        _findMyTicket(savedTicket);
      }
    }
  }

  Future<void> _saveTicketNumber() async {
    final ticketNumber = _ticketInputController.text.trim().toUpperCase();
    if (ticketNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a ticket number')),
      );
      return;
    }

    await SavedTicketService.saveTicketNumber(ticketNumber);
    setState(() {
      _savedTicketNumber = ticketNumber;
      _ticketInputController.clear();
      // Reset notification tracking for new ticket
      _lastNotifiedStatus = null;
      _lastNotifiedPosition = null;
    });
    _findMyTicket(ticketNumber);

    // Immediately check for notifications
    _checkTicketStatusForNotification();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket $ticketNumber saved. You\'ll be notified when it\'s your turn!'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  Future<void> _findMyTicket(String ticketNumber) async {
    final repository = ref.read(queueRepositoryProvider);
    final servingStream = repository.streamServingTickets(departmentId: null);
    final waitingStream = repository.streamWaitingTickets(departmentId: null);

    final servingTickets = await servingStream.first;
    final waitingTickets = await waitingStream.first;

    final allTickets = [...servingTickets, ...waitingTickets];
    final ticket = allTickets.where((t) => t.ticketNumber == ticketNumber).firstOrNull;

    if (mounted) {
      setState(() {
        _myTicket = ticket;
      });
    }
  }

  Future<void> _clearSavedTicket() async {
    await SavedTicketService.clearSavedTicket();
    await NotificationService().cancelAll();
    setState(() {
      _savedTicketNumber = null;
      _myTicket = null;
      _lastNotifiedStatus = null;
      _lastNotifiedPosition = null;
    });
  }

  Widget _buildMyTicketInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const FaIcon(
                  FontAwesomeIcons.ticket,
                  color: primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Track My Ticket',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ticketInputController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter ticket number (e.g., BUSS-004)',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: textGray.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: backgroundGray,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _saveTicketNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: neutralWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const FaIcon(
                  FontAwesomeIcons.floppyDisk,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyTicketCard() {
    if (_myTicket == null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: neutralWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.circleExclamation,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ticket Not Found',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ticket $_savedTicketNumber may have been completed',
                    style: TextStyle(
                      fontSize: 12,
                      color: textGray,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _clearSavedTicket,
              icon: const FaIcon(
                FontAwesomeIcons.xmark,
                size: 16,
                color: textGray,
              ),
            ),
          ],
        ),
      );
    }

    final isServing = _myTicket!.status == 'serving';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isServing
              ? [primaryColor, const Color(0xFF05236D)]
              : [secondaryColor, const Color(0xFFFFD54F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isServing ? primaryColor : secondaryColor).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Ticket',
                    style: TextStyle(
                      fontSize: 12,
                      color: isServing
                          ? neutralWhite.withOpacity(0.8)
                          : textDark.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _myTicket!.ticketNumber,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: isServing ? secondaryColor : textDark,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isServing
                          ? secondaryColor
                          : neutralWhite.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isServing ? 'NOW SERVING' : 'WAITING',
                      style: TextStyle(
                        color: isServing ? textDark : primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: _clearSavedTicket,
                    icon: FaIcon(
                      FontAwesomeIcons.xmark,
                      size: 16,
                      color: isServing
                          ? neutralWhite.withOpacity(0.7)
                          : textDark.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isServing && _myTicket!.windowName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.computer,
                    color: secondaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proceed to',
                        style: TextStyle(
                          color: neutralWhite.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _myTicket!.windowName!,
                        style: const TextStyle(
                          color: neutralWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDepartmentId = ref.watch(selectedDepartmentProvider);
    final departmentsAsync = ref.watch(departmentsStreamProvider);

    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: neutralWhite,
        elevation: 0,
        title: const Text(
          'Queue Display',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: neutralWhite,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: neutralWhite),
      ),
      body: Column(
        children: [
          // Department Filter
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: departmentsAsync.when(
              data: (departments) => _buildDepartmentFilter(
                context,
                ref,
                departments,
                selectedDepartmentId,
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: neutralWhite),
              ),
              error: (error, stack) => Text(
                'Error loading departments',
                style: TextStyle(color: neutralWhite),
              ),
            ),
          ),

          // My Ticket Section
          if (_savedTicketNumber != null)
            _buildMyTicketCard()
          else
            _buildMyTicketInput(),

          // Queue Display
          Expanded(
            child: _buildQueueDisplay(context, ref, selectedDepartmentId),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentFilter(
    BuildContext context,
    WidgetRef ref,
    List<Department> departments,
    String? selectedDepartmentId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Department',
          style: TextStyle(
            color: neutralWhite,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // All Departments chip
            _buildDepartmentChip(
              context,
              ref,
              'All',
              null,
              selectedDepartmentId == null,
            ),
            // Individual department chips
            ...departments.map((dept) => _buildDepartmentChip(
                  context,
                  ref,
                  dept.name,
                  dept.id,
                  selectedDepartmentId == dept.id,
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildDepartmentChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    String? departmentId,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedDepartmentProvider.notifier).state = departmentId;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? secondaryColor : neutralWhite.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? secondaryColor : neutralWhite.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? textDark : neutralWhite,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildQueueDisplay(
    BuildContext context,
    WidgetRef ref,
    String? departmentId,
  ) {
    final servingTicketsAsync =
        ref.watch(servingTicketsStreamProvider(departmentId));
    final waitingTicketsAsync =
        ref.watch(waitingTicketsStreamProvider(departmentId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(servingTicketsStreamProvider(departmentId));
        ref.invalidate(waitingTicketsStreamProvider(departmentId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Now Serving Section
            Text(
              'Now Serving',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
            ),
            const SizedBox(height: 12),
            servingTicketsAsync.when(
              data: (tickets) => tickets.isEmpty
                  ? _buildEmptyState('No tickets being served')
                  : _buildServingTickets(context, tickets),
              loading: () => _buildServingSkeletonLoader(),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),

            const SizedBox(height: 24),

            // Waiting Queue Section
            Text(
              'Next in Line',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
            ),
            const SizedBox(height: 12),
            waitingTicketsAsync.when(
              data: (tickets) => tickets.isEmpty
                  ? _buildEmptyState('No tickets waiting')
                  : _buildWaitingTickets(context, tickets),
              loading: () => _buildWaitingSkeletonLoader(),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServingTickets(BuildContext context, List tickets) {
    return Column(
      children: tickets.map((ticket) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, Color(0xFF05236D)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ticket Number Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.ticketNumber,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: neutralWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NOW SERVING',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Window Name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.computer,
                      size: 20,
                      color: secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proceed to',
                          style: TextStyle(
                            color: neutralWhite.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ticket.windowName ?? 'Counter',
                          style: const TextStyle(
                            color: neutralWhite,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Student Info (if available)
              if (ticket.studentName != null || ticket.studentId != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: neutralWhite.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.user,
                        size: 14,
                        color: neutralWhite.withOpacity(0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ticket.studentName != null)
                              Text(
                                ticket.studentName!,
                                style: const TextStyle(
                                  color: neutralWhite,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (ticket.studentId != null)
                              Text(
                                'ID: ${ticket.studentId}',
                                style: TextStyle(
                                  color: neutralWhite.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWaitingTickets(BuildContext context, List tickets) {
    // Show only the next 6 tickets
    final displayTickets = tickets.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displayTickets.length,
      itemBuilder: (context, index) {
        final ticket = displayTickets[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                neutralWhite,
                neutralWhite.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryColor.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ticket.ticketNumber,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (ticket.studentName != null)
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.user,
                      size: 10,
                      color: textGray.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        ticket.studentName!,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              if (ticket.studentId != null) ...[
                const SizedBox(height: 4),
                Text(
                  ticket.studentId!,
                  style: TextStyle(
                    color: textGray,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            FaIcon(
              FontAwesomeIcons.clockRotateLeft,
              size: 48,
              color: textGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: textGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            const FaIcon(
              FontAwesomeIcons.triangleExclamation,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(
                color: textGray,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: textGray,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServingSkeletonLoader() {
    return Column(
      children: List.generate(2, (index) => _buildServingSkeleton()),
    );
  }

  Widget _buildServingSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Skeleton Ticket Number
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          // Skeleton Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingSkeletonLoader() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: neutralWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 24,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
