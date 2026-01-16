import 'package:cpuq/models/queue/department.dart';
import 'package:cpuq/models/queue/queue_ticket.dart';
import 'package:cpuq/repositories/queue_repository.dart';
import 'package:cpuq/services/notification_service.dart';
import 'package:cpuq/services/saved_ticket_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository provider
final queueRepositoryProvider = Provider<QueueRepository>((ref) {
  return QueueRepository();
});

// Stream provider for serving tickets
final servingTicketsStreamProvider =
    StreamProvider.family<List<QueueTicket>, String?>((ref, departmentId) {
  final repository = ref.watch(queueRepositoryProvider);
  return repository.streamServingTickets(departmentId: departmentId);
});

// Stream provider for waiting tickets
final waitingTicketsStreamProvider =
    StreamProvider.family<List<QueueTicket>, String?>((ref, departmentId) {
  final repository = ref.watch(queueRepositoryProvider);
  return repository.streamWaitingTickets(departmentId: departmentId);
});

// Provider for the saved ticket number (sync with SharedPreferences)
final savedTicketProvider = StateProvider<String?>((ref) => null);

// Info class for tracking a specific ticket
class TrackedTicketInfo {
  final QueueTicket? ticket;
  final int? position;
  TrackedTicketInfo({this.ticket, this.position});
}

// Provider to find and track a specific ticket in real-time
final myTrackedTicketProvider = Provider.family<TrackedTicketInfo, String>((ref, ticketNumber) {
  final servingTickets = ref.watch(servingTicketsStreamProvider(null)).value ?? [];
  final waitingTickets = ref.watch(waitingTicketsStreamProvider(null)).value ?? [];
  
  final servingTicket = servingTickets.where((t) => t.ticketNumber == ticketNumber).firstOrNull;
  if (servingTicket != null) {
    return TrackedTicketInfo(ticket: servingTicket, position: null);
  }
  
  final waitingIndex = waitingTickets.indexWhere((t) => t.ticketNumber == ticketNumber);
  if (waitingIndex != -1) {
    return TrackedTicketInfo(ticket: waitingTickets[waitingIndex], position: waitingIndex + 1);
  }
  
  return TrackedTicketInfo(ticket: null, position: null);
});

// Global Notification Logic Provider
// This provider is designed to be "listened" to at the app level
final queueNotificationProvider = Provider((ref) {
  final ticketNumber = ref.watch(savedTicketProvider);
  if (ticketNumber == null) return;

  // Track state to avoid duplicate notifications
  String? lastNotifiedStatus;
  int? lastNotifiedPosition;

  ref.listen<TrackedTicketInfo>(myTrackedTicketProvider(ticketNumber), (previous, next) {
    if (next.ticket == null) return;

    final ticket = next.ticket!;
    final position = next.position;

    // 1. Check for Serving Status
    if (ticket.status == 'serving' && lastNotifiedStatus != 'serving') {
      lastNotifiedStatus = 'serving';
      NotificationService().showNowServingNotification(
        ticketNumber: ticket.ticketNumber,
        windowName: ticket.windowName ?? 'Counter',
      );
    } 
    // 2. Check for Position Updates
    else if (position != null && position != lastNotifiedPosition) {
      if (position == 1) {
        lastNotifiedPosition = 1;
        NotificationService().showNextInLineNotification(ticketNumber: ticket.ticketNumber);
      } else if (position <= 3) {
        lastNotifiedPosition = position;
        NotificationService().showPositionUpdateNotification(
          ticketNumber: ticket.ticketNumber,
          position: position,
        );
      }
    }
  });
});

// Stream provider for departments
final departmentsStreamProvider = StreamProvider<List<Department>>((ref) {
  final repository = ref.watch(queueRepositoryProvider);
  return repository.streamDepartments();
});

// Future provider for departments
final departmentsProvider = FutureProvider<List<Department>>((ref) {
  final repository = ref.watch(queueRepositoryProvider);
  return repository.getDepartments();
});
