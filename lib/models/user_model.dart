class UserModel {
  final String name;
  final int age;
  final double weight;
  final String diabetesType;
  final String? gender;

  UserModel({
    required this.name,
    required this.age,
    required this.weight,
    required this.diabetesType,
    this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'diabetesType': diabetesType,
      'gender': gender,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      weight: (map['weight'] ?? 0.0).toDouble(),
      diabetesType: map['diabetesType'] ?? 'Type 1',
      gender: map['gender'],
    );
  }
}
