---
created: 2025-09-09T19:38:05Z
last_updated: 2025-09-09T19:38:05Z
version: 1.0
author: Claude Code PM System
---

# Contexte Technique

## Environnement de Développement

### Plateforme
- **OS**: Windows (win32)
- **Git**: Repository initialisé et connecté au remote
- **Remote**: https://github.com/guillaumejay/resas.git
- **Branche principale**: main

### Outils et Dépendances

#### Système de Gestion de Version
- **Git**: Contrôle de version principal
- **GitHub**: Hébergement du repository distant
- **Workflow**: Feature branches avec merge vers main

#### Infrastructure Claude Code
- **Claude Code PM System**: Système de gestion de projet propriétaire
- **Agents spécialisés**: 4 agents pour la préservation de contexte
- **Système de commandes**: Interface markdown pour l'exécution de tâches

### Technologies Utilisées

#### Langages de Documentation
- **Markdown**: Format principal pour toute la documentation
- **YAML**: Frontmatter pour les métadonnées de fichiers
- **Shell**: Scripts bash pour les commandes système

#### Aucune Dépendance Externe
Ce projet n'utilise aucun framework ou bibliothèque externe:
- Pas de package.json (projet non-Node.js)
- Pas de requirements.txt (projet non-Python)
- Pas de Cargo.toml (projet non-Rust)
- Pas de go.mod (projet non-Go)

## Architecture Technique

### Système de Méta-Développement
Ce n'est PAS une application traditionnelle mais un **système de méta-développement**:
- Outil pour gérer D'AUTRES projets
- Infrastructure de commandes pour Claude AI
- Framework d'agents spécialisés

### Stack Technologique
```
Couche Interface: Commandes Markdown (/pm:*, /context:*, etc.)
    ↓
Couche Orchestration: System de Commandes Claude Code
    ↓
Couche Traitement: Agents Spécialisés (Task tool)
    ↓
Couche Données: Fichiers Markdown + Context + Git
```

## Patterns d'Architecture

### Context Firewall Pattern
- **Problème**: Les threads principaux perdent cohérence avec trop d'informations
- **Solution**: Agents comme "pare-feu de contexte"
- **Implémentation**: Agent traite N fichiers → Thread principal reçoit 1 résumé

### Command-Agent Integration
- **Pattern**: Commande → Analyse → Agent → Résultat concis
- **Exemples**:
  - `/testing:run` → test-runner agent → résumé des échecs
  - `/pm:issue-start` → parallel-worker agent → statut consolidé

### Fail-Fast Error Handling
- **Configuration critique**: Arrêt immédiat si échec
- **Fonctionnalités optionnelles**: Dégradation gracieuse
- **Messages d'erreur**: Solutions actionnables fournies

## Intégrations et APIs

### Intégrations Claude Code
- **Task tool**: Spawning d'agents spécialisés
- **File tools**: Read, Write, Edit pour manipulation de fichiers
- **Shell tools**: Bash pour commandes système
- **Search tools**: Grep, Glob pour recherche de code

### Pas d'APIs Externes
- Aucune intégration service web
- Aucune authentification externe requise
- Fonctionnement entièrement local

## Gestion des Données

### Format des Données
- **Fichiers Markdown**: Documentation et spécifications
- **YAML Frontmatter**: Métadonnées structurées
- **Git**: Versioning et historique
- **Logs**: Sortie des agents dans fichiers temporaires

### Persistance
- **État du projet**: Fichiers dans `.claude/context/`
- **Configuration**: `.claude/CLAUDE.md`
- **Historique**: Git commits
- **Logs temporaires**: Générés par les agents lors de l'exécution

## Performance et Optimisation

### Optimisations de Contexte
- **Agents**: Réduisent la charge contextuelle de 80-90%
- **Exécution parallèle**: multiple agents simultanés
- **Résumés concis**: Seules les informations essentielles remontent

### Patterns de Performance
- **Lazy loading**: Contexte chargé sur demande via `/context:prime`
- **Batching**: Commandes groupent les opérations
- **Caching**: Git et filesystem native caching

## Sécurité

### Pratiques de Sécurité
- **Pas de credentials**: Système local uniquement
- **Fail-fast**: Arrêt sur problèmes de sécurité
- **Isolation**: Agents fonctionnent en isolation
- **Validation**: Input validation dans toutes les commandes

### Considérations de Sécurité
- Exécution de code shell via Bash tool
- Manipulation de fichiers système
- Aucune exposition réseau
- Accès filesystem local uniquement

## Déploiement et Distribution

### Méthode de Distribution
- **Git clone**: Distribution via repository GitHub
- **Setup**: Copie des fichiers `.claude/` dans projet cible
- **Activation**: Commande `/re-init` pour initialisation

### Pas de Build Process
- Aucune compilation requise
- Aucune installation de dépendances
- Système prêt à l'emploi après clone

## Monitoring et Logging

### Système de Logging
- **Agent logs**: Sortie complète capturée pour débogage
- **Command execution**: Traçabilité via git et filesystem
- **Error reporting**: Messages structurés avec solutions

### Pas de Monitoring Externe
- Aucune télémétrie
- Aucune analytique
- Logs locaux uniquement