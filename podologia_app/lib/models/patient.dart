class Patient {
  final String id;
  final String name;
  final String address;
  final String neighborhood;
  final String city;
  final String state;
  final String cep;
  final String birthDate;
  final String sex;
  final String profession;
  final String contact;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.name,
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.cep,
    required this.birthDate,
    required this.sex,
    required this.profession,
    required this.contact,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'cep': cep,
      'birth_date': birthDate,
      'sex': sex,
      'profession': profession,
      'contact': contact,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      neighborhood: map['neighborhood'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      cep: map['cep'] ?? '',
      birthDate: map['birth_date'] ?? '',
      sex: map['sex'] ?? '',
      profession: map['profession'] ?? '',
      contact: map['contact'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Patient copyWith({
    String? id,
    String? name,
    String? address,
    String? neighborhood,
    String? city,
    String? state,
    String? cep,
    String? birthDate,
    String? sex,
    String? profession,
    String? contact,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      cep: cep ?? this.cep,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      profession: profession ?? this.profession,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}