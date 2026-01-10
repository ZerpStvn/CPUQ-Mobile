import 'package:shared_preferences/shared_preferences.dart';

class SavedTicketService {
  static const String _ticketNumberKey = 'saved_ticket_number';
  static const String _savedDateKey = 'saved_ticket_date';

  // Save ticket number with current date
  static Future<void> saveTicketNumber(String ticketNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month}-${now.day}';

    await prefs.setString(_ticketNumberKey, ticketNumber.toUpperCase());
    await prefs.setString(_savedDateKey, dateStr);
  }

  // Get saved ticket number (returns null if expired)
  static Future<String?> getSavedTicketNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final ticketNumber = prefs.getString(_ticketNumberKey);
    final savedDate = prefs.getString(_savedDateKey);

    if (ticketNumber == null || savedDate == null) {
      return null;
    }

    // Check if saved date is today
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';

    if (savedDate != todayStr) {
      // Clear expired ticket
      await clearSavedTicket();
      return null;
    }

    return ticketNumber;
  }

  // Clear saved ticket
  static Future<void> clearSavedTicket() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ticketNumberKey);
    await prefs.remove(_savedDateKey);
  }

  // Check if ticket is saved
  static Future<bool> hasTicketSaved() async {
    final ticket = await getSavedTicketNumber();
    return ticket != null;
  }
}
