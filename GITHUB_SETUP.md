# GitHub Setup Guide

## Quick Setup Steps

### 1. Create Repository on GitHub

1. Go to https://github.com/new
2. Repository name: `fbla-member-engagement-app` (or your choice)
3. Description: "FBLA Mobile App - 2025-2026 Competition"
4. **Keep it Private** (or Public if you prefer)
5. **DO NOT** initialize with README (we already have one)
6. Click "Create repository"

### 2. Initialize and Push from Windows

Open PowerShell in the project directory and run:

```powershell
# Navigate to project directory (if not already there)
cd "c:\Users\Milind Kopikare\Code\mobile_app"

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit - FBLA Member Engagement App scaffold"

# Add your GitHub repository as remote
# Replace YOUR_USERNAME with your actual GitHub username
git remote add origin https://github.com/YOUR_USERNAME/fbla-member-engagement-app.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 3. Clone on Mac

On your Mac, open Terminal and run:

```bash
# Navigate to where you want the project
cd ~/Documents/Projects  # or your preferred location

# Clone the repository
# Replace YOUR_USERNAME with your actual GitHub username
git clone https://github.com/YOUR_USERNAME/fbla-member-engagement-app.git

# Navigate into the project
cd fbla-member-engagement-app

# Install Flutter dependencies
flutter pub get

# Connect iPhone and run
flutter run
```

## Alternative: Using GitHub Desktop

### On Windows:
1. Download GitHub Desktop: https://desktop.github.com
2. Install and sign in with your GitHub account
3. Click "Add" → "Add Existing Repository"
4. Choose: `c:\Users\Milind Kopikare\Code\mobile_app`
5. Click "Publish repository"
6. Choose name and privacy settings
7. Click "Publish repository"

### On Mac:
1. Download GitHub Desktop for Mac
2. Sign in with same GitHub account
3. Click "Clone a repository"
4. Select your repository
5. Choose location and clone
6. Open in VS Code or your preferred editor

## Verify Files are Tracked

After running `git add .`, verify what will be committed:

```powershell
# See what files are staged
git status

# You should see files like:
# - lib/
# - pubspec.yaml
# - README.md
# - etc.

# You should NOT see:
# - .dart_tool/
# - build/
# - .flutter-plugins
# (These are ignored by .gitignore)
```

## Useful Git Commands

```bash
# Check status
git status

# Pull latest changes (when working across machines)
git pull

# Make changes, then:
git add .
git commit -m "Description of changes"
git push

# See commit history
git log --oneline

# Create a branch for new features
git checkout -b feature-name
```

## Tips for Working Across Machines

1. **Always pull before starting work:**
   ```bash
   git pull
   ```

2. **Commit and push after each work session:**
   ```bash
   git add .
   git commit -m "Describe what you did"
   git push
   ```

3. **Don't commit build files** (already handled by .gitignore)

4. **After cloning on Mac, run:**
   ```bash
   flutter pub get
   cd ios
   pod install  # If needed
   ```

## Troubleshooting

### "Repository not found"
- Check the URL is correct
- Make sure you're logged into the right GitHub account
- Verify the repository exists and you have access

### "Permission denied"
- You may need to authenticate with GitHub
- Use a personal access token instead of password
- Or set up SSH keys

### "Large files" warning
- The .gitignore should prevent this
- If it happens, don't commit build/ or .dart_tool/ folders

### Changes not syncing
```bash
# Force pull (be careful - this overwrites local changes)
git fetch --all
git reset --hard origin/main

# Or stash your changes first
git stash
git pull
git stash pop
```

## What Gets Committed

✅ **DO commit:**
- All `.dart` files in `lib/`
- `pubspec.yaml`
- All `.md` documentation files
- `.gitignore`

❌ **DON'T commit:**
- `build/` folder
- `.dart_tool/` folder
- `ios/Pods/` folder
- `.flutter-plugins` files
- Generated files
- IDE-specific files (`.vscode/`, `.idea/`)

The `.gitignore` file handles this automatically!

---

## Quick Reference

**First time setup (Windows):**
```powershell
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
git push -u origin main
```

**Clone on Mac:**
```bash
git clone https://github.com/YOUR_USERNAME/REPO_NAME.git
cd REPO_NAME
flutter pub get
```

**Regular workflow:**
```bash
git pull                           # Get latest changes
# ... make changes ...
git add .                          # Stage changes
git commit -m "Description"        # Commit changes
git push                           # Push to GitHub
```

---

You're all set! After pushing to GitHub, you can access your code from anywhere. 🚀
