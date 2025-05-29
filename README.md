Unofficial AppImage of Steam built on top of "[RunImage](https://github.com/VHSgunzo/runimage)", the portable single-file Linux container in unprivileged user namespaces

This includes 32bit libraries needed to run Steam, **it will also use the proprietary nvidia driver from the host**.

--------------------------------------------------
### NOTE: This wrapper is not verified by, affiliated with, or supported by Valve.

**The base software is under a proprietary license and unofficially repackaged as an AppImage for demonstration purposes, for the original authors, to promote this packaging format to them. Consider this package as "experimental". I also invite you to request the authors to release an official AppImage, and if they agree, you can show this repository as a proof of concept.**

--------------------------------------------------

### Features

- [Patched EAC-Glibc](https://www.youtube.com/watch?v=PhseQ0Kfe5w).
- `steam-screensaver-fix` which fixes the [issue](https://github.com/ValveSoftware/steam-for-linux/issues/5607) that Steam disables the screensaver even when no game is running.
- `zenity-gtk3` which prevents the broken theme issues of the gtk4 version, aka [flashbang](https://github.com/ValveSoftware/SteamOS/issues/1534).
- Bundles its own mesa from Arch Linux, so you don't have to deal with [outdated mesa](https://www.reddit.com/r/yuzu/comments/11307f0/glitches_on_steam_deck_flatpak_version_dont/j8o6gsa/) versions causing issues.
- [No performance issues](https://github.com/flatpak/flatpak/issues/4187) runs as fast as if it was a native distro package.
- Sandboxable with [aisap](https://github.com/mgord9518/aisap) (squashfs version only) with no performance issues either.
- "sudo" is not required, no need enable 32 bit repo, no need to install flatpak or snap, **it should even run on musl distros.**
- Can use a [portable home](https://docs.appimage.org/user-guide/portable-mode.html), so you can avoid all the [mess that Steam leaves in $HOME](https://github.com/ValveSoftware/steam-for-linux/issues/1890) and no need to settle with a hardcoded `~/.var` or `~/snap` either.
- Uses a patched bubblewrap that [allows](https://github.com/flathub/com.valvesoftware.Steam/issues/770) launching AppImages from Steam.
- Will use the nvidia driver from the host instead of downloading one, note that for this to happen you also need the 32bit nvidia driver, otherwise runimage will fallback to download it. 

---------------------------------

### How it works


## Installation

### Pho

This command requires [Pho](https://github.com/zyrouge/pho) to be installed.

```bash
pho install github --id steam-appimage ivan-hc/Steam-appimage
```

### Manual


1. Download the AppImage from https://github.com/ivan-hc/Steam-appimage/releases/latest
2. Made it executable
```
chmod a+x ./*.AppImage
```
3. Run it or simply double click on it. 
```
./*.AppImage
```
this may need seconds before you can use Steam.

This AppImage does NOT require libfuse2, being it a new generation one.

---------------------------------

### How to build it

Run the `steam-runimage.sh` if you want to the build the AppImage locally on your system.

---------------------------------

## Install and update it with ease

### *"*AM*" Application Manager* 
#### *Package manager, database & solutions for all AppImages and portable apps for GNU/Linux!*

[![Istantanea_2024-06-26_17-00-46 png](https://github.com/ivan-hc/AM/assets/88724353/671f5eb0-6fb6-4392-b45e-af0ea9271d9b)](https://github.com/ivan-hc/AM)

[![Readme](https://img.shields.io/github/stars/ivan-hc/AM?label=%E2%AD%90&style=for-the-badge)](https://github.com/ivan-hc/AM/stargazers) [![Readme](https://img.shields.io/github/license/ivan-hc/AM?label=&style=for-the-badge)](https://github.com/ivan-hc/AM/blob/main/LICENSE)

*"AM"/"AppMan" is a set of scripts and modules for installing, updating, and managing AppImage packages and other portable formats, in the same way that APT manages DEBs packages, DNF the RPMs, and so on... using a large database of Shell scripts inspired by the Arch User Repository, each dedicated to an app or set of applications.*

*The engine of "AM"/"AppMan" is the "APP-MANAGER" script which, depending on how you install or rename it, allows you to install apps system-wide (for a single system administrator) or locally (for each user).*

*"AM"/"AppMan" aims to be the default package manager for all AppImage packages, giving them a home to stay.*

*You can consult the entire **list of managed apps** at [**portable-linux-apps.github.io/apps**](https://portable-linux-apps.github.io/apps).*

## *Go to *https://github.com/ivan-hc/AM* for more!*

------------------------------------------------------------------------

| [***Install "AM"***](https://github.com/ivan-hc/AM) | [***See all available apps***](https://portable-linux-apps.github.io) | [***Support me on ko-fi.com***](https://ko-fi.com/IvanAlexHC) | [***Support me on PayPal.me***](https://paypal.me/IvanAlexHC) |
| - | - | - | - |

------------------------------------------------------------------------
