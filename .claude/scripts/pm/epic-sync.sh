#!/bin/bash

echo "Syncing to GitHub..."
echo ""

epic_name="$1"

if [ -z "$epic_name" ]; then
  echo "❌ Please specify an epic name"
  echo "Usage: /pm:epic-sync <epic-name>"
  echo ""
  echo "Available epics:"
  for dir in .claude/epics/*/; do
    [ -d "$dir" ] && echo "  • $(basename "$dir")"
  done
  exit 1
fi

epic_dir=".claude/epics/$epic_name"
epic_file="$epic_dir/epic.md"

# Verify epic exists
if [ ! -f "$epic_file" ]; then
  echo "❌ Epic not found: $epic_name"
  echo "Run: /pm:prd-parse $epic_name"
  exit 1
fi

# Count task files
task_count=$(ls "$epic_dir"/[0-9][0-9][0-9].md 2>/dev/null | wc -l)
if [ "$task_count" -eq 0 ]; then
  echo "❌ No tasks to sync. Run: /pm:epic-decompose $epic_name"
  exit 1
fi

# 0. Check Remote Repository
remote_url=$(git remote get-url origin 2>/dev/null || echo "")
if [[ "$remote_url" == *"automazeio/ccpm"* ]] || [[ "$remote_url" == *"automazeio/ccpm.git"* ]]; then
  echo "❌ ERROR: You're trying to sync with the CCPM template repository!"
  echo ""
  echo "This repository (automazeio/ccpm) is a template for others to use."
  echo "You should NOT create issues or PRs here."
  echo ""
  echo "To fix this:"
  echo "1. Fork this repository to your own GitHub account"
  echo "2. Update your remote origin:"
  echo "   git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
  echo ""
  echo "Or if this is a new project:"
  echo "1. Create a new repository on GitHub"
  echo "2. Update your remote origin:"
  echo "   git remote set-url origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
  echo ""
  echo "Current remote: $remote_url"
  exit 1
fi

# Create temporary files
mkdir -p /tmp/epic-sync-$$

# 1. Create Epic Issue
echo "Creating epic issue..."

# Extract content without frontmatter
sed '1,/^---$/d; 1,/^---$/d' "$epic_file" > /tmp/epic-sync-$$/epic-body-raw.md

# Remove "## Tasks Created" section and replace with Stats
awk '
  /^## Tasks Created/ {
    in_tasks=1
    next
  }
  /^## / && in_tasks {
    in_tasks=0
    # When we hit the next section after Tasks Created, add Stats
    if (total_tasks) {
      print "## Stats\n"
      print "Total tasks: " total_tasks
      print "Parallel tasks: " parallel_tasks " (can be worked on simultaneously)"
      print "Sequential tasks: " sequential_tasks " (have dependencies)"
      if (total_effort) print "Estimated total effort: " total_effort " hours"
      print ""
    }
  }
  /^Total tasks:/ && in_tasks { total_tasks = $3; next }
  /^Parallel tasks:/ && in_tasks { parallel_tasks = $3; next }
  /^Sequential tasks:/ && in_tasks { sequential_tasks = $3; next }
  /^Estimated total effort:/ && in_tasks {
    gsub(/^Estimated total effort: /, "")
    total_effort = $0
    next
  }
  !in_tasks { print }
  END {
    # If we were still in tasks section at EOF, add stats
    if (in_tasks && total_tasks) {
      print "## Stats\n"
      print "Total tasks: " total_tasks
      print "Parallel tasks: " parallel_tasks " (can be worked on simultaneously)"
      print "Sequential tasks: " sequential_tasks " (have dependencies)"
      if (total_effort) print "Estimated total effort: " total_effort
    }
  }
' /tmp/epic-sync-$$/epic-body-raw.md > /tmp/epic-sync-$$/epic-body.md

# Determine epic type (feature vs bug) from content
if grep -qi "bug\|fix\|issue\|problem\|error" /tmp/epic-sync-$$/epic-body.md; then
  epic_type="bug"
else
  epic_type="feature"
fi

# Create necessary labels first (ignore errors if they already exist)
gh label create "epic" --color "B60205" --description "Epic issues" 2>/dev/null || true
gh label create "epic:$epic_name" --color "D4C5F9" --description "Epic: $epic_name" 2>/dev/null || true
gh label create "$epic_type" --color "0052CC" --description "$epic_type issues" 2>/dev/null || true
gh label create "task" --color "7057ff" --description "Task issues" 2>/dev/null || true

# Create epic issue with labels
epic_output=$(gh issue create \
  --title "Epic: $epic_name" \
  --body-file /tmp/epic-sync-$$/epic-body.md \
  --label "epic,epic:$epic_name,$epic_type" 2>&1)

# Extract issue number from URL in output
epic_number=$(echo "$epic_output" | grep -o 'issues/[0-9]*' | grep -o '[0-9]*' | head -1)

if [ -z "$epic_number" ]; then
  echo "❌ Failed to create epic issue"
  exit 1
fi

echo "✅ Created epic issue #$epic_number"

# 2. Create Task Sub-Issues

# Check if gh-sub-issue is available
if gh extension list | grep -q "yahsan2/gh-sub-issue"; then
  use_subissues=true
  echo "Using gh-sub-issue extension"
else
  use_subissues=false
  echo "⚠️ gh-sub-issue not installed. Using fallback mode."
fi

# Count task files to determine strategy
task_count=$(ls "$epic_dir"/[0-9][0-9][0-9].md 2>/dev/null | wc -l)
echo "Creating $task_count sub-issues..."

# For Small Batches (<= 10 tasks): Sequential Creation
if [ "$task_count" -le 10 ]; then
  echo "Sequential creation for small batch..."
  
  > /tmp/epic-sync-$$/task-mapping.txt
  
  for task_file in "$epic_dir"/[0-9][0-9][0-9].md; do
    [ -f "$task_file" ] || continue

    # Extract task name from frontmatter (try name first, then title)
    task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
    if [ -z "$task_name" ]; then
      task_name=$(grep '^title:' "$task_file" | sed 's/^title: *//' | sed 's/^"//;s/"$//')
    fi

    # Strip frontmatter from task content
    sed '1,/^---$/d; 1,/^---$/d' "$task_file" > /tmp/epic-sync-$$/task-body.md

    # Skip empty task names
    if [ -z "$task_name" ]; then
      echo "⚠️ Skipping task with empty name: $task_file"
      continue
    fi
    
    # Create sub-issue with labels
    if [ "$use_subissues" = true ]; then
      task_body=$(cat /tmp/epic-sync-$$/task-body.md)
      task_output=$(gh sub-issue create \
        --parent "$epic_number" \
        --title "$task_name" \
        --body "$task_body" \
        --label "task,epic:$epic_name" 2>&1)
      task_number=$(echo "$task_output" | grep -o 'issues/[0-9]*' | grep -o '[0-9]*' | head -1)
    else
      task_output=$(gh issue create \
        --title "$task_name" \
        --body-file /tmp/epic-sync-$$/task-body.md \
        --label "task,epic:$epic_name" 2>&1)
      task_number=$(echo "$task_output" | grep -o 'issues/[0-9]*' | grep -o '[0-9]*' | head -1)
    fi

    if [ -n "$task_number" ]; then
      echo "✅ Created task #$task_number: $task_name"
      # Record mapping for renaming
      echo "$task_file:$task_number" >> /tmp/epic-sync-$$/task-mapping.txt
    else
      echo "❌ Failed to create task: $task_name"
    fi
  done
