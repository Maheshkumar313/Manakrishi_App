import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  BookingProvider() {
    _initRealTimeListener();
  }

  // Set up a listener for real-time updates from Firebase
  void _initRealTimeListener() {
    _firestore
        .collection('bookings')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _bookings = snapshot.docs
          .map((doc) => Booking.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }

  List<Booking> getBookingsForUser(String userId) {
    return _bookings.where((b) => b.farmerId == userId).toList();
  }

  // Farmer Actions
  Future<void> createBooking(Booking booking) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Add a new document with an auto-generated ID
      await _firestore.collection('bookings').add(booking.toMap());
    } catch (e) {
      debugPrint("Error creating booking: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      await _firestore.collection('bookings').doc(id).delete();
    } catch (e) {
      debugPrint("Error cancelling booking: $e");
      rethrow;
    }
  }

  // Admin Actions
  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    try {
      await _firestore.collection('bookings').doc(id).update({
        'status': status.name,
      });
    } catch (e) {
      debugPrint("Error updating booking status: $e");
      rethrow;
    }
  }
}
