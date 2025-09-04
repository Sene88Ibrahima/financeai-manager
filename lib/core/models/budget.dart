import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  double montantLimite;

  @HiveField(3)
  double montantDepense;

  @HiveField(4)
  String? categorie; // null pour budget global

  @HiveField(5)
  DateTime dateDebut;

  @HiveField(6)
  DateTime dateFin;

  @HiveField(7)
  bool alerteActive;

  @HiveField(8)
  double seuilAlerte; // Pourcentage (0.8 = 80%)

  @HiveField(9)
  String? userId;

  Budget({
    required this.id,
    required this.nom,
    required this.montantLimite,
    this.montantDepense = 0.0,
    this.categorie,
    required this.dateDebut,
    required this.dateFin,
    this.alerteActive = true,
    this.seuilAlerte = 0.8,
    this.userId,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      nom: json['nom'],
      montantLimite: json['montant_limite'].toDouble(),
      montantDepense: json['montant_depense']?.toDouble() ?? 0.0,
      categorie: json['categorie'],
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      alerteActive: json['alerte_active'] ?? true,
      seuilAlerte: json['seuil_alerte']?.toDouble() ?? 0.8,
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'montant_limite': montantLimite,
      'montant_depense': montantDepense,
      'categorie': categorie,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      'alerte_active': alerteActive,
      'seuil_alerte': seuilAlerte,
      'user_id': userId,
    };
  }

  double get pourcentageUtilise => montantLimite > 0 ? (montantDepense / montantLimite) : 0.0;
  double get montantRestant => montantLimite - montantDepense;
  bool get estDepasse => montantDepense > montantLimite;
  bool get doitAlerter => alerteActive && pourcentageUtilise >= seuilAlerte;
  bool get estGlobal => categorie == null;

  @override
  String toString() {
    return 'Budget(id: $id, nom: $nom, limite: $montantLimite, depense: $montantDepense)';
  }
}
