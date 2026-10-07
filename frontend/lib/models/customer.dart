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

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      area: json['area'] as String,
      serviceHistory: List<String>.from(json['serviceHistory'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'area': area,
        'serviceHistory': serviceHistory,
      };
}
