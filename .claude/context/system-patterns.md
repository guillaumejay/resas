---
created: 2025-09-09T19:38:05Z
last_updated: 2025-09-09T19:38:05Z
version: 1.0
author: Claude Code PM System
---

# Patterns Système

## Patterns Architecturaux Principaux

### 1. Context Firewall Pattern

**Problème identifié**:
```
Thread principal lit 10 fichiers → Contexte explose → Perd cohérence
```

**Solution implémentée**:
```
Agent lit 10 fichiers → Thread principal reçoit 1 résumé → Contexte préservé
```

**Implémentation**:
- Agents spécialisés comme "pare-feu de contexte"
- Réduction de 80-90% de l'information transmise
- Préservation uniquement des insights critiques

### 2. Command-Agent Integration Pattern

**Structure**:
```
Commande → Analyse → Agent approprié → Traitement lourd → Résultat concis
```

**Exemples concrets**:
- `/testing:run` → test-runner agent → analyse des échecs → résumé actionnable
- `/pm:issue-start` → parallel-worker agent → coordination → statut consolidé
- `/context:update` → file-analyzer agent → scan changements → rapport mis à jour

### 3. Parallel Execution Pattern

**Coordination hiérarchique**:
```
parallel-worker (coordinateur)
├── sous-agent-1 (stream A)
├── sous-agent-2 (stream B) 
├── sous-agent-3 (stream C)
└── consolidation → résultat unifié
```

**Avantages**:
- Maximise le parallélisme
- Évite les collisions de contexte
- Résultats synchronisés automatiquement

## Patterns de Gestion d'Erreurs

### 1. Fail-Fast pour Configuration Critique

**Principe**: Les problèmes de configuration critique arrêtent l'exécution immédiatement

**Implémentation**:
```markdown
# Preflight Checks requis avant exécution
- Validation répertoire .claude/ existe
- Vérification permissions écriture
- Test intégrité des fichiers de configuration
```

**Exemples**:
- Modèle de texte manquant → Arrêt immédiat
- Permissions fichier insuffisantes → Erreur explicite
- Repository Git absent → Demande confirmation utilisateur

### 2. Graceful Degradation pour Fonctionnalités Optionnelles

**Principe**: Les fonctionnalités optionnelles dégradent gracieusement avec messages clairs

**Implémentation**:
- Services externes indisponibles → Continue avec fonctionnalités de base
- Modèle d'extraction absent → Log + continue avec alternatives
- Tests non trouvés → Avertissement + suggestions

### 3. User-Friendly Error Messages

**Pattern standard**:
```
❌ [PROBLÈME IDENTIFIÉ]
💡 [SOLUTION ACTIONNABLE]
🔧 [COMMANDE SUGGÉRÉE]
```

## Patterns de Communication Inter-Agents

### 1. No Direct Agent Communication

**Anti-pattern évité**:
```
Agent A ←→ Agent B ←→ Agent C (Chaos)
```

**Pattern implémenté**:
```
Coordinateur
├── Agent A → Résultat A
├── Agent B → Résultat B  
└── Consolidation A + B → Résultat final
```

### 2. Coordinator Agent Pattern

**Rôle du parallel-worker**:
- Lit l'analyse initiale de l'issue
- Spawn multiple sous-agents spécialisés
- Coordonne leur exécution en parallèle
- Consolide les résultats pour le thread principal

## Patterns de Préservation de Contexte

### 1. Hierarchical Context Reduction

**Niveau 1 - Agents spécialisés**:
- file-analyzer: Fichier verbeux → Résumé critique (90% réduction)
- code-analyzer: Multiple fichiers → Rapport de bugs concis
- test-runner: Sortie complète → Analyse d'échecs ciblée

**Niveau 2 - Coordinateur**:
- parallel-worker: N résultats d'agents → 1 statut consolidé

**Niveau 3 - Thread principal**:
- Reçoit uniquement les insights actionnables
- Contexte préservé pour cohérence long terme

### 2. Stateless Agent Execution

**Principe**: Chaque invocation d'agent est sans état
- Agent reçoit contexte complet dans le prompt
- Agent retourne résultat final en une seule réponse  
- Pas de communication continue avec l'agent
- État maintenu uniquement dans le thread principal

## Patterns de Workflow de Développement

### 1. Task Decomposition Pattern

**Pour issues complexes**:
```
/pm:issue-analyze → Identification des work streams
/pm:issue-start → Création worktree + spawn parallel-worker
parallel-worker → Distribution aux sous-agents spécialisés
Consolidation → Retour au thread principal avec résumé
```

### 2. Context Loading Pattern

**Workflow standard**:
```
Début de session → /context:prime → Contexte chargé
Travail intensif → Agents préservent contexte
Fin de session → /context:update → Contexte mis à jour
```

### 3. Testing Integration Pattern

**Approche sans interruption**:
```
Développement → /testing:run → test-runner agent
Agent capture sortie complète → Analyse automatique
Thread principal reçoit → Résumé échecs uniquement
```

## Anti-Patterns Évités

### ❌ Specialist Agent Anti-Pattern
- **Évité**: Création d'"experts" (database-expert, api-expert)
- **Raison**: Tous les agents utilisent le même modèle
- **Alternative**: Agents par tâche, pas par domaine d'expertise

### ❌ Verbose Output Anti-Pattern  
- **Évité**: Agents retournant sortie complète
- **Raison**: Défait l'objectif de préservation de contexte
- **Alternative**: Résumés de 10-20% de l'information traitée

### ❌ Agent Communication Anti-Pattern
- **Évité**: Communication directe entre agents
- **Raison**: Crée complexité et perte de contrôle
- **Alternative**: Architecture coordinateur centralisé

### ❌ Simple Task Agent Anti-Pattern
- **Évité**: Utilisation d'agents pour tâches simples
- **Raison**: Overhead inutile pour tâches triviales
- **Alternative**: Agents uniquement quand réduction de contexte valuable

## Patterns de Quality Assurance

### 1. Complete Implementation Pattern

**Règle absolue**: NO PARTIAL IMPLEMENTATION
- Toutes les fonctionnalités complètement implémentées
- Pas de placeholders "simplifié pour maintenant"
- Tests complets pour chaque fonction

### 2. Context-Aware Testing Pattern

**Test-runner agent**:
- Capture sortie complète pour débogage
- Conversation principale reste propre
- Optimisation d'usage du contexte
- Issues correctement remontées

### 3. Error-Revealing Test Pattern

**Tests conçus pour**:
- Révéler vraies failles, pas juste passer
- Usage réel, pas scénarios artificiels
- Verbosité pour débogage efficace
- Pas de "cheater tests"

## Évolutivité des Patterns

### 1. Extensible Command System
- Nouveaux commands ajoutés sans affecter existant
- Structure modulaire par catégorie (`/pm:*`, `/context:*`)
- Frontmatter standardisé pour outils autorisés

### 2. Agent Specialization Growth
- Nouveaux agents ajoutés facilement
- Pattern uniforme: input → processing → concise output
- Intégration automatique avec système de commandes

### 3. Context Evolution Pattern
- Contexte grandit organiquement avec projet
- Structure préservée via frontmatter et conventions
- Mise à jour incrémentale via `/context:update`