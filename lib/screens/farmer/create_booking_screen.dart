import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../core/colors.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../login_screen.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _landSizeController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedCrop;
  String? _selectedSprayType;
  DateTime? _selectedDate;
  Position? _currentPosition;
  bool _isGettingLocation = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _landSizeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permissions are permanently denied, we cannot request permissions.')),
        );
        return;
      }

      // For emulator/testing if real GPS fails or is slow
      // Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

      // Mocking location for stability in demo environment if geolocator fails or takes too long
      // In production, use the real call above.
      await Future.delayed(const Duration(seconds: 1));
      Position position = Position(
        longitude: 80.64,
        latitude: 16.54,
        timestamp: DateTime.now(),
        accuracy: 10,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.earthBrown,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitBooking() async {
    final hasLocation = _currentPosition != null;
    final hasAddress = _addressController.text.trim().isNotEmpty;

    if (_formKey.currentState!.validate() && (hasLocation || hasAddress)) {
      if (_selectedCrop == null ||
          _selectedSprayType == null ||
          _selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please select all options and pick a date')),
        );
        return;
      }

      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        // Show login screen first and wait for success
        final bool loginSuccess = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LoginScreen(returnOnSuccess: true),
              ),
            ) ??
            false;

        if (!loginSuccess || !mounted)
          return; // User cancelled login or unmounted
      }

      setState(() {
        _isSubmitting = true;
      });

      // Fetch the updated auth state if they just logged in
      final updatedAuth = context.read<AuthProvider>();
      final user = updatedAuth.currentUser;

      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        farmerId: user?.id ?? 'temp_id',
        farmerName: user?.name ?? 'Farmer', // Get name from actual profile
        cropType: _selectedCrop!,
        landSize: double.parse(_landSizeController.text),
        sprayType: _selectedSprayType!,
        address: hasAddress ? _addressController.text.trim() : null,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        status: BookingStatus.requested,
        date: _selectedDate!,
      );

      await context.read<BookingProvider>().createBooking(booking);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking Submitted Successfully!')),
        );
      }
    } else if (!hasLocation && !hasAddress) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please capture location or enter address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final crops = [
      l10n.rice,
      l10n.wheat,
      l10n.cotton,
      "Sugarcane",
      "Maize",
      "Chilli",
      "Mango",
      "Groundnut",
      "Turmeric"
    ];

    // Map visual display names to internal values if needed,
    // but for simplicity we store the display name here or English key.
    // Better practice: Store key, display localized.
    // Here we will just use the localized string for storage/display for simplicity in this demo.

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Header
            Container(
              height: 220,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/service_tech_indian.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.all(24.0),
                alignment: Alignment.bottomLeft,
                child: Text(
                  l10n.bookingFormTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Crop Dropdown
                    Text(l10n.cropType,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.earthBrown)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCrop,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        prefixIcon:
                            Icon(Icons.grass, color: AppColors.primaryGreen),
                      ),
                      hint: Text(l10n.selectCrop),
                      items:
                          crops.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCrop = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Land Size
                    CustomTextField(
                      label: l10n.landSize,
                      controller: _landSizeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Icon(Icons.square_foot,
                          color: AppColors.primaryGreen),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return l10n.requiredField;
                        if (double.tryParse(value) == null)
                          return "Invalid number";
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Date of Visit
                    Text("Date of Visit",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.earthBrown)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedDate == null
                                  ? "Select preferred date"
                                  : DateFormat.yMMMd().format(_selectedDate!),
                              style: TextStyle(
                                  fontSize: _selectedDate == null ? 14 : 16,
                                  color: _selectedDate == null
                                      ? Colors.black54
                                      : Colors.black87),
                            ),
                            const Icon(Icons.calendar_month,
                                color: AppColors.primaryGreen),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Spray Type
                    Text(l10n.sprayType,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.earthBrown)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: [
                          RadioListTile<String>(
                            title: Text(l10n.pesticide),
                            value: 'Pesticide',
                            activeColor: AppColors.primaryGreen,
                            groupValue: _selectedSprayType,
                            secondary: const Icon(Icons.bug_report,
                                color: AppColors.textGrey),
                            onChanged: (value) {
                              setState(() {
                                _selectedSprayType = value;
                              });
                            },
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          RadioListTile<String>(
                            title: Text(l10n.fertilizer),
                            value: 'Fertilizer',
                            activeColor: AppColors.primaryGreen,
                            groupValue: _selectedSprayType,
                            secondary: const Icon(Icons.eco,
                                color: AppColors.textGrey),
                            onChanged: (value) {
                              setState(() {
                                _selectedSprayType = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Location Capture
                    Text("Farm Location",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.earthBrown)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4))
                          ]),
                      child: Column(
                        children: [
                          if (_currentPosition != null) ...[
                            const Icon(Icons.check_circle,
                                color: AppColors.primaryGreen, size: 48),
                            const SizedBox(height: 8),
                            Text(l10n.locationCaptured,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                    fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              "Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}",
                              style:
                                  const TextStyle(color: AppColors.earthBrown),
                            ),
                          ] else ...[
                            Icon(Icons.location_on_outlined,
                                color: AppColors.primaryGreen.withOpacity(0.6),
                                size: 48),
                            const SizedBox(height: 8),
                            Text(l10n.getLocation,
                                style: TextStyle(
                                    color:
                                        AppColors.earthBrown.withOpacity(0.8))),
                          ],
                          const SizedBox(height: 16),
                          if (_currentPosition == null)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isGettingLocation
                                    ? null
                                    : _getCurrentLocation,
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(
                                      color: AppColors.primaryGreen),
                                  foregroundColor: AppColors.primaryGreen,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: _isGettingLocation
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primaryGreen))
                                    : const Icon(Icons.my_location),
                                label: Text(_isGettingLocation
                                    ? l10n.loading
                                    : l10n.getLocation),
                              ),
                            ),
                          if (_currentPosition == null) ...[
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text("OR",
                                      style: TextStyle(
                                          color: AppColors.textGrey,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (_currentPosition == null)
                            CustomTextField(
                              label: "Enter Address Manually",
                              controller: _addressController,
                              prefixIcon: const Icon(Icons.edit_location_alt,
                                  color: AppColors.primaryGreen),
                              validator: (value) {
                                if (_currentPosition == null &&
                                    (value == null || value.trim().isEmpty)) {
                                  return "Required if location not captured";
                                }
                                return null;
                              },
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    CustomButton(
                      text: l10n.submitBooking,
                      isLoading: _isSubmitting,
                      onPressed: () {
                        // Allow button press, validation will handle the logic
                        _submitBooking();
                      },
                    ),
                    if (_currentPosition == null &&
                        _addressController.text.trim().isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          " * Location or Address required to submit",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
