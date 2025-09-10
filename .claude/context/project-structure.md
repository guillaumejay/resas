---
created: 2025-09-09T19:38:05Z
last_updated: 2025-09-09T19:38:05Z
version: 1.0
author: Claude Code PM System
---

# Structure du Projet

## Vue d'Ensemble de l'Architecture

Ce projet est un **Système de Gestion de Projet (PM) pour Claude Code** - une boîte à outils sophistiquée pour gérer les workflows de développement Claude AI utilisant des agents spécialisés et des commandes.

## Structure des Répertoires

```
resas/
├── .claude/                    # Infrastructure du système PM
│   ├── agents/                 # Spécifications des agents spécialisés
│   │   ├── code-analyzer.md    # Agent d'analyse de code
│   │   ├── file-analyzer.md    # Agent d'analyse de fichiers
│   │   ├── parallel-worker.md  # Agent de travail parallèle
│   │   └── test-runner.md      # Agent d'exécution de tests
│   ├── commands/               # Implémentations des commandes
│   │   ├── context/            # Gestion du contexte
│   │   │   ├── create.md       # Création du contexte initial
│   │   │   ├── prime.md        # Chargement du contexte
│   │   │   └── update.md       # Mise à jour du contexte
│   │   ├── pm/                 # Gestion de projet
│   │   │   ├── blocked.md      # Gestion des blocages
│   │   │   ├── clean.md        # Nettoyage du projet
│   │   │   ├── epic-*.md       # Gestion des épiques
│   │   │   ├── init.md         # Initialisation PM
│   │   │   ├── issue-*.md      # Gestion des issues
│   │   │   ├── sprint-*.md     # Gestion des sprints
│   │   │   └── status.md       # Statut du projet
│   │   ├── testing/            # Tests et validation
│   │   │   ├── prime.md        # Configuration des tests
│   │   │   └── run.md          # Exécution des tests
│   │   ├── code-rabbit.md      # Traitement des revues CodeRabbit
│   │   ├── prompt.md           # Gestion des prompts complexes
│   │   └── re-init.md          # Réinitialisation du système
│   ├── context/                # Documentation du contexte
│   │   └── README.md           # Guide du système de contexte
│   ├── scripts/                # Scripts shell pour les commandes PM
│   └── CLAUDE.md               # Règles de base du système PM
├── .git/                       # Contrôle de version Git
├── AGENTS.md                   # Documentation des agents
├── CLAUDE.md                   # Règles et directives du projet
├── COMMANDS.md                 # Référence des commandes
└── README.md                   # Documentation principale du projet
```

## Organisation des Fichiers

### Système PM (`.claude/`)
- **Structure modulaire** organisée par fonctionnalité
- **Agents spécialisés** dans `/agents/` avec spécifications complètes
- **Commandes hiérarchiques** dans `/commands/` par catégorie
- **Contexte centralisé** dans `/context/` pour la préservation d'état
- **Scripts utilitaires** dans `/scripts/` pour l'exécution de commandes

### Documentation Racine
- **AGENTS.md** - Philosophie et usage des agents
- **CLAUDE.md** - Règles de développement absolues
- **COMMANDS.md** - Référence complète des commandes
- **README.md** - Point d'entrée principal du projet

## Modèles de Nommage

### Conventions de Fichiers
- **Fichiers de commande**: `category/action.md` (ex: `pm/issue-start.md`)
- **Agents**: `agent-name.md` (ex: `code-analyzer.md`)
- **Documentation**: `UPPERCASE.md` pour les documents principaux
- **Contexte**: `descriptive-name.md` pour les fichiers de contexte

### Conventions de Structure
- **Frontmatter YAML** requis pour tous les fichiers de contexte
- **Sections markdown standardisées** dans tous les documents
- **Références croisées** utilisant des liens relatifs

## Organisation des Modules

### Agents (`/agents/`)
Chaque agent a une spécification complète incluant:
- Purpose et cas d'usage
- Pattern d'exécution (input → processing → output)
- Outils autorisés
- Format de retour
- Gestion d'erreurs

### Commandes (`/commands/`)
Organisées par domaine fonctionnel:
- **context/**: Gestion du contexte projet
- **pm/**: Flux de travail de gestion de projet
- **testing/**: Validation et tests
- **Utilitaires**: Commandes d'assistance diverses

### Contexte (`/context/`)
Documentation structurée du projet:
- État actuel et progression
- Architecture et patterns techniques
- Contexte produit et vision
- Guide de style et conventions

## Patterns d'Intégration

### Système Commande-Agent
```
Commande → Analyse → Agent approprié → Traitement → Résultat concis
```

### Firewall de Contexte
```
Agent lit N fichiers → Contexte principal reçoit 1 résumé → Contexte préservé
```

### Exécution Parallèle
```
parallel-worker → multiple sous-agents → résultats consolidés
```

## Considérations de Maintenance

### Évolutivité
- Structure modulaire permet l'ajout facile de nouveaux agents
- Commandes peuvent être étendues sans affecter le système existant
- Contexte peut croître organiquement avec le projet

### Robustesse  
- Gestion d'erreurs fail-fast pour les problèmes critiques
- Dégradation gracieuse pour les fonctionnalités optionnelles
- Messages d'erreur clairs avec solutions actionnables

### Documentation
- Auto-documentation via frontmatter et structure
- Références croisées maintiennent la cohérence
- Exemples intégrés dans chaque spécification