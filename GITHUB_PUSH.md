# GitHub Push Guide

This file explains how to prepare the project and push it to GitHub safely.

## 1. Clean The Repository

Before pushing:

- make sure build folders are not tracked
- make sure Qt Creator and generated files are ignored
- make sure private local paths are not committed by accident

Check:

```bash
git status
```

## 2. Initialize Git If Needed

If the folder is not already a Git repository:

```bash
git init
git branch -M main
```

If it already is a Git repo, skip this step.

## 3. Review The Ignore Rules

This repository now includes `.gitignore`.

It is meant to ignore:

- `build/`, `build-qt6/`
- `CMakeFiles/`, `CMakeCache.txt`
- Qt Creator local files
- generated binaries and cache files

## 4. Create A GitHub Repository

On GitHub:

1. Create a new repository.
2. Choose the repository name.
3. Do not auto-add a README if this local repo already has one.
4. Copy the remote URL.

Example remote:

```bash
git remote add origin git@github.com:YOUR_NAME/circlebarsui.git
```

Or with HTTPS:

```bash
git remote add origin https://github.com/YOUR_NAME/circlebarsui.git
```

If `origin` already exists:

```bash
git remote set-url origin git@github.com:YOUR_NAME/circlebarsui.git
```

## 5. Add And Commit Files

Stage files:

```bash
git add .
```

Create the first commit:

```bash
git commit -m "Initial traffic robot monitoring UI"
```

## 6. Push To GitHub

```bash
git push -u origin main
```

If your default branch is different, push that branch instead.

## 7. Recommended Files To Have Before Public Push

- `README.md`
- `.gitignore`
- `LICENSE`
- `QUICKSTART.md`
- `DATABASE_SETUP.md`
- `PROJECT_TASKS.md`

## 8. Recommended Pre-Push Checklist

- [ ] The app builds on your machine
- [ ] The README matches the current codebase
- [ ] No local absolute secrets or tokens are committed
- [ ] Large build artifacts are ignored
- [ ] You are okay with publishing sample assets and screenshots
- [ ] The license is clear

## 9. Useful Commands

Show remote:

```bash
git remote -v
```

Show current branch:

```bash
git branch --show-current
```

Show commit history:

```bash
git log --oneline --decorate -n 10
```

Push a later update:

```bash
git add .
git commit -m "Update monitor UI and docs"
git push
```

## 10. If You Want A Better Public Repo

Before sharing widely, it is worth adding:

- screenshots in a `docs/` or `assets/` folder
- a `LICENSE` file
- GitHub Actions for CI builds
- issue templates
- pull request template

That is optional, but it makes the project much easier to maintain.
