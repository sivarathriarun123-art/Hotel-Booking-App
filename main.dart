import 'package:flutter/material.dart';

void main() => runApp(const HotelBookingApp());

class HotelBookingApp extends StatelessWidget {
  const HotelBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StayEase - Hotel Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176B65)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class Hotel {
  final String name, location, description;
  final int price, rating;
  final IconData icon;
  const Hotel(this.name, this.location, this.description, this.price, this.rating, this.icon);
}

const hotels = <Hotel>[
  Hotel('The Grand Palace', 'Hyderabad, Telangana', 'Elegant rooms, city views and complimentary breakfast.', 3499, 5, Icons.apartment),
  Hotel('Green Leaf Residency', 'Warangal, Telangana', 'Comfortable stay close to popular local attractions.', 1899, 4, Icons.park),
  Hotel('Lakeview Suites', 'Vijayawada, Andhra Pradesh', 'Modern suites designed for families and business trips.', 2799, 4, Icons.water),
  Hotel('Royal Comfort Inn', 'Visakhapatnam, Andhra Pradesh', 'Relaxing rooms with easy access to the beach.', 2299, 4, Icons.king_bed),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  DateTime checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime checkOut = DateTime.now().add(const Duration(days: 2));
  int guests = 2;
  String query = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> chooseDate(bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? checkIn : checkOut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isCheckIn) {
        checkIn = picked;
        if (!checkOut.isAfter(checkIn)) checkOut = checkIn.add(const Duration(days: 1));
      } else if (picked.isAfter(checkIn)) {
        checkOut = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleHotels = hotels.where((h) =>
      h.name.toLowerCase().contains(query.toLowerCase()) ||
      h.location.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('StayEase', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Booking history',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF176B65), Color(0xFF2E9183)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Find your perfect stay', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Comfort, convenience and great memories.', style: TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: searchController,
            onChanged: (v) => setState(() => query = v),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search city or hotel'),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _DateTile(label: 'CHECK-IN', date: checkIn, onTap: () => chooseDate(true))),
            const SizedBox(width: 10),
            Expanded(child: _DateTile(label: 'CHECK-OUT', date: checkOut, onTap: () => chooseDate(false))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.people_alt_outlined),
            const SizedBox(width: 8),
            const Text('Guests', style: TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            IconButton(onPressed: guests > 1 ? () => setState(() => guests--) : null, icon: const Icon(Icons.remove_circle_outline)),
            Text('$guests', style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(onPressed: guests < 8 ? () => setState(() => guests++) : null, icon: const Icon(Icons.add_circle_outline)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Text('Recommended hotels', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${visibleHotels.length} found', style: TextStyle(color: Colors.grey.shade600)),
          ]),
          const SizedBox(height: 8),
          if (visibleHotels.isEmpty)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No hotels found. Try another search.'))),
          ...visibleHotels.map((hotel) => _HotelCard(
            hotel: hotel,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HotelDetailsScreen(
              hotel: hotel, checkIn: checkIn, checkOut: checkOut, guests: guests,
            ))),
          )),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DateTile({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Row(children: [const Icon(Icons.calendar_month, size: 17), const SizedBox(width: 6), Expanded(child: Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontWeight: FontWeight.w600)))]),
      ]),
    ),
  );
}

