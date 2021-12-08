# PSHistory
PowerShell lookup for recent locations and commands

## How to use it

1. Install PSHistory module

```ps
Install-Module PSHistory
```

2. Define the following aliases in your `$PROFILE` file

```ps
Set-Alias -Name cd -Value Set-HistoricalLocation -Option AllScope
Set-Alias -Name hd -Value Show-HistoricalLocation -Option AllScope
```

3. Reload your profile

```ps
. $PROFILE
```

## How to use it

When you are changing directories with cd command, `PSHistory` tracks your location. `hd` command allows to switch to one of the recent directories.

![HiHjfS7LE5](https://user-images.githubusercontent.com/7759991/145283243-7acf3b3c-858c-403d-9cd9-89aed3f663f5.gif)