else
  echo "❌ Parallel creation not implemented yet. Please implement parallel processing for large task batches."
  exit 1
fi

# 3. Rename Task Files and Update References

echo "Updating task references and renaming files..."

# Create mapping from old task numbers (001, 002, etc.) to new issue IDs
> /tmp/epic-sync-$$/id-mapping.txt
while IFS=: read -r task_file task_number; do
  # Extract old number from filename (e.g., 001 from 001.md)
  old_num=$(basename "$task_file" .md)
  echo "$old_num:$task_number" >> /tmp/epic-sync-$$/id-mapping.txt
done < /tmp/epic-sync-$$/task-mapping.txt

# Process each task file
while IFS=: read -r task_file task_number; do
  new_name="$(dirname "$task_file")/${task_number}.md"

  # Read the file content
  content=$(cat "$task_file")

  # Update depends_on and conflicts_with references
  while IFS=: read -r old_num new_num; do
    # Update arrays like [001, 002] to use new issue numbers
    content=$(echo "$content" | sed "s/\\b$old_num\\b/$new_num/g")
  done < /tmp/epic-sync-$$/id-mapping.txt

  # Write updated content to new file
  echo "$content" > "$new_name"

  # Remove old file if different from new
  [ "$task_file" != "$new_name" ] && rm "$task_file"

  # Update github field in frontmatter
  # Add the GitHub URL to the frontmatter
  repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || gh repo view | grep '^name:' | awk '{print $2}')
  github_url="https://github.com/$repo/issues/$task_number"

  # Update frontmatter with GitHub URL and current timestamp
  current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Use sed to update the github and updated fields
  sed -i.bak "/^github:/c\\github: $github_url" "$new_name"
  sed -i.bak "/^updated:/c\\updated: $current_date" "$new_name"
  rm "${new_name}.bak" 2>/dev/null || true

  echo "✅ Renamed $(basename "$task_file") → $(basename "$new_name")"
done < /tmp/epic-sync-$$/task-mapping.txt

# 4. Update Epic with Task List (Fallback Only)

if [ "$use_subissues" = false ]; then
  echo "Adding task list to epic issue..."
  
  # Get current epic body
  gh issue view "$epic_number" --json body -q .body > /tmp/epic-sync-$$/epic-body.md

  # Append task list
  echo "" >> /tmp/epic-sync-$$/epic-body.md
  echo "## Tasks" >> /tmp/epic-sync-$$/epic-body.md
  
  for task_file in "$epic_dir"/[0-9]*.md; do
    [ -f "$task_file" ] || continue
    
    task_number=$(basename "$task_file" .md)
    task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
    echo "- [ ] #${task_number} ${task_name}" >> /tmp/epic-sync-$$/epic-body.md
  done

  # Update epic issue
  gh issue edit "$epic_number" --body-file /tmp/epic-sync-$$/epic-body.md
