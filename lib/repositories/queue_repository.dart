import 'package:cpuq/models/queue/department.dart';
import 'package:cpuq/models/queue/queue_ticket.dart';
import 'package:cpuq/services/supabase_service.dart';

class QueueRepository {
  final _supabase = SupabaseService.client;

  // Stream serving tickets for a specific department or all departments
  Stream<List<QueueTicket>> streamServingTickets({String? departmentId}) async* {
    // We stream tickets with a broader filter and sort descending by called_at
    // Using descending here to keep the most recently called tickets at the top
    await for (final data in _supabase
        .from('queue_tickets')
        .stream(primaryKey: ['id'])
        .order('called_at', ascending: false)) {
      try {
        // Filter locally for 'serving' status to ensure real-time removal
        // when status transitions to 'completed' or 'waiting'
        var servingData = data.where((json) => json['status'] == 'serving').toList();

        // Further filter by department if departmentId is provided
        if (departmentId != null) {
          servingData = servingData.where((json) => json['department_id'] == departmentId).toList();
        }

        var tickets = <QueueTicket>[];

        for (var json in servingData) {
          try {
            // Fetch window name if window_id exists
            // Optimization: In a production app, window names should be cached or joined
            // but since .stream() doesn't support joins, we fetch it here.
            if (json['window_id'] != null) {
              final windowData = await _supabase
                  .from('windows')
                  .select('name')
                  .eq('id', json['window_id'])
                  .maybeSingle();

              if (windowData != null) {
                json['window_name'] = windowData['name'];
              }
            }

            tickets.add(QueueTicket.fromJson(json));
          } catch (e) {
            print('Error parsing ticket: $e');
            continue; // Skip failed tickets instead of breaking the stream
          }
        }

        yield tickets;
      } catch (e) {
        print('Error in streamServingTickets: $e');
        // Don't rethrow to keep the stream alive
      }
    }
  }

  // Stream waiting tickets for a specific department or all departments
  Stream<List<QueueTicket>> streamWaitingTickets({String? departmentId}) async* {
    await for (final data in _supabase
        .from('queue_tickets')
        .stream(primaryKey: ['id'])
        .eq('status', 'waiting')
        .order('created_at', ascending: true)) {
      try {
        var tickets = <QueueTicket>[];

        for (var json in data) {
          try {
            // Fetch window name if window_id exists (usually null for waiting)
            if (json['window_id'] != null) {
              final windowData = await _supabase
                  .from('windows')
                  .select('name')
                  .eq('id', json['window_id'])
                  .maybeSingle();

              if (windowData != null) {
                json['window_name'] = windowData['name'];
              }
            }

            tickets.add(QueueTicket.fromJson(json));
          } catch (e) {
            print('Error parsing ticket: $e');
            continue;
          }
        }

        // Filter by department if departmentId is provided
        if (departmentId != null) {
          tickets = tickets.where((ticket) => ticket.departmentId == departmentId).toList();
        }

        yield tickets;
      } catch (e) {
        print('Error in streamWaitingTickets: $e');
      }
    }
  }

  // Get all departments
  Future<List<Department>> getDepartments() async {
    final response = await _supabase
        .from('departments')
        .select()
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map((json) => Department.fromJson(json))
        .toList();
  }

  // Stream all departments
  Stream<List<Department>> streamDepartments() {
    return _supabase
        .from('departments')
        .stream(primaryKey: ['id'])
        .eq('is_active', true)
        .order('name')
        .map((data) {
      return data.map((json) => Department.fromJson(json)).toList();
    });
  }
}
