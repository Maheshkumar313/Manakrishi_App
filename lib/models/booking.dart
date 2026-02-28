enum BookingStatus { requested, scheduled, inProgress, completed, unknown }

class Booking {
  final String id;
  final String farmerId;
  final String farmerName;
  final String cropType;
  final double landSize;
  final String sprayType;
  final String? address;
  final double? latitude;
  final double? longitude;
  final BookingStatus status;
  final DateTime date;

  Booking({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.cropType,
    required this.landSize,
    required this.sprayType,
    this.address,
    this.latitude,
    this.longitude,
    required this.status,
    required this.date,
  });

  Booking copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? cropType,
    double? landSize,
    String? sprayType,
    String? address,
    double? latitude,
    double? longitude,
    BookingStatus? status,
    DateTime? date,
  }) {
    return Booking(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      cropType: cropType ?? this.cropType,
      landSize: landSize ?? this.landSize,
      sprayType: sprayType ?? this.sprayType,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }

  // Save to Firebase
  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'cropType': cropType,
      'landSize': landSize,
      'sprayType': sprayType,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name, // Save enum as string
      'date': date.toIso8601String(), // Save DateTime as string
    };
  }

  // Load from Firebase
  factory Booking.fromMap(Map<String, dynamic> map, String documentId) {
    return Booking(
      id: documentId,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      cropType: map['cropType'] ?? '',
      landSize: (map['landSize'] ?? 0).toDouble(),
      sprayType: map['sprayType'] ?? '',
      address: map['address'],
      latitude: map['latitude'] != null ? (map['latitude']).toDouble() : null,
      longitude:
          map['longitude'] != null ? (map['longitude']).toDouble() : null,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BookingStatus.unknown,
      ),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }
}
