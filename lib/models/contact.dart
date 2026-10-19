class Contact {
  final int? id;
  final String name;
  final String email;
  final String phoneNumber;

  const Contact({
    this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: (json["id"] as num?)?.toInt(),
      name: "${json["name"] ?? ""}",
      email: "${json["email"] ?? ""}",
      phoneNumber: "${json["phone_number"] ?? ""}",
    );
  }

  Map<String, dynamic> toJson() {
    return {"name": name, "email": email, "phone_number": phoneNumber};
  }
}
