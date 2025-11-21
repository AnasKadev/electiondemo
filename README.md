# 🗳️ Système de Vote Électronique - Version Améliorée

## 📝 Description

Application web Java EE pour la gestion d'élections avec interface moderne et intuitive pour électeurs et administrateurs.

## ✨ Fonctionnalités Principales

### Pour les Électeurs
- ✅ Tableau de bord moderne avec statistiques
- ✅ Recherche et filtrage d'élections
- ✅ Interface de vote intuitive avec confirmation
- ✅ Prévention du double vote
- ✅ Historique complet des participations
- ✅ Visualisation des élections (actives, à venir, terminées)

### Pour les Administrateurs  
- ✅ Tableau de bord avec statistiques globales
- ✅ Graphiques interactifs (Chart.js)
- ✅ Résultats en temps réel avec pourcentages
- ✅ Gestion complète des élections (CRUD)
- ✅ Suivi détaillé des participants

## 🎨 Design

- Interface moderne et responsive
- Animations fluides
- Palette de couleurs professionnelle
- Compatible mobile/tablette/desktop
- Font Awesome pour les icônes
- Bootstrap 5 pour le layout

## 🛠️ Technologies

### Backend
- Java 8+
- Jakarta EE (Servlets, JSP)
- Hibernate 6.2.7
- MySQL 8.0

### Frontend
- HTML5/CSS3
- JavaScript (Vanilla)
- Bootstrap 5.1.3
- Font Awesome 6.0.0
- Chart.js 3.9.1

### Serveur
- Apache Tomcat 10.x

## 📁 Structure du Projet

```
electiondemo/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/voting/
│       │       ├── entities/        # Entités JPA
│       │       ├── servlets/        # Contrôleurs
│       │       ├── filters/         # Filtres de sécurité
│       │       └── util/            # Utilitaires
│       ├── resources/
│       │   ├── hibernate.cfg.xml
│       │   └── schema.sql
│       └── webapp/
│           ├── voter/               # Pages électeurs
│           │   ├── dashboard.jsp
│           │   ├── vote.jsp
│           │   └── history.jsp
│           ├── admin/               # Pages admin
│           │   ├── dashboard.jsp
│           │   └── createElection.jsp
│           ├── login.jsp
│           └── register.jsp
├── pom.xml
├── build.bat                        # Script de build
├── AMELIORATIONS.md                 # Documentation des améliorations
└── GUIDE_DEMARRAGE.md              # Guide rapide
```

## 🚀 Installation

### Prérequis
- JDK 8 ou supérieur
- Maven 3.6+
- MySQL 8.0+
- Apache Tomcat 10.x

### Étapes

1. **Cloner le projet**
   ```bash
   git clone <url-du-repo>
   cd electiondemo
   ```

2. **Configurer la base de données**
   - Créer une base de données MySQL : `voting_system`
   - Mettre à jour `hibernate.cfg.xml` avec vos identifiants

3. **Compiler le projet**
   ```bash
   mvn clean package
   ```
   Ou utiliser le script :
   ```bash
   build.bat
   ```

4. **Déployer sur Tomcat**
   - Copier `target/elections.war` dans `tomcat/webapps/`
   - Démarrer Tomcat

5. **Accéder à l'application**
   ```
   http://localhost:8080/elections/
   ```

## 👥 Comptes de Test

### Administrateur
- Username: `admin`
- Password: `admin123`
- Rôle: `ADMIN`

### Électeur
- Username: `voter1`
- Password: `voter123`
- Rôle: `VOTER`

## 📖 Documentation

- **[AMELIORATIONS.md](AMELIORATIONS.md)** - Liste détaillée des améliorations
- **[GUIDE_DEMARRAGE.md](GUIDE_DEMARRAGE.md)** - Guide de test rapide

## 🎯 Guide Rapide

### Voter
1. Connexion avec compte électeur
2. Accéder au dashboard
3. Cliquer sur "Voter Maintenant"
4. Sélectionner un candidat
5. Confirmer le vote

### Administrer
1. Connexion avec compte admin
2. Voir les statistiques globales
3. Consulter les graphiques de votes
4. Créer/Éditer/Supprimer des élections

## 🔐 Sécurité

- Authentification par session
- Contrôle d'accès basé sur les rôles (RBAC)
- Prévention du double vote
- Validation des entrées
- Confirmation pour actions critiques

## 🎨 Captures d'Écran

### Tableau de Bord Électeur
- Statistiques personnelles
- Élections actives avec badges
- Historique de votes
- Recherche d'élections

### Page de Vote
- Cartes de candidats interactives
- Barre de progression
- Modale de confirmation
- Design moderne

### Tableau de Bord Admin
- Statistiques globales
- Graphiques circulaires
- Tableaux de résultats
- Gestion des élections

## 🐛 Résolution de Problèmes

### La page ne s'affiche pas
1. Vérifier que Tomcat est démarré
2. Vérifier que la BD est active
3. Vider le cache du navigateur

### Erreur de connexion BD
1. Vérifier `hibernate.cfg.xml`
2. Vérifier les credentials MySQL
3. Vérifier que la BD existe

### Erreur 404
1. Vérifier l'URL (doit inclure `/elections/`)
2. Redéployer le WAR
3. Redémarrer Tomcat

## 📝 Améliorations Futures Possibles

- [ ] Notifications en temps réel
- [ ] Export des résultats en PDF
- [ ] Authentification OAuth
- [ ] Interface multilingue
- [ ] Application mobile
- [ ] Système de chat
- [ ] Analyse avancée des données
- [ ] API REST

## 🤝 Contribution

Les contributions sont les bienvenues ! 

## 📄 Licence

Ce projet est sous licence MIT.

## 👨‍💻 Auteur

Système développé dans le cadre d'un projet éducatif.

---

**Version actuelle : 2.0 - Interface Moderne**

*Dernière mise à jour : Novembre 2024*

