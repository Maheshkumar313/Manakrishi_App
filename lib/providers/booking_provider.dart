import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  final List<Booking> _bookings = [
     Booking(
      id: '1',
      farmerId: 'farmer1',
      farmerName: 'Ramesh Kumar',
      cropType: 'Rice',
      landSize: 2.5,
      sprayType: 'Pesticide',
      latitude: 16.5,
      longitude: 80.6,
      status: BookingStatus.scheduled,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Booking(
      id: '2',
      farmerId: 'farmer1',
      farmerName: 'Ramesh Kumar',
      cropType: 'Cotton',
      landSize: 5.0,
      sprayType: 'Fertilizer',
      latitude: 16.51,
      longitude: 80.62,
      status: BookingStatus.requested,
      date: DateTime.now(),
    ),
     Booking(
      id: '3',
      farmerId: 'farmer2',
      farmerName: 'Suresh Babu',
      cropType: 'Wheat',
      landSize: 3.0,
      sprayType: 'Pesticide',
      latitude: 16.52,
      longitude: 80.63,
      status: BookingStatus.requested,
      date: DateTime.now(),
    ),
  ];

  List<Booking> get bookings => _bookings;

  List<Booking> getBookingsForUser(String userId) {
    return _bookings.where((b) => b.farmerId == userId).toList();
  }

  // Farmer Actions
  Future<void> createBooking(Booking booking) async {
    await Future.delayed(const Duration(seconds: 1));
    _bookings.insert(0, booking); // Add to top
    notifyListeners();
  }

  Future<void> cancelBooking(String id) async {
     await Future.delayed(const Duration(seconds: 1));
     _bookings.removeWhere((b) => b.id == id);
     notifyListeners();
  }


  // Admin Actions
  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(status: status);
      notifyListeners();
    }
  }
}
