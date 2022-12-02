## 🌙 **Moony**: a minimalistic and unlocked third-party [Lunar Client](https://lunarclient.com) launcher

### 🚀 **At launch**
* Choose the version directly, no need to launch then have to ``Click to view launch options``
* Select a server that will be joined automatically when Minecraft finishes launching
* Select an account to switch to at launch
* Doesn't get in your way, you can type your command and go back to whatever you were doing while waiting for it to finish launching
### 🔓**Unlocked features**
* You get to choose when to update, (e.g a controversial update happens that removes your favorite feature), unlike Lunar Client's official launcher which phones home every time you launch it
* Make Minecraft significantly more stable (1.8+) with a custom JRE (GraalVM, learn more in [CTT](http://dsc.gg/CTT))
* Make your own shortened version/server/account combos to quickly launch Moony (e.g you could make typing `mn MyPreset` launch 1.8, join eu.minemen.club on account MyPvPAlt123)
* Completly strip out every cosmetics ([lmk](https://t.me/Couleur) if you know a way for emotes)

# ⌨️ Using Moony
### Moony is ridiculously simple to use, you can just call it from the Run window (Windows+R) as "mn"
I made it very flexible so you can either type full server IPs / versions or just their shortened nicks (7,8,12,16,17,18)

## 🖼 Here's a few examples:

```
mn <version> <server> <account> [-Verbose]
```

 There's also a few utilities like 'edit' to open up the script to tune it and 'stop' to kill javaw
```
mn 8 hy
```
 Launches Lunar Client in version 1.8.9, with whatever account you previously had selected

```
mn 7 em sweatyPvPalt420
```
 Launches Minecraft in version 1.7.10, join ``eu.minemen.club``, and switch to the sweatyPvPalt420 account
 Tip: you can also just type the first few letters of your name
```
mn edit
```
 Opens the config file in your favorite text editor (VSCode, Sublime Text Notepad++ or Notepad), you can also just say e instead of edit ;)
```
mn MyPreset
```
 If you take a second to tune the script, you can set a custom version, server and account as a preset and call it from the Run window.

# 🥄 Installation

I recommend using installing scoop and adding my bucket by pasting the commands down below in a PowerShell window:

This will make automatically add the shortcuts to path and let you update Moony by sending a single [command](#-updating).

### \# Install scoop:
```PowerShell
[System.Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
```

### \# Install git (for updates)
```
scoop install main/git
```
### \# Add my [bucket](https://github.com/couleur-tweak-tips/utils)
```
scoop bucket add utils https://github.com/couleur-tweak-tips/utils
```
### \# Install [Moony](https://github.com/couleur-tweak-tips/utils/blob/main/bucket/Moony.json)
```
scoop install utils/moony
```


## ⏬ Updating

```
scoop.cmd update utils/moony
```

For fiddlers: feel free to download [Moony.ps1](https://github.com/couleur-tweak-tips/Moony/blob/main/Moony.ps1) and work with your own shortcut