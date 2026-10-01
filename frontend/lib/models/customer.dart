class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.area,
    required this.serviceHistory,
  });

  final String id;
  final String name;
  final String phone;
  final String address;
  final String area;
  final List<String> serviceHistory;
}
