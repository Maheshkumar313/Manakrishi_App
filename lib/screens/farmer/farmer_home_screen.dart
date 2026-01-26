import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import 'create_booking_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.redirectPath == '/create_booking') {
        auth.clearRedirectPath();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateBookingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _FarmerHomeContent();
  }
}

class _FarmerHomeContent extends StatelessWidget {
  const _FarmerHomeContent();

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.requested:
        return Colors.orange;
      case BookingStatus.scheduled:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;
    final bookings =
        context.watch<BookingProvider>().getBookingsForUser(user?.id ?? '');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(l10n.appTitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    shadows: [
                      const Shadow(color: Colors.black45, blurRadius: 4)
                    ],
                  )),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/home_drone.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(
                              0.3), // Darker top for white text visibility
                          Colors.transparent,
                          AppColors.primaryGreen.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                onPressed: () {
                  context.read<LanguageProvider>().toggleLanguage();
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  context.read<AuthProvider>().logout();
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny,
                          color: AppColors.accentYellow, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        "Welcome, Farmer!", // localize later if needed
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.earthBrown,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Card
                  Card(
                    elevation: 8,
                    shadowColor: AppColors.primaryGreen.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                    color: AppColors.primaryGreen,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CreateBookingScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen,
                                AppColors.secondaryGreen
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_circle_outline,
                                  color: Colors.white, size: 36),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.bookServiceBtn,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    "Schedule a drone spray", // localize later
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white70, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Your Bookings", // localize later
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.earthBrown),
                  ),
                ],
              ),
            ),
          ),

          if (bookings.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.agriculture_rounded,
                        size: 80, color: AppColors.lightGreen.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(l10n.noBookings,
                        style: const TextStyle(
                            color: AppColors.textGrey, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text("Your upcoming spray tasks will appear here",
                        style:
                            TextStyle(color: AppColors.textGrey, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final booking = bookings[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: Card(
                      elevation: 3,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      surfaceTintColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 16,
                                        color: AppColors.primaryGreen),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat.yMMMd().format(booking.date),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textBlack),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(booking.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: _getStatusColor(booking.status)
                                            .withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    _getStatusText(booking.status, l10n),
                                    style: TextStyle(
                                      color: _getStatusColor(booking.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32, thickness: 0.5),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildInfoItem(
                                        context,
                                        l10n.cropType,
                                        booking.cropType,
                                        Icons.grass)),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.grey.withOpacity(0.2)),
                                Expanded(
                                    child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: _buildInfoItem(
                                      context,
                                      l10n.landSize,
                                      "${booking.landSize} Acres",
                                      Icons.square_foot),
                                )),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(12)),
                                child: _buildInfoItem(context, l10n.sprayType,
                                    booking.sprayType, Icons.water_drop)),
                            if (booking.status == BookingStatus.requested)
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      context
                                          .read<BookingProvider>()
                                          .cancelBooking(booking.id);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.errorRed,
                                      side: const BorderSide(
                                          color: AppColors.errorRed),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    child: Text(l10n.cancelBooking),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: bookings.length,
              ),
            ),

          const SliverToBoxAdapter(
              child: SizedBox(height: 80)), // Bottom padding
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateBookingScreen()),
          );
        },
        backgroundColor: AppColors.accentYellow,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textGrey),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textGrey)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