class _HotelCard extends StatelessWidget {
  final Hotel hotel;
  final VoidCallback onTap;
  const _HotelCard({required this.hotel, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(vertical: 7),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 105, width: double.infinity,
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFD8ECE8), Color(0xFFB4D7D1)])),
          child: Icon(hotel.icon, size: 56, color: const Color(0xFF176B65)),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(hotel.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
              const Icon(Icons.star, color: Colors.amber, size: 18),
              Text('${hotel.rating}.0'),
            ]),
            const SizedBox(height: 5),
            Row(children: [const Icon(Icons.location_on_outlined, size: 16), const SizedBox(width: 4), Expanded(child: Text(hotel.location, style: TextStyle(color: Colors.grey.shade700)))]),
            const SizedBox(height: 10),
            Row(children: [
              Text('₹${hotel.price}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF176B65))),
              const Text(' / night', style: TextStyle(color: Colors.grey)),
              const Spacer(),
              const Text('View details  ›', style: TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

class HotelDetailsScreen extends StatelessWidget {
  final Hotel hotel;
  final DateTime checkIn, checkOut;
  final int guests;
  const HotelDetailsScreen({super.key, required this.hotel, required this.checkIn, required this.checkOut, required this.guests});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Hotel details')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      Container(height: 190, decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFFD8ECE8), Color(0xFF9BCBC2)]),
      ), child: Icon(hotel.icon, size: 90, color: const Color(0xFF176B65))),
      const SizedBox(height: 18),
      Text(hotel.name, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text(hotel.location, style: TextStyle(color: Colors.grey.shade700)),
      const SizedBox(height: 12),
      Row(children: [const Icon(Icons.star, color: Colors.amber), Text(' ${hotel.rating}.0 rating  •  ${guests} guests')]),
      const SizedBox(height: 16),
      const Text('About this stay', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text(hotel.description),
      const SizedBox(height: 16),
      ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_month), title: const Text('Your dates'), subtitle: Text('${checkIn.day}/${checkIn.month}/${checkIn.year} – ${checkOut.day}/${checkOut.month}/${checkOut.year}')),
      ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.wifi), title: const Text('Amenities'), subtitle: const Text('Wi-Fi • Air conditioning • Room service')),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFormScreen(hotel: hotel, checkIn: checkIn, checkOut: checkOut, guests: guests))),
        child: Text('Book now • ₹${hotel.price}/night'),
      ),
    ]),
  );
}

class BookingFormScreen extends StatefulWidget {
  final Hotel hotel;
  final DateTime checkIn, checkOut;
  final int guests;
  const BookingFormScreen({super.key, required this.hotel, required this.checkIn, required this.checkOut, required this.guests});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose(); emailController.dispose(); phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nights = widget.checkOut.difference(widget.checkIn).inDays.clamp(1, 365);
    final total = widget.hotel.price * nights;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: Form(
        key: formKey,
        child: ListView(padding: const EdgeInsets.all(18), children: [
          Text(widget.hotel.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          Text('$nights night(s) • ${widget.guests} guest(s)'),
          const SizedBox(height: 18),
          TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null),
          const SizedBox(height: 12),
          TextFormField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address'), validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
          const SizedBox(height: 12),
          TextFormField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number'), validator: (v) => v == null || v.trim().length < 10 ? 'Enter a valid phone number' : null),
          const SizedBox(height: 20),
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            const Expanded(child: Text('Estimated total', style: TextStyle(fontWeight: FontWeight.bold))),
            Text('₹$total', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF176B65))),
          ]))),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingConfirmationScreen(
                hotel: widget.hotel, guestName: nameController.text.trim(), email: emailController.text.trim(),
                nights: nights, total: total,
              )));
            },
            child: const Text('Confirm booking'),
          ),
        ]),
      ),
    );
  }
}

class BookingConfirmationScreen extends StatelessWidget {
  final Hotel hotel;
  final String guestName, email;
  final int nights, total;
  const BookingConfirmationScreen({super.key, required this.hotel, required this.guestName, required this.email, required this.nights, required this.total});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Booking confirmation'), automaticallyImplyLeading: false),
    body: Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_circle, color: Color(0xFF21866D), size: 86),
        const SizedBox(height: 16),
        const Text('Booking confirmed!', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Thank you, $guestName. Your demo booking has been recorded on this screen.'),
        const SizedBox(height: 18),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hotel.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Guest: $guestName'),
          Text('Email: $email'),
          Text('Duration: $nights night(s)'),
          Text('Total: ₹$total', style: const TextStyle(fontWeight: FontWeight.bold)),
        ]))),
        const SizedBox(height: 18),
        FilledButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (_) => false), child: const Text('Back to home')),
      ]),
    )),
  );
}

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Booking history')),
    body: const Center(child: Padding(
      padding: EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.history, size: 64, color: Color(0xFF176B65)),
        SizedBox(height: 14),
        Text('No saved bookings yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('This lab demo shows the booking confirmation during the current session. Persistent booking history or online payments are not connected.'),
        ],
      ),
    )),
  );
}
