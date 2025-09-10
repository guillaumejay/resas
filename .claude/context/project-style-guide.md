---
created: 2025-09-09T19:38:05Z
last_updated: 2025-09-09T19:38:05Z
version: 1.0
author: Claude Code PM System
---

# Guide de Style du Projet

## Principes de Style Fondamentaux

### Clarté Avant Tout
- **Explicite > Implicite**: Préférer la clarté à la concision obscure
- **Noms descriptifs**: Variables et fonctions auto-documentées
- **Structure évidente**: Organisation logique immédiatement compréhensible
- **Commentaires utiles**: Expliquer le pourquoi, pas le quoi

### Consistance Absolue
- **Patterns uniformes**: Même approche pour problèmes similaires
- **Conventions respectées**: Jamais de déviations arbitraires
- **Structure prévisible**: Développeurs trouvent ce qu'ils cherchent intuitivement
- **Evolution cohérente**: Nouveautés respectent style existant

## Conventions de Nommage

### Fichiers et Répertoires

#### Fichiers Markdown
```
# Documents principaux (visibilité maximale)
UPPERCASE.md              → README.md, AGENTS.md, COMMANDS.md

# Fichiers de contexte (descriptifs)
kebab-case.md              → project-overview.md, tech-context.md

# Commandes (catégorie:action)
category/action.md         → pm/issue-start.md, context/prime.md

# Agents (descriptif avec tirets)
agent-name.md              → code-analyzer.md, file-analyzer.md
```

#### Structure Répertoires
```
.claude/                   → Racine système PM
├── agents/               → Spécialisations agents
├── commands/             → Implémentations commandes
│   ├── context/         → Sous-catégorie logique
│   └── pm/              → Sous-catégorie logique
├── context/             → Documentation projet
└── scripts/             → Utilitaires shell
```

### Conventions Internes

#### Variables et Identifiants
- **Snake_case**: Variables dans scripts bash
- **UPPER_CASE**: Constants et variables d'environnement
- **kebab-case**: Identifiants fichiers et paramètres
- **camelCase**: Évité dans ce projet (préférer kebab-case)

#### Noms de Commandes
```
Format: /category:action
Exemples:
/pm:issue-start           → Catégorie PM, action start issue
/context:prime            → Catégorie context, action prime
/testing:run              → Catégorie testing, action run
```

## Structure de Fichiers

### Frontmatter Standardisé

#### Tous Fichiers de Contexte
```yaml
---
created: 2025-09-09T19:38:05Z          # UTC timestamp réel
last_updated: 2025-09-09T19:38:05Z     # UTC timestamp réel  
version: 1.0                          # Versioning sémantique
author: Claude Code PM System         # Attribution claire
---
```

#### Fichiers de Commandes
```yaml
---
allowed-tools: Read, Write, Bash      # Outils autorisés explicites
---
```

### Structure Markdown

#### Headers Hiérarchiques
```markdown
# Titre Principal (H1)
## Section Majeure (H2)
### Sous-section (H3)
#### Détail (H4)
##### Rarement utilisé (H5)
```

#### Organisation Type
```markdown
# Titre Principal

## Vue d'Ensemble
Brief description et context

## Section Principale 1
### Détails 1.1
### Détails 1.2

## Section Principale 2
### Détails 2.1
### Détails 2.2

## Références et Notes
Liens, attributions, notes techniques
```

## Conventions de Documentation

### Style d'Écriture

#### Langue et Ton
- **Français obligatoire**: Toutes documentations, spécifications, issues
- **Ton professionnel**: Clair, direct, sans familiarité excessive
- **Forme active**: "Créez le fichier" vs "Le fichier doit être créé"
- **Impératif dans instructions**: "Utilisez", "Configurez", "Exécutez"

#### Format Instructions
```markdown
### Titre Action Concrète

**Objectif**: Une phrase claire décrivant le but

**Étapes**:
1. Action spécifique avec détail nécessaire
2. Action suivante avec contexte
3. Validation ou vérification résultat

**Résultat attendu**: Description claire de l'état final
```

### Exemples et Code Blocks

#### Code Blocks Annotés
````markdown
```bash
# Description de ce que fait cette commande
git status --short
```
````

#### Exemples Concrets
```markdown
**Exemple**:
```
Input: /pm:issue-start #1234
Processing: parallel-worker spawned with 3 sub-agents
Output: "Issue #1234 implementation started - 4 work streams active"
```
```

### Références et Liens

#### Liens Internes
```markdown
# Préférer liens relatifs
[Agents documentation](../agents/code-analyzer.md)

# Éviter liens absolus
❌ [Bad](https://github.com/user/repo/blob/main/file.md)
✅ [Good](./relative-path.md)
```

#### Références Croisées
```markdown
Voir aussi:
- [Context Management](./context/create.md) - Création contexte initial
- [Agent Patterns](../AGENTS.md#patterns) - Patterns d'usage agents
```

## Standards de Code (Scripts et Configuration)

### Scripts Bash

#### Conventions Nommage
```bash
#!/bin/bash
# Convention: verbes d'action en kebab-case
# Exemples: setup-project.sh, run-tests.sh, clean-worktree.sh
```

#### Structure Script Type
```bash
#!/bin/bash
set -euo pipefail  # Fail-fast, undefined vars error, pipe failures

# Description claire du script
# Usage: ./script-name.sh [arguments]

# Variables configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="${SCRIPT_DIR}/.."

# Fonctions utilitaires
log_info() {
    echo "ℹ️  $*" >&2
}

log_error() {
    echo "❌ $*" >&2
    exit 1
}

# Logic principal
main() {
    # Implementation here
    log_info "Script completed successfully"
}

# Execution
main "$@"
```

### Configuration Files

#### YAML Formatting
```yaml
# Indentation: 2 espaces (jamais tabs)
# Strings: Quotes seulement si nécessaires
# Lists: Format compact ou expanded selon contexte

key: value
nested:
  subkey: subvalue
  list:
    - item1
    - item2
```

## Standards de Qualité

### Règles Absolues (Non-Négociables)

#### Code Quality
- **NO PARTIAL IMPLEMENTATION**: Fonctionnalité complète ou pas du tout
- **NO SIMPLIFICATION**: Pas de "version simplifiée pour maintenant"
- **NO CODE DUPLICATION**: Réutiliser fonctions existantes
- **NO DEAD CODE**: Supprimer complètement code inutilisé

#### Testing Standards
- **IMPLEMENT TEST FOR EVERY FUNCTION**: Aucune exception
- **NO CHEATER TESTS**: Tests révèlent vraies failles
- **VERBOSE TESTS**: Tests utilisables pour débogage
- **REAL USAGE TESTS**: Scénarios réalistes, pas artificiels

#### Documentation Requirements
- **COMPLETE DOCUMENTATION**: Chaque fonctionnalité documentée
- **EXAMPLES INCLUDED**: Exemples concrets pour chaque feature
- **UP-TO-DATE**: Documentation synchronisée avec code
- **FRENCH LANGUAGE**: Toute documentation en français

### Error Handling Standards

#### Messages d'Erreur Format
```markdown
❌ [PROBLÈME IDENTIFIÉ]
💡 [SOLUTION ACTIONNABLE]  
🔧 [COMMANDE EXACTE SI APPLICABLE]

Exemple:
❌ Cannot create context directory
💡 Check permissions for .claude/ directory
🔧 Run: chmod 755 .claude/ && mkdir -p .claude/context/
```

#### Fail-Fast Implementation
```bash
# Critical errors stop immediately
[[ -d .claude ]] || {
    log_error "PM system not initialized. Run /pm:init first."
    exit 1
}

# Optional features degrade gracefully
if ! command -v rg >/dev/null 2>&1; then
    log_warning "ripgrep not found, using grep fallback"
    GREP_CMD="grep"
else
    GREP_CMD="rg"
fi
```

## Patterns d'Architecture

### Agent Specifications

#### Structure Agent File
```markdown
# Agent Name

## Purpose
One clear sentence describing agent responsibility

## Pattern
input → processing → output description

## Usage Context
When to use this agent vs others

## Tools Required
List of allowed tools in frontmatter

## Return Format
Exact specification of what agent returns

## Error Handling
How agent handles and reports failures
```

### Command Specifications

#### Structure Command File
```markdown
# Command Name

Brief description of command purpose

## Required Rules
Links to applicable rules from .claude/rules/

## Preflight Checklist
Validation steps before execution

## Instructions
Step-by-step implementation details

## Error Handling
Common failures and solutions

## Post-Execution Summary
Expected output format for user
```

## Maintenance et Evolution

### Version Control Conventions

#### Commit Messages
```
Format: category: clear description

Exemples:
docs: add context creation guide
agents: implement file-analyzer with 90% reduction
commands: add parallel execution to pm:issue-start
fix: resolve context loading edge case
```

#### Branch Naming
```
feature/descriptive-feature-name
bugfix/specific-issue-description
docs/documentation-improvement
refactor/component-restructure
```

### Documentation Maintenance

#### Regular Updates Required
- **Context files**: Update après changements majeurs
- **Command documentation**: Sync avec implémentation
- **Examples**: Vérifier validité et pertinence
- **Links**: Valider références internes et externes

#### Quality Assurance
- **Spell check**: Français correct obligatoire
- **Link validation**: Références internes fonctionnent
- **Example testing**: Code examples s'exécutent correctement
- **Consistency check**: Style uniforme maintenu

### Style Evolution

#### Adding New Patterns
1. **Document first**: Nouveau pattern documenté avant usage
2. **Consistency check**: S'assure compatibilité style existant
3. **Community review**: Patterns majeurs discutés ouvertement
4. **Update guides**: Style guide mis à jour si nécessaire

#### Backward Compatibility
- **Breaking changes**: Évités autant que possible
- **Migration guides**: Fournis pour changements majeurs
- **Deprecation process**: Phase-out graduel anciens patterns
- **Version support**: Support versions antérieures documenté