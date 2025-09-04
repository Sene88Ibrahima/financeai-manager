import 'package:hive/hive.dart';

part 'expense_pattern.g.dart';

@HiveType(typeId: 3)
class ExpensePattern extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String categorie;

  @HiveField(3)
  double montantJournalier;

  @HiveField(4)
  List<int> joursActifs; // 1=lundi, 2=mardi, ..., 7=dimanche

  @HiveField(5)
  bool estActif;

  @HiveField(6)
  String? userId;

  ExpensePattern({
    required this.id,
    required this.nom,
    required this.categorie,
    required this.montantJournalier,
    required this.joursActifs,
    this.estActif = true,
    this.userId,
  });

  factory ExpensePattern.fromJson(Map<String, dynamic> json) {
    return ExpensePattern(
      id: json['id'],
      nom: json['nom'],
      categorie: json['categorie'],
      montantJournalier: json['montant_journalier'].toDouble(),
      joursActifs: List<int>.from(json['jours_actifs']),
      estActif: json['est_actif'] ?? true,
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'categorie': categorie,
      'montant_journalier': montantJournalier,
      'jours_actifs': joursActifs,
      'est_actif': estActif,
      'user_id': userId,
    };
  }

  // Calcule le montant estimé pour un mois donné
  double calculerMontantMensuel(DateTime mois) {
    if (!estActif) return 0.0;

    final premierJour = DateTime(mois.year, mois.month, 1);
    final dernierJour = DateTime(mois.year, mois.month + 1, 0);
    
    double total = 0.0;
    for (int jour = 1; jour <= dernierJour.day; jour++) {
      final date = DateTime(mois.year, mois.month, jour);
      final jourSemaine = date.weekday; // 1=lundi, 7=dimanche
      
      if (joursActifs.contains(jourSemaine)) {
        total += montantJournalier;
      }
    }
    
    return total;
  }

  String get joursActifsTexte {
    final jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return joursActifs.map((j) => jours[j - 1]).join(', ');
  }
}
