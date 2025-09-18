# Project Setup Guide

This guide walks you through getting **Viktor Orbán: Endless Escape** running locally, from cloning the repository to playing the game and producing builds.

## 1. Requirements

Before you begin, make sure the following tools are installed on your machine:

| Requirement | Notes |
| --- | --- |
| **Git** | Required to clone the repository. Any modern Git (2.30+) works.
| **Godot 4.x (Standard or .NET build)** | The game project targets Godot 4 (see `game/project.godot`). Install the latest 4.x stable release for best results.
| **Godot Export Templates** | Needed only if you plan to produce desktop, web, or mobile builds from the editor.
| **Zip utility (optional)** | Helpful if you intend to package exported builds for distribution.

> **Tip:** On Windows you can install Godot via the official `.zip` download. On macOS use the official `.dmg` or Homebrew (`brew install --cask godot`). On Linux you can use the official `.zip`, Flatpak (`flatpak install org.godotengine.Godot`), or your distro package.

## 2. Clone the Repository

1. Choose a folder on your machine where you want the project to live.
2. Clone the repository:
   ```bash
   git clone https://github.com/<owner>/vityabird.git
   cd vityabird
   ```
   Replace `<owner>` with the GitHub username or organization that hosts your fork (for example, `git clone https://github.com/vityabird/vityabird.git`).

If your team uses Git LFS for large binary assets, run `git lfs install` beforehand and ensure `git lfs pull` completes after cloning. (This repository currently stores assets directly, so LFS is optional.)

## 3. Inspect the Project Layout

Key directories you will interact with:

- `game/` – The Godot project (scenes, scripts, assets).
- `assets/` – Source art and audio files.
- `docs/` – Narrative and design documentation.
- `backend/` – Planning notes for cloud functions and services.

All playable content lives under `game/`, and `project.godot` is the file you open in Godot.

## 4. Open the Project in Godot

You can open the project either through the Godot Project Manager GUI or via the command line.

### Using the GUI
1. Launch Godot 4.x.
2. Click **Import** in the Project Manager.
3. Navigate to the cloned repository, select `game/project.godot`, and click **Import & Edit**.
4. The editor will load the project and import assets on first launch. This may take a minute the first time.

### Using the Command Line
If you have the `godot4` executable on your PATH, run:
```bash
godot4 -e game/project.godot
```
The `-e` flag opens the editor directly on the project.

## 5. Play the Game Locally

Once the project is open in the Godot editor:

1. Verify that the main scene is set to `res://scenes/main.tscn` (already configured in `project.godot`).
2. Click the **Play** button (triangle icon) or press <kbd>F5</kbd> to launch the game.
3. Godot will open a separate game window where you can play the current build.

If you make changes to scripts or scenes, press <kbd>F5</kbd> again to test the new version.

## 6. Export Builds

To produce runnable builds:

1. Install the official Godot export templates if you have not already (Godot will prompt you the first time you open the **Export** window).
2. In Godot, go to **Project → Export…**.
3. Add the desired preset(s) (e.g., **Windows Desktop**, **Linux/X11**, **macOS**, **Web**, **Android**, **iOS**).
4. Configure the output path and platform-specific options as needed.
5. Click **Export Project** to generate the build.

For headless exports (useful for CI/CD), you can also run:
```bash
godot4 --headless --export-release "Windows Desktop" build/VityaBird.exe
```
Replace the preset name and output path to match your configuration.

## 7. Troubleshooting & Tips

- **Editor version mismatch:** If you open the project with an older Godot 3.x build, it will fail to load. Always use a Godot 4.x release.
- **Missing assets:** If sprites or audio do not appear, ensure all files were pulled during the Git clone. Re-run `git pull` or `git lfs pull` if using LFS.
- **Performance issues:** Use **Project → Project Settings → Display** to adjust resolution or run the game in windowed mode while testing.
- **Command not found:** If `godot4` is not on your PATH, either add the executable or launch via the GUI.

## 8. Next Steps

- Review `README.md` for the current design vision.
- Explore the scripts under `game/scripts/` to understand gameplay logic.
- Consult `docs/` for narrative context and feature plans.

You are now ready to iterate on the project, export builds, and share the game with your team!
