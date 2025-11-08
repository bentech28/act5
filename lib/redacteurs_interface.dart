// lib/redacteurs_interface.dart

import 'package:flutter/material.dart';
import 'modele/redacteur.dart';
import 'services/database_manager.dart';

class RedacteursInterface extends StatefulWidget {
  const RedacteursInterface({super.key});

  @override
  State<RedacteursInterface> createState() => _RedacteursInterfaceState();
}

class _RedacteursInterfaceState extends State<RedacteursInterface> {
  // Contrôleurs pour les champs de texte
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Liste des rédacteurs
  List<Redacteur> _redacteurs = [];

  // Instance du gestionnaire de base de données
  final DatabaseManager _dbManager = DatabaseManager.instance;

  @override
  void initState() {
    super.initState();
    _chargerRedacteurs();
  }

  // Charger tous les rédacteurs depuis la base de données
  Future<void> _chargerRedacteurs() async {
    final redacteurs = await _dbManager.getAllRedacteurs();
    setState(() {
      _redacteurs = redacteurs;
    });
  }

  // Ajouter un nouveau rédacteur
  Future<void> _ajouterRedacteur() async {
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _emailController.text.isEmpty) {
      _afficherMessage('Veuillez remplir tous les champs');
      return;
    }

    final nouveauRedacteur = Redacteur.sansId(
      nom: _nomController.text,
      prenom: _prenomController.text,
      email: _emailController.text,
    );

    await _dbManager.insertRedacteur(nouveauRedacteur);

    // Réinitialiser les champs
    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();

    // Recharger la liste
    await _chargerRedacteurs();

    _afficherMessage('Rédacteur ajouté avec succès');
  }

  // Modifier un rédacteur existant
  Future<void> _modifierRedacteur(Redacteur redacteur) async {
    final nomController = TextEditingController(text: redacteur.nom);
    final prenomController = TextEditingController(text: redacteur.prenom);
    final emailController = TextEditingController(text: redacteur.email);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le rédacteur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nomController.text.isEmpty ||
                  prenomController.text.isEmpty ||
                  emailController.text.isEmpty) {
                _afficherMessage('Veuillez remplir tous les champs');
                return;
              }

              final redacteurModifie = Redacteur(
                id: redacteur.id,
                nom: nomController.text,
                prenom: prenomController.text,
                email: emailController.text,
              );

              await _dbManager.updateRedacteur(redacteurModifie);
              await _chargerRedacteurs();

              if (!mounted) return;
              Navigator.of(context).pop();
              _afficherMessage('Rédacteur modifié avec succès');
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  // Supprimer un rédacteur
  Future<void> _supprimerRedacteur(Redacteur redacteur) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer ${redacteur.prenom} ${redacteur.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await _dbManager.deleteRedacteur(redacteur.id!);
              await _chargerRedacteurs();

              if (!mounted) return;
              Navigator.of(context).pop();
              _afficherMessage('Rédacteur supprimé avec succès');
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Afficher un message SnackBar
  void _afficherMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des rédacteurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Fonctionnalité de recherche (à implémenter si nécessaire)
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulaire d'ajout
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nomController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _prenomController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _ajouterRedacteur,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un Rédacteur'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Liste des rédacteurs
            Expanded(
              child: _redacteurs.isEmpty
                  ? const Center(
                child: Text(
                  'Aucun rédacteur enregistré',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: _redacteurs.length,
                itemBuilder: (context, index) {
                  final redacteur = _redacteurs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        '${redacteur.prenom} ${redacteur.nom}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(redacteur.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _modifierRedacteur(redacteur),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _supprimerRedacteur(redacteur),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}