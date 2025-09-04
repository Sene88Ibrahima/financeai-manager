import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 2)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String description;

  @HiveField(3)
  double montantCible;

  @HiveField(4)
  double montantActuel;

  @HiveField(5)
  DateTime dateCreation;

  @HiveField(6)
  DateTime? dateEcheance;

  @HiveField(7)
  bool estAtteint;

  @HiveField(8)
  String? userId;

  @HiveField(9)
  String? dernierMoisApplique; // Format: "2025-01"

  Goal({
    required this.id,
    required this.nom,
    required this.description,
    required this.montantCible,
    this.montantActuel = 0.0,
    required this.dateCreation,
    this.dateEcheance,
    this.estAtteint = false,
    this.userId,
    this.dernierMoisApplique,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      montantCible: json['montant_cible'].toDouble(),
      montantActuel: json['montant_actuel']?.toDouble() ?? 0.0,
      dateCreation: DateTime.parse(json['date_creation']),
      dateEcheance: json['date_echeance'] != null 
          ? DateTime.parse(json['date_echeance']) 
          : null,
      estAtteint: json['est_atteint'] ?? false,
      userId: json['user_id'],
      dernierMoisApplique: json['dernier_mois_applique'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'montant_cible': montantCible,
      'montant_actuel': montantActuel,
      'date_creation': dateCreation.toIso8601String(),
      'date_echeance': dateEcheance?.toIso8601String(),
      'est_atteint': estAtteint,
      'user_id': userId,
      'dernier_mois_applique': dernierMoisApplique,
    };
  }

  double get pourcentageProgression => montantCible > 0 ? (montantActuel / montantCible) : 0.0;
  double get montantRestant => montantCible - montantActuel;
  bool get estComplete => montantActuel >= montantCible;
  
  int? get joursRestants {
    if (dateEcheance == null) return null;
    final difference = dateEcheance!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  @override
  String toString() {
    return 'Goal(id: $id, nom: $nom, cible: $montantCible, actuel: $montantActuel)';
  }
}
