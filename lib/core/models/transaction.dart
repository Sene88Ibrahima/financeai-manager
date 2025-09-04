import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double montant;

  @HiveField(2)
  String type; // 'revenu' ou 'depense'

  @HiveField(3)
  String categorie;

  @HiveField(4)
  String? description;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  DateTime dateCreation;

  @HiveField(7)
  String? userId;

  Transaction({
    required this.id,
    required this.montant,
    required this.type,
    required this.categorie,
    this.description,
    required this.date,
    required this.dateCreation,
    this.userId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      montant: json['montant'].toDouble(),
      type: json['type'],
      categorie: json['categorie'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      dateCreation: DateTime.parse(json['date_creation']),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'type': type,
      'categorie': categorie,
      'description': description,
      'date': date.toIso8601String(),
      'date_creation': dateCreation.toIso8601String(),
      'user_id': userId,
    };
  }

  bool get isRevenu => type == 'revenu';
  bool get isDepense => type == 'depense';

  @override
  String toString() {
    return 'Transaction(id: $id, montant: $montant, type: $type, categorie: $categorie)';
  }
}
