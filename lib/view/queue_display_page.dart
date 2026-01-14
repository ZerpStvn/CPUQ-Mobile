import 'dart:async';
import 'package:cpuq/models/queue/queue_ticket.dart';
import 'package:cpuq/providers/queue_providers.dart';
import 'package:cpuq/services/notification_service.dart';
import 'package:cpuq/services/saved_ticket_service.dart';
import 'package:cpuq/utils/global_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/services.dart';

// Added to format the text enter to all caps January 14, 2025
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class QueueDisplayPage extends ConsumerStatefulWidget {
  const QueueDisplayPage({super.key});

  @override
  ConsumerState<QueueDisplayPage> createState() => _QueueDisplayPageState();
}

class _QueueDisplayPageState extends ConsumerState<QueueDisplayPage> {
  final _ticketInputController = TextEditingController();
  String? _savedTicketNumber;

  // Notification tracking (local state to avoid repeating notifications)
  String? _lastNotifiedStatus;
  int? _lastNotifiedPosition;

  @override
  void initState() {
    super.initState();
    _loadSavedTicket();
  }

  @override
  void dispose() {
    _ticketInputController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedTicket() async {
    final savedTicket = await SavedTicketService.getSavedTicketNumber();
    if (mounted) {
      setState(() {
        _savedTicketNumber = savedTicket;
      });
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ticket $ticketNumber saved. You\'ll be notified when it\'s your turn!'),
          backgroundColor: primaryColor,
        ),
      );
    }
  }

  Future<void> _clearSavedTicket() async {
    await SavedTicketService.clearSavedTicket();
    await NotificationService().cancelAll();
    setState(() {
      _savedTicketNumber = null;
      _lastNotifiedStatus = null;
      _lastNotifiedPosition = null;
    });
  }

  // Handle notifications based on real-time ticket info
  void _handleNotifications(TrackedTicketInfo info) {
    if (_savedTicketNumber == null || info.ticket == null) return;

    final ticket = info.ticket!;
    final position = info.position;

    // Check serving status
    if (ticket.status == 'serving') {
      if (_lastNotifiedStatus != 'serving') {
        _lastNotifiedStatus = 'serving';
        NotificationService().showNowServingNotification(
          ticketNumber: ticket.ticketNumber,
          windowName: ticket.windowName ?? 'Counter',
        );
      }
      return;
    }

    // Check waiting position
    if (position != null) {
      if (position == 1 && _lastNotifiedPosition != 1) {
        _lastNotifiedPosition = 1;
        NotificationService().showNextInLineNotification(
          ticketNumber: ticket.ticketNumber,
        );
      } else if (position > 1 && position <= 3 && _lastNotifiedPosition != position) {
        _lastNotifiedPosition = position;
        NotificationService().showPositionUpdateNotification(
          ticketNumber: ticket.ticketNumber,
          position: position,
        );
      }
    }
  }

  Widget _buildMyTicketInput() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
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
                  color: primaryColor.withValues(alpha: 0.1),
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
                  inputFormatters: [UpperCaseTextFormatter()],
                  decoration: InputDecoration(
                    hintText: 'Enter ticket number (e.g., BUSS-004)',
                    hintStyle: TextStyle(
                      fontSize: 12,
                      color: textGray.withValues(alpha: 0.6),
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

  Widget _buildMyTicketCard(QueueTicket ticket, int? position) {
    final isServing = ticket.status == 'serving';

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
            color: (isServing ? primaryColor : secondaryColor).withValues(alpha: 0.3),
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
                          ? neutralWhite.withValues(alpha: 0.8)
                          : textDark.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ticket.ticketNumber,
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
                          : neutralWhite.withValues(alpha: 0.3),
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
                          ? neutralWhite.withValues(alpha: 0.7)
                          : textDark.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isServing && ticket.windowName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: secondaryColor.withValues(alpha: 0.2),
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
                          color: neutralWhite.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        ticket.windowName!,
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
          ] else if (!isServing && position != null) ...[
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildTicketNotFoundCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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

  @override
  Widget build(BuildContext context) {
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),
      body: Column(
        children: [
          // My Ticket Section (Real-time)
          if (_savedTicketNumber != null)
            Consumer(
              builder: (context, ref, child) {
                final info = ref.watch(myTrackedTicketProvider(_savedTicketNumber!));
                
                // Trigger notifications here based on state changes
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handleNotifications(info);
                });

                if (info.ticket != null) {
                  return _buildMyTicketCard(info.ticket!, info.position);
                }
                return _buildTicketNotFoundCard();
              },
            )
          else
            _buildMyTicketInput(),

          // Queue Display
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                String? deptId;
                if (_savedTicketNumber != null) {
                  deptId = ref.watch(myTrackedTicketProvider(_savedTicketNumber!)).ticket?.departmentId;
                }
                return _buildQueueDisplay(context, ref, deptId);
              },
            ),
          ),
        ],
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

            const SizedBox(height: 32),

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

  Widget _buildServingTickets(BuildContext context, List<QueueTicket> tickets) {
    // Arrange order by called_at desc
    final sortedTickets = [...tickets];
    sortedTickets.sort((a, b) {
      if (a.calledAt == null && b.calledAt == null) return 0;
      if (a.calledAt == null) return 1;
      if (b.calledAt == null) return -1;
      return b.calledAt!.compareTo(a.calledAt!);
    });

    return Container(
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Text(
                    'WINDOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'TICKET',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Data Rows
          ...sortedTickets.map((ticket) {
            final isLast = sortedTickets.indexOf(ticket) == sortedTickets.length - 1;
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: backgroundGray,
                          width: 1,
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      ticket.windowName ?? 'Counter',
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      ticket.ticketNumber,
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWaitingTickets(BuildContext context, List tickets) {
    // Show only the next 10 tickets
    final displayTickets = tickets.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayTickets.length,
        separatorBuilder: (context, index) => Divider(
          color: backgroundGray,
          height: 1,
          indent: 20,
          endIndent: 20,
        ),
        itemBuilder: (context, index) {
          final ticket = displayTickets[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              ticket.ticketNumber,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            subtitle: ticket.studentName != null 
              ? Text(ticket.studentName!, style: const TextStyle(color: textGray, fontSize: 13)) 
              : null,
            trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
          );
        },
      ),
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
              color: textGray.withValues(alpha: 0.5),
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
    return Container(
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),
          ...List.generate(2, (index) => Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(child: Container(height: 20, color: Colors.grey[200])),
                const SizedBox(width: 20),
                Expanded(child: Container(height: 20, color: Colors.grey[200])),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWaitingSkeletonLoader() {
    return Container(
      decoration: BoxDecoration(
        color: neutralWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(color: backgroundGray, height: 1),
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(backgroundColor: Colors.grey[200]),
          title: Container(height: 16, width: 80, color: Colors.grey[200]),
          subtitle: Container(height: 12, width: 120, color: Colors.grey[100]),
        ),
      ),
    );
  }
}
