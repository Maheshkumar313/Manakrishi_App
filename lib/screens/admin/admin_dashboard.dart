import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/colors.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allBookings = context.watch<BookingProvider>().bookings;
    
    // Sort: Requested first, then by date
    final sortedBookings = List<Booking>.from(allBookings)..sort((a, b) {
      if (a.status == BookingStatus.requested && b.status != BookingStatus.requested) return -1;
      if (a.status != BookingStatus.requested && b.status == BookingStatus.requested) return 1;
      return b.date.compareTo(a.date);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedBookings.length,
        itemBuilder: (context, index) {
          final booking = sortedBookings[index];
          return AdminBookingCard(booking: booking);
        },
      ),
    );
  }
}

class AdminBookingCard extends StatelessWidget {
  final Booking booking;

  const AdminBookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: booking.status == BookingStatus.requested ? Colors.orange[50] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.farmerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _getStatusText(booking.status, l10n),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(booking.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("${l10n.cropType}: ${booking.cropType} | ${booking.landSize} Acres"),
            Text("${l10n.sprayType}: ${booking.sprayType}"),
            Text("Location: ${booking.latitude}, ${booking.longitude}"),
            const SizedBox(height: 16),
            
            if (booking.status == BookingStatus.requested)
              Row(
                children: [
                   Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                         context.read<BookingProvider>().updateBookingStatus(booking.id, BookingStatus.scheduled);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                      child: Text(l10n.acceptJob),
                    ),
                  ),
                  const SizedBox(width: 12),
                   Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Rejecting is just cancelling or special status? Let's say cancel/reject effectively.
                        // For this demo 'reject' is just a status update maybe or remove.
                        // Let's assume reject = cancel/delete or separate status. 
                        // Simplified: Cancel
                        context.read<BookingProvider>().cancelBooking(booking.id);
                      },
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(l10n.rejectJob),
                    ),
                  ),
                ],
              ),

             if (booking.status == BookingStatus.scheduled)
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                    onPressed: () {
                       context.read<BookingProvider>().updateBookingStatus(booking.id, BookingStatus.inProgress);
                    },
                    child: Text("Start Job"),
                  ),
               ),

             if (booking.status == BookingStatus.inProgress)
               SizedBox(
                 width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                       context.read<BookingProvider>().updateBookingStatus(booking.id, BookingStatus.completed);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text(l10n.markComplete),
                  ),
               ),
          ],
        ),
      ),
    );
  }

   Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.requested:
        return Colors.orange[800]!;
      case BookingStatus.scheduled:
        return Colors.blue[700]!;
      case BookingStatus.inProgress:
        return Colors.purple[700]!;
      case BookingStatus.completed:
        return Colors.green[700]!;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(BookingStatus status, AppLocalizations l10n) {
     switch (status) {
      case BookingStatus.requested:
        return l10n.statusRequested;
      case BookingStatus.scheduled:
        return l10n.statusScheduled;
      case BookingStatus.inProgress:
        return l10n.statusInProgress;
      case BookingStatus.completed:
        return l10n.statusCompleted;
      default:
        return l10n.unknown;
    }
  }
}
