// lib/modele/redacteur.dart

class Redacteur {
  // Attributs de la classe
  int? id; // Clé primaire avec auto-incrémentation
  String nom;
  String prenom;
  String email;

  // Constructeur avec tous les attributs
  Redacteur({
    this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  // Constructeur sans l'attribut id (pour l'insertion)
  Redacteur.sansId({
    required this.nom,
    required this.prenom,
    required this.email,
  }) : id = null;

  // Méthode pour convertir un objet Redacteur en Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
    };
  }

  // Méthode pour créer un objet Redacteur à partir d'un Map
  factory Redacteur.fromMap(Map<String, dynamic> map) {
    return Redacteur(
      id: map['id'],
      nom: map['nom'],
      prenom: map['prenom'],
      email: map['email'],
    );
  }

  @override
  String toString() {
    return 'Redacteur{id: $id, nom: $nom, prenom: $prenom, email: $email}';
  }
}