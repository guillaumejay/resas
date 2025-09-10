# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.
Toutes les documentations, spécifications, et issues doivent être ecrites en français

## Project Overview

This is a **Claude Code Project Management (PM) System** - a sophisticated toolchain for managing Claude AI development workflows using specialized agents and commands. This is NOT a traditional application codebase but rather a meta-development tool for managing OTHER projects.

## Core Architecture

### Agent-Based Context Preservation
The system uses specialized agents as "context firewalls" to prevent information overload:
- **code-analyzer**: Hunts bugs across multiple files, returns concise reports
- **file-analyzer**: Summarizes verbose files (80-90% size reduction)
- **test-runner**: Executes tests and captures output to logs
- **parallel-worker**: Coordinates multiple parallel work streams

### Command System Structure
Commands are organized in `.claude/commands/` by category:
- **Context Commands**: `/context:create`, `/context:update`, `/context:prime`
- **Project Management**: `/pm:*` (documented in README.md)  
- **Testing**: `/testing:prime`, `/testing:run`
- **Utilities**: `/prompt`, `/re-init`, `/code-rabbit`

## Key Development Commands

Since this is a PM system for managing other projects, typical build/test commands don't apply. Instead:

### PM System Commands
- `/pm:init` - Initialize PM system in a project
- `/pm:status` - Check current project status
- `/pm:help` - Show available PM commands

### Context Management
- `/context:create` - Analyze and document project structure
- `/context:prime` - Load project context into conversation
- `/context:update` - Refresh context with recent changes

### Testing Workflow
- `/testing:prime` - Configure testing framework detection
- `/testing:run` - Execute tests via test-runner agent

## Architecture Patterns

### Context Firewall Pattern
```
Without Agent: Main thread reads 10 files → Context explodes → Loses coherence
With Agent: Agent reads 10 files → Main thread gets 1 summary → Context preserved
```

### Command-Agent Integration
Commands spawn agents for heavy processing:
```
/pm:issue-start → parallel-worker agent → multiple sub-agents → consolidated results
```

### Fail-Fast Error Handling
- Critical configuration failures stop execution immediately
- Optional features degrade gracefully with clear messages
- All errors provide actionable solutions

## Absolute Development Rules

- **NO PARTIAL IMPLEMENTATION** - Complete all features fully
- **NO SIMPLIFICATION** - No placeholder or "simplified for now" code
- **NO CODE DUPLICATION** - Reuse existing functions and constants
- **NO DEAD CODE** - Remove unused code completely
- **IMPLEMENT TEST FOR EVERY FUNCTION** - No exceptions
- **NO CHEATER TESTS** - Tests must be accurate and reveal real flaws
- **NO INCONSISTENT NAMING** - Follow existing patterns
- **NO OVER-ENGINEERING** - Simple functions over complex abstractions
- **NO MIXED CONCERNS** - Proper separation of responsibilities
- **NO RESOURCE LEAKS** - Clean up connections, timeouts, listeners

## Agent Usage Requirements

### Always Use Sub-Agents For:
1. **File Analysis** - Use `file-analyzer` for reading/summarizing files
2. **Code Analysis** - Use `code-analyzer` for bug hunting and logic tracing  
3. **Test Execution** - Use `test-runner` for running and analyzing tests

### Agent Benefits:
- Full output captured for debugging
- Main conversation stays clean
- Context usage optimized
- All issues properly surfaced
- No approval dialogs interrupt workflow

## File Structure

```
.claude/
├── agents/           # Agent specifications
├── commands/         # Command implementations
│   ├── context/      # Context management
│   ├── pm/          # Project management
│   └── *.md         # Utility commands
├── scripts/         # Shell scripts for PM commands
└── CLAUDE.md        # Base PM system rules
```

## Error Handling Philosophy

- **Fail fast** for critical configuration issues
- **Log and continue** for optional features  
- **Graceful degradation** when external services unavailable
- **User-friendly messages** with clear solutions

## Testing Philosophy

- Always use test-runner agent for execution
- Never use mock services - test real implementations
- Complete each test before moving to next
- Verify test structure before assuming code needs refactoring
- Tests must be verbose for effective debugging

## Communication Style

- Be skeptical and provide constructive criticism
- Ask questions when intent is unclear - don't guess
- Be concise but thorough when explaining solutions
- Point out better approaches or relevant standards
- No flattery or unnecessary compliments