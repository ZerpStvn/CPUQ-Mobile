import 'package:cpuq/models/queue/department.dart';
import 'package:cpuq/models/queue/queue_ticket.dart';
import 'package:cpuq/repositories/queue_repository.dart';
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
