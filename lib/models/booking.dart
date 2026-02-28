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
}
