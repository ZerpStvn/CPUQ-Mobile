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