fi

# 5. Update Epic File

echo "Updating epic file..."

# Get repo info
repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || gh repo view | grep '^name:' | awk '{print $2}')
epic_url="https://github.com/$repo/issues/$epic_number"
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Update epic frontmatter
sed -i.bak "/^github:/c\\github: $epic_url" "$epic_file"
sed -i.bak "/^updated:/c\\updated: $current_date" "$epic_file"
rm "${epic_file}.bak" 2>/dev/null || true

# Update Tasks Created Section
cat > /tmp/epic-sync-$$/tasks-section.md << 'EOF'
## Tasks Created
EOF

# Add each task with its real issue number
for task_file in "$epic_dir"/[0-9]*.md; do
  [ -f "$task_file" ] || continue

  # Get issue number (filename without .md)
  issue_num=$(basename "$task_file" .md)

  # Get task name from frontmatter (try name first, then title)
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  if [ -z "$task_name" ]; then
    task_name=$(grep '^title:' "$task_file" | sed 's/^title: *//' | sed 's/^"//;s/"$//')
  fi

  # Get parallel status
  parallel=$(grep '^parallel:' "$task_file" | sed 's/^parallel: *//')

  # Add to tasks section
  echo "- [ ] #${issue_num} - ${task_name} (parallel: ${parallel})" >> /tmp/epic-sync-$$/tasks-section.md
done

# Add summary statistics
total_count=$(ls "$epic_dir"/[0-9]*.md 2>/dev/null | wc -l)
parallel_count=$(grep -l '^parallel: true' "$epic_dir"/[0-9]*.md 2>/dev/null | wc -l)
sequential_count=$((total_count - parallel_count))

cat >> /tmp/epic-sync-$$/tasks-section.md << EOF

Total tasks: ${total_count}
Parallel tasks: ${parallel_count}
Sequential tasks: ${sequential_count}
EOF

# Replace the Tasks Created section in epic.md
# First, create a backup
cp "$epic_file" "${epic_file}.backup"

# Use awk to replace the section
awk '
  /^## Tasks Created/ {
    skip=1
    while ((getline line < "/tmp/epic-sync-'$$'/tasks-section.md") > 0) print line
    close("/tmp/epic-sync-'$$'/tasks-section.md")
  }
  /^## / && !/^## Tasks Created/ { skip=0 }
  !skip && !/^## Tasks Created/ { print }
' "${epic_file}.backup" > "$epic_file"

# Clean up
rm "${epic_file}.backup"

# 6. Create Mapping File

echo "Creating GitHub mapping file..."

cat > "$epic_dir/github-mapping.md" << EOF
# GitHub Issue Mapping

Epic: #${epic_number} - https://github.com/${repo}/issues/${epic_number}

Tasks:
EOF

# Add each task mapping
for task_file in "$epic_dir"/[0-9]*.md; do
  [ -f "$task_file" ] || continue

  issue_num=$(basename "$task_file" .md)
  task_name=$(grep '^name:' "$task_file" | sed 's/^name: *//')
  if [ -z "$task_name" ]; then
    task_name=$(grep '^title:' "$task_file" | sed 's/^title: *//' | sed 's/^"//;s/"$//')
  fi

  echo "- #${issue_num}: ${task_name} - https://github.com/${repo}/issues/${issue_num}" >> "$epic_dir/github-mapping.md"
done

# Add sync timestamp
echo "" >> "$epic_dir/github-mapping.md"
echo "Synced: $(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$epic_dir/github-mapping.md"

# 7. Create Worktree

echo "Creating development worktree..."

# Ensure main is current
git checkout main
git pull origin main

# Create worktree for epic (remove if exists)
if [ -d "../epic-$epic_name" ]; then
  git worktree remove "../epic-$epic_name" --force 2>/dev/null || true
fi

git worktree add "../epic-$epic_name" -b "epic/$epic_name" 2>/dev/null || git worktree add "../epic-$epic_name" "epic/$epic_name"

echo "✅ Created worktree: ../epic-$epic_name"

# 8. Output

echo ""
echo "✅ Synced to GitHub"
echo "  - Epic: #${epic_number} - Epic: $epic_name"
echo "  - Tasks: ${task_count} sub-issues created"
echo "  - Labels applied: epic, task, epic:${epic_name}"
echo "  - Files renamed: 001.md → {issue_id}.md"
echo "  - References updated: depends_on/conflicts_with now use issue IDs"
echo "  - Worktree: ../epic-$epic_name"
echo ""
echo "Next steps:"
echo "  - Start parallel execution: /pm:epic-start $epic_name"
echo "  - Or work on single issue: /pm:issue-start {issue_number}"
echo "  - View epic: https://github.com/${repo}/issues/${epic_number}"

# Clean up
rm -rf /tmp/epic-sync-$$

exit 0