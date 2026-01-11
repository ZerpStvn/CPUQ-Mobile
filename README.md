# CPU Queue Mobile App

A Flutter mobile application for Central Philippine University (CPU) that provides real-time queue management system integration, allowing students to monitor queue status and track their tickets.

## Features

- **Real-time Queue Display**: View currently serving and waiting tickets with live updates via Supabase streaming
- **Department Filtering**: Filter queue by department (Registrar, Business, etc.)
- **Track My Ticket**: Save your ticket number and monitor your status in real-time
- **Auto-clearing Tickets**: Saved tickets automatically clear at midnight
- **Check Queue**: Search for any ticket number to check its status
- **Modern UI**: Clean, card-based design with CPU brand colors

## Screenshots

The app features a blue and gold color scheme reflecting CPU's official branding:
- Primary Color: `#03236D` (CPU Blue)
- Secondary Color: `#FFB800` (CPU Gold)

## Tech Stack

- **Flutter** (SDK ^3.10.4) - Cross-platform mobile framework
- **Dart** - Programming language
- **Supabase** - Backend-as-a-Service (Real-time database)
- **Riverpod** - State management
- **SharedPreferences** - Local storage for ticket persistence

## Prerequisites

Before running this project, ensure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (^3.10.4 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code with Flutter extensions
- A Supabase account and project

## Installation

### 1. Clone the Repository

```bash
git clone <repository-url>
cd cpuq
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Create a `.env` file in the root directory with your Supabase credentials:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4. Run the App

```bash
# For debug mode
flutter run

# For release mode
flutter run --release

# For specific device
flutter run -d <device_id>
```

## Project Structure

```
lib/
├── main.dart                    # App entry point with Supabase initialization
├── models/
│   ├── announcement.dart        # Announcement data model
│   ├── service_item.dart        # Service item data model
│   └── queue/
│       ├── department.dart      # Department model
│       └── queue_ticket.dart    # Queue ticket model with JSON parsing
├── providers/
│   └── queue_providers.dart     # Riverpod providers for queue state management
├── repositories/
│   └── queue_repository.dart    # Data layer for Supabase queue operations
├── services/
│   ├── supabase_service.dart    # Supabase client initialization
│   └── saved_ticket_service.dart # SharedPreferences ticket persistence
├── utils/
│   └── global_theme.dart        # App-wide colors and theme constants
├── view/
│   ├── homepge.dart             # Home page with services grid
│   ├── queue_display_page.dart  # Real-time queue display
│   ├── check_queue_page.dart    # Ticket search page
│   ├── services_page.dart       # Services listing
│   ├── alerts_page.dart         # Notifications/alerts page
│   └── profile_page.dart        # User profile page
└── widgets/
    └── coming_soon_dialog.dart  # Reusable coming soon dialog
```

## Database Schema (Supabase)

### Tables Required

#### `queue_tickets`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| ticket_number | text | Ticket identifier (e.g., BUSS-004) |
| status | text | 'waiting', 'serving', 'completed' |
| department_id | uuid | Foreign key to departments |
| window_id | uuid | Foreign key to windows (nullable) |
| student_name | text | Student name (nullable for walk-ins) |
| student_id | text | Student ID (nullable for walk-ins) |
| created_at | timestamp | When ticket was created |
| called_at | timestamp | When ticket was called |

#### `departments`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| name | text | Department name |
| code | text | Department code (e.g., BUSS, REG) |
| is_active | boolean | Whether department is active |

#### `windows`
| Column | Type | Description |
|--------|------|-------------|
| id | uuid | Primary key |
| name | text | Window name (e.g., Window 15) |
| department_id | uuid | Foreign key to departments |

## Key Components

### Queue Display Page
The main queue monitoring interface featuring:
- Department filter chips
- "Track My Ticket" input card
- Now Serving section with gradient cards
- Next in Line waiting tickets grid
- Skeleton loading states

### Saved Ticket Service
Manages ticket persistence with automatic expiration:
```dart
// Save ticket (clears at midnight)
SavedTicketService.saveTicketNumber('BUSS-004');

// Get saved ticket (returns null if expired)
final ticket = await SavedTicketService.getSavedTicketNumber();

// Clear saved ticket
SavedTicketService.clearSavedTicket();
```

### Queue Repository
Handles real-time data streaming with window name resolution:
- `streamServingTickets()` - Stream currently serving tickets
- `streamWaitingTickets()` - Stream waiting tickets
- `streamDepartments()` - Stream active departments

## State Management

The app uses Riverpod for state management:

```dart
// Stream providers for real-time data
final servingTicketsStreamProvider = StreamProvider.family<List<QueueTicket>, String?>();
final waitingTicketsStreamProvider = StreamProvider.family<List<QueueTicket>, String?>();
final departmentsStreamProvider = StreamProvider<List<Department>>();

// State provider for selected department filter
final selectedDepartmentProvider = StateProvider<String?>();
```

## Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Supabase Connection Error**
   - Verify `.env` file exists with correct credentials
   - Check internet connectivity
   - Ensure Supabase project RLS policies allow read access

2. **Tickets Not Updating**
   - Verify Supabase Realtime is enabled for `queue_tickets` table
   - Check browser console for WebSocket errors

3. **Window Names Showing "Counter"**
   - Ensure `windows` table has data
   - Verify `window_id` in tickets references valid window records

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -m 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## License

This project is proprietary software for Central Philippine University.

## Contact

For questions or support, contact the CPU IT Department.
