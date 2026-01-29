# 🚖 YangoClone - Plateforme VTC Complète

Un prototype fonctionnel de plateforme de VTC (Voiture de Tourisme avec Chauffeur) comprenant une application mobile pour les clients, une application pour les chauffeurs (simulée), et un dashboard d'administration complet.

![Banner](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![Banner](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB) ![Banner](https://img.shields.io/badge/Supabase-181818?style=for-the-badge&logo=supabase&logoColor=white)

## 🌟 Fonctionnalités Clés

### 📱 Application Mobile (Flutter)
- **Authentification** : Connexion/Inscription sécurisée (Email/Password).
- **Géolocalisation** : Visualisation en temps réel sur carte (OpenStreetMap).
- **Réservation** : Commande de course avec estimation de prix et distance.
- **Suivi** : Tracking du chauffeur en temps réel.
- **Gestion de profil** : Historique des courses et informations personnelles.

### 🖥️ Dashboard Admin (React + Refine)
- **Vue d'ensemble** : Statistiques clés (Courses, Chauffeurs actifs, Revenus).
- **Gestion des Utilisateurs** : Administration des clients et chauffeurs (Validation documents).
- **Suivi des Courses** : Liste des courses en temps réel avec statuts.
- **Carte Globale** : Position de tous les chauffeurs actifs.

## 🏗️ Architecture Technique

Le projet repose sur une architecture moderne et scalable :

- **Frontend Mobile** : Flutter avec **GetX** pour la gestion d'état (Pattern MVC).
- **Frontend Web** : React avec **Refine** pour une interface admin rapide et robuste.
- **Backend** : **Supabase** (PostgreSQL) gère :
    - L'authentification (Auth)
    - La base de données temps réel (Realtime DB)
    - Le stockage de fichiers (Storage)
    - Les Edge Functions (Logique serveur)

## 🚀 Installation & Démarrage

### Prérequis
- Flutter SDK (3.x)
- Node.js (18+)
- Compte Supabase (ou instance locale)

### 1. Configuration Backend
Exécuter le script `migration.sql` dans votre interface Supabase SQL Editor pour créer la structure de la base de données.

### 2. Démarrage Application Mobile (Client)
```bash
cd yango_client
flutter pub get
flutter run
```

### 3. Démarrage Dashboard Admin
```bash
cd yango_admin
npm install
npm run dev
```

## 📱 Captures d'écran

| Accueil Client | Recherche | Dashboard Admin |
|:---:|:---:|:---:|
| *(Insérer Screenshot)* | *(Insérer Screenshot)* | *(Insérer Screenshot)* |

## 🛠️ Technologies Utilisées
- **Flutter** : Framework UI mobile.
- **GetX** : State Management & Routing.
- **Flutter Map** : Affichage de cartes OpenStreetMap.
- **React** : Library UI Web.
- **Refine** : Framework React pour applications internes/admin.
- **Ant Design** : Kit UI pour le dashboard.
- **Supabase** : Backend-as-a-Service (PostgreSQL).

## 👤 Auteur
Projet académique réalisé par **[Votre Nom]**.
