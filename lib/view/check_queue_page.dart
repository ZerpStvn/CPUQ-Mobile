import 'package:cpuq/models/queue/queue_ticket.dart';
import 'package:cpuq/providers/queue_providers.dart';
import 'package:cpuq/utils/global_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CheckQueuePage extends ConsumerStatefulWidget {
  const CheckQueuePage({super.key});

  @override
  ConsumerState<CheckQueuePage> createState() => _CheckQueuePageState();
}

class _CheckQueuePageState extends ConsumerState<CheckQueuePage> {
  final _formKey = GlobalKey<FormState>();
  final _ticketNumberController = TextEditingController();
  QueueTicket? _foundTicket;
  bool _isSearching = false;
  bool _searched = false;

  @override
  void dispose() {
    _ticketNumberController.dispose();
    super.dispose();
  }

  void _searchTicket() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSearching = true;
      _searched = false;
      _foundTicket = null;
    });

    final ticketNumber = _ticketNumberController.text.trim().toUpperCase();

    try {
      // Access the repository directly to search
      final repository = ref.read(queueRepositoryProvider);

      // Get streams and listen for first emission
      final servingStream = repository.streamServingTickets(departmentId: null);
      final waitingStream = repository.streamWaitingTickets(departmentId: null);

      final servingTickets = await servingStream.first;
      final waitingTickets = await waitingStream.first;

      final allTickets = [...servingTickets, ...waitingTickets];
      final ticket = allTickets.firstWhere(
        (t) => t.ticketNumber == ticketNumber,
        orElse: () => throw Exception('Ticket not found'),
      );

      if (mounted) {
        setState(() {
          _foundTicket = ticket;
          _isSearching = false;
          _searched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _foundTicket = null;
          _isSearching = false;
          _searched = true;
        });
      }
    }
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
          'Check My Queue',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.ticket,
                      color: neutralWhite,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Your Ticket Number',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find out your queue status',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: textGray,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Search Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ticket Number',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ticketNumberController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'e.g., RG-001',
                      prefixIcon: const Icon(FontAwesomeIcons.hashtag, size: 18),
                      filled: true,
                      fillColor: neutralWhite,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: textGray.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: textGray.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: primaryColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your ticket number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _searchTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: neutralWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: neutralWhite,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Check Status',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: neutralWhite,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Result Display
            if (_searched) _buildResultDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultDisplay() {
    if (_foundTicket == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: neutralWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const FaIcon(
              FontAwesomeIcons.circleXmark,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Ticket Not Found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your ticket number and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textGray,
                  ),
            ),
          ],
        ),
      );
    }

    final ticket = _foundTicket!;
    final isServing = ticket.status == 'serving';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isServing ? primaryColor : neutralWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isServing ? primaryColor.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isServing ? secondaryColor : primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isServing ? 'NOW SERVING' : 'WAITING',
              style: TextStyle(
                color: isServing ? textDark : neutralWhite,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Ticket Number
          Text(
            ticket.ticketNumber,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: isServing ? secondaryColor : primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Student Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isServing ? neutralWhite.withValues(alpha: 0.2) : backgroundGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (ticket.studentName != null)
                  _buildInfoRow(
                    'Name',
                    ticket.studentName!,
                    FontAwesomeIcons.user,
                    isServing,
                  ),
                if (ticket.studentName != null && (ticket.studentId != null || ticket.departmentName != null || ticket.windowName != null))
                  const SizedBox(height: 12),
                if (ticket.studentId != null)
                  _buildInfoRow(
                    'Student ID',
                    ticket.studentId!,
                    FontAwesomeIcons.idCard,
                    isServing,
                  ),
                if (ticket.studentId != null && (ticket.departmentName != null || ticket.windowName != null))
                  const SizedBox(height: 12),
                if (ticket.departmentName != null)
                  _buildInfoRow(
                    'Department',
                    ticket.departmentName!,
                    FontAwesomeIcons.building,
                    isServing,
                  ),
                if (ticket.departmentName != null && isServing && ticket.windowName != null)
                  const SizedBox(height: 12),
                if (isServing && ticket.windowName != null)
                  _buildInfoRow(
                    'Window',
                    ticket.windowName!,
                    FontAwesomeIcons.computer,
                    isServing,
                  ),
              ],
            ),
          ),

          if (isServing) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const FaIcon(
                    FontAwesomeIcons.bellConcierge,
                    color: textDark,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Please proceed to ${ticket.windowName ?? "the counter"}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isServing) {
    return Row(
      children: [
        FaIcon(
          icon,
          size: 16,
          color: isServing ? neutralWhite.withValues(alpha: 0.8) : textGray,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isServing ? neutralWhite.withValues(alpha: 0.7) : textGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isServing ? neutralWhite : textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
