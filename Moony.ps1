# --------------------------------------- FIRST ARG / VERSION EXPANDER ---------------------------------------

$Host.UI.RawUI.WindowTitle = "Moony [0.3]"

switch ($args[0]){ # Argument 1: Version

    {$_ -eq 'stop'}{"Stopping Java";Get-Process javaw -Ea Ignore | Stop-Process -Ea Ignore;exit}
    # If often use this to kill Minecraft after debugging
    
    {$_ -in (7,1.7,1.7.10)}{$script:ver = 1.7}
    {$_ -in (8,1.8,1.8.9)}{$script:ver = 1.8}
    {$_ -in (12,1.12,1.12.2)}{$script:ver = 1.12}
    {$_ -in (16,1.16,1.16.5)}{$script:ver = 1.16}
    {$_ -in (17,1.17,1.17.1)}{$script:ver = 1.17}
    {$_ -in ('l','latest',18,1.18)}{$script:ver = 1.18}
        # $ver is the shortened version name, there's a switch statement that expands the versions later (-7.10,-8.9,-12.2, etc...) 
        # If you're struggling with 1.18 and Lunar updated to 1.18.x that might be why it's not launching

    {$_ -eq 'f'}{$script:server = 'eu.minemen.club';$script:ver = 1.7;$account = 'Couleur'}
        # If you want to make your own fast preset, you can add it here to set a server IP, version and account
        # I recommend just making it one letter so it's faster to type, you'll get blazing fast muscle memory in no time

    {$_ -in 'e','edit','conf','config','settings'}{

        # s/o yanderedev, this tries VSCode, Sublime Text, Notepad++ then falls back to notepad

        if (Get-Command code -ErrorAction Ignore){
            $TextEditor = (Get-Command code -ErrorAction Ignore).Source
        }elseif(Get-Command subl.exe -ErrorAction Ignore){
            $TextEditor = (Get-Command subl.exe -ErrorAction Ignore).Source
        }elseif(Test-Path "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"){
            $TextEditor = "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe"
        }elseif(Get-Command notepad++.exe -ErrorAction Ignore){
            $TextEditor = (Get-Command notepad++.exe -ErrorAction Ignore).Source
        }else{
            $TextEditor = (Get-Command notepad.exe).Source
        }

        & $TextEditor `"$($MyInvocation.MyCommand.Path)`"
        exit
    }

    $null{
@"
Moony is ridiculously simple to use, you can just call it from the Run window (Windows+R) as "mn"

Here's a few examples:

mn <version> <server> <account> [Verbose]
 There's also a few utilities like 'edit' to open up the script to tune it and 'stop' to kill javaw

mn 8 hy
 Launches Lunar Client in version 1.8.9, with whatever account you previously had selected

mn 7 em sweatyPvPalt420
 Launches Minecraft in version 1.7.10, join eu.minemen.club, and switch to the sweatyPvPalt420 account
 Tip: you can also just type the first few letters of your name

mn edit
 Opens the config file in VSCode, Notepad++ or Notepad, you can also just say e instead of edit ;)

mn MyPreset
 If you take a second to tune the script, you can set a custom version, server and account as a preset and call it from the Run window

Also if you are a CLI lover I made it so you can also call it from the command line (s/o minimoony <3)
"@
pause
exit
    }
}

if (($args | Select-Object -Last 1) -in ('-v', 'v', '-verbose','verbose')){
    # Sets up Verbose if specified and removes it from args
    $script:Verbose = $true
    $VerbosePreference = 'Continue'
    $args = $args | Select-Object -SkipLast 1
}

# --------------------------------------- SERVER EXPANDER ---------------------------------------

switch ($args[1]){ # Argument 2: Server IP

    # mmc
    {$_ -in ('eu','eummc','eu.minemen.club','em')}{$script:server = 'eu.minemen.club'}
    {$_ -in ('na','mmc','nammc','na.minemen.club','nm')}{$script:server = 'na.minemen.club'}
    {$_ -in ('as','asmmc','as.minemen.club','am')}{$script:server = 'as.minemen.club'}

    # lunar
    {$_ -in ('lunar','nalunar','lunarna','nl','lunar.gg')}{$script:server = 'na.lunar.gg'}
    {$_ -in ('lunarw','lunarwest','westlunar','wlunar','wl','west.lunar.gg')}{$script:server = 'west.lunar.gg'}
    {$_ -in ('eulunar','lunareu','el','eu.lunar.gg')}{$script:server = 'eu.lunar.gg'}

    # smaller prac servers
    {$_ -in ('ak','akuma','akuma.gg')}{$script:server = 'akuma.gg'}
    {$_ -in ('an','anteiku','anteiku.us','ant')}{$script:server = 'anteiku.us'}
    {$_ -in ('mpl','mpl.gg')}{$script:server = 'mpl.gg'}


    #miscellaneous
    {$_ -in ('h','hy','hypixel','hypixel.net')}{$script:server = 'hypixel.net'}
    {$_ -in ('pvpdojo','pd')}{$script:server = 'pvpdojo.com'}
    {$_ -in ('viper','viperhcf','vipermc')}{$script:server = 'vipermc.com'}
    {$_ -in ('pvplegacy','pl','pvplegacy.net')}{$script:server = 'pvplegacy.net'}
    {$_ -in ('eri','erisium','erisium.com','mc.erisium.com')}{$script:server = 'mc.erisium.com'}

    # Feel free to add your own, here's a template (don't forget to add quotation marks at the start and end!), template:
    {$_ -in ('serv','server')}{$script:server = 'region.domain.tld'}

    default{$script:server = $_} # If you're using another IP it replugs into the expected variable

}

$settings = @{

    DedicatedGigaBytesOfRam = 2.5
        # You likely won't need more, unless you're gonna play in big maps with a shit ton of mods (Default: 2.5)

    WindowedHeight = 480
    WindowedWidth = 854
        # This will only affect Windowed resolution (Default: 480,854)

    LunarClientCosmetics = $false
        # Set this to false to completly disable Lunar's cosmetics
        # I have no idea what it's effect is if you are using LCProxy / Solar Tweaks

    MinecraftDir = "$env:APPDATA\.minecraft"
        # If you're using a custom Minecraft directory, make sure it has an asset folder, else it'll fail to load the textures
        # You can copy your asset folder from one of your default Minecraft directory
    LCDirectory = "$env:USERPROFILE\.lunarclient"
        # You most likely won't need to change this since Lunar Client does not allow you to change their install directory, still adding this for the smart LFL/PL fellas

    Java_Executable = ""
        # Feel free to put a path to your JRE here (it'll automatic detect GraalVM in ProgramData/LC's Zulu of you don't set anything)
        # Remember to surround it by single/double quotes

}

$JVM_Arguments = @( # Non GraalVM arguments

    '-XX:+UseZGC'
        # Try removing that if your Minecraft tends to freeze / crash, this is an optimized garbage collector

    "-Xms$($settings.DedicatedGigaBytesOfRam*1024)m"
    "-Xmx$($settings.DedicatedGigaBytesOfRam*1024)m"
    '-XX:+DisableAttachMechanism'
    "-Djava.library.path=$(Join-Path $settings.LCDirectory offline\$ver\natives) " # This needs to be in here for some reason
        

) -join ' '
    # If the JRE's path contains 'GraalVM', it'll append extra JVM arguments which you can find later down

# --------------------------------------- ACCOUNT SWITCHER ---------------------------------------

if($args[2]){

    $file = "$($settings.LCDirectory)\settings\game\accounts.json"

    $json = Get-Content  $file | ConvertFrom-Json

    ForEach($account in ($json.accounts | Get-Member -MemberType Properties).Name){

        if ($json.accounts.$($account).MinecraftProfile.name -like "$($args[2])*"){

            $json.activeAccountLocalId = $account

            Set-Content $file -Value $($json | ConvertTo-Json -Depth 10) -Force -ErrorAction SilentlyContinue

            $script:Succeed = $true
        }
    }
    if (-Not($Succeed)){
        Write-Warning "Could not find a matching account that is connected with the IGN $($args[2])"
        ''
        Write-Host "Lunar Client will launch (and may join a server if you specified it) with the account: $($json.accounts.($json.activeAccountLocalId).minecraftProfile.name)"
        pause
    }
}

Write-Host "Launching Lunar Client version $ver$(if ($server){", joining server $server"})$(if ($args[2]){" and switching to account $($args[2])"})" -ForegroundColor Green
''


if (-Not($settings.Java_Executable)){ # If you don't set anything up there (by default), this'll find one for you

    $Temurin = (Get-Command temurin17-javaw.exe -Ea Ignore).Source | Sort-Object -Descending | Select-Object -Last 1
    $GraalVM = Convert-Path "$env:ProgramData\GraalVM\bin\javaw.exe" -ErrorAction Ignore

    $Zulu = Convert-Path "$env:USERPROFILE\.lunarclient\jre\1.*\zulu*-jre*-win_x*\bin\javaw.exe" -Ea Ignore | Sort-Object -Descending | Select-Object -Last 1
    $FallbackJRE = (Get-Command javaw.exe -Ea Ignore).Source | Sort-Object -Descending | Select-Object -First 1

    if ($Temurin){$settings.Java_Executable = $Temurin}
    elseif ($GraalVM){$settings.Java_Executable = $GraalVM}
    elseif($Zulu){$settings.Java_Executable = $Zulu}
    elseif ($FallbackJRE){$settings.Java_Executable = $FallbackJRE

@"
Could not find Lunar Client's java executable, using javaw.exe from path (may fail)

Will use the following JRE: $($settings.Javaw_Executable)
"@
            
            
        }else{

            @"
A java runtime environment (JRE) could not be found on your system, would you like to install GraalVM? [Press Y/N]
"@

switch (choice.exe /N | Out-Null){
    1{ # Yes

        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            # This forces PowerShell to use a more secure TLS version
    
        if(-Not(Get-Command scoop.cmd -Ea SilentlyContinue)){

            Set-ExecutionPolicy Unrestricted -Scope Process -Force
    
            Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/lukesampson/scoop/master/bin/install.ps1')
        }
    
        & scoop.cmd bucket add extras
        & scoop.cmd install https://raw.githubusercontent.com/couleur-tweak-tips/utils/main/bucket/temurin17-jdk.json

    }
    2{ # No
@"
You have two options:

- Launch Lunar Client and let it download Zulu
- Open up launcher.ps1 and manually set the JRE's path, in the JRE's bin folder, select java.exe if you wish to console, or javaw.exe if you don't
"@
pause
exit
    }
}
    }

}


if ($settings.Java_Executable -like "*GraalVM*"){ # Appends these JVM arguments only if path contains 'GraalVM'

    $settings.JVM_Arguments += @(

        # Put your GraalVM related JVM Args here
        
        '-XX:+UnlockExperimentalVMOptions'
        '-XX:+EnableJVMCI'
        '-XX:+UseJVMCICompiler'
        '-XX:+EagerJVMCI'
        '-Djvmci.Compiler=graal'

    ) -join ' '
}

switch ($ver){
    # Fix Asset Index
    1.7{Set-Variable -Name version -Value 1.7.10}
    1.8{Set-Variable -Name version -Value 1.8}
    1.12{Set-Variable -Name version -Value 1.12}
    1.16{Set-Variable -Name version -Value 1.16}
    1.17{Set-Variable -Name version -Value 1.17}
    1.18{Set-Variable -Name version -Value 1.18}
    default{Write-Warning "Unknown version provided: $ver"
    pause
    exit}
}

$libraries = @(
'--add-modules jdk.naming.dns'
'--add-exports jdk.naming.dns/com.sun.jndi.dns=java.naming'
'-Dlog4j2.formatMsgNoLookups=true' # Fixes that java exploit
'--add-opens java.base/java.io=ALL-UNNAMED'
) -join ' '

$jars = @(

    # Jars required to make Lunar Client work properly
    # I'm not indicating paths because I start javaw.exe with the WorkingDirectory in the folders where these files are at

    '-cp vpatcher-prod.jar'
    'lunar-prod-optifine.jar'
    'lunar-libs.jar'
    'lunar-assets-prod-1-optifine.jar'
    'lunar-assets-prod-2-optifine.jar'
    'lunar-assets-prod-3-optifine.jar'
    'OptiFine.jar'

) -join ';'

if ($settings.LunarClientCosmetics){

    $texturesDir = Join-Path $settings.LCDirectory textures

}else{
    $texturesDir = "`"`""
}

if(-Not($settings.WindowedHeight)){$settings.WindowedHeight = 480}
if(-Not($settings.WindowedWidth)){$settings.WindowedWidth = 854}


$config = @(
'com.moonsworth.lunar.patcher.LunarMain'
"--version $ver"
'--accessToken 0'
"--assetIndex $version"
'--userProperties {}'
"--gameDir $($settings.MinecraftDir)"
"--texturesDir $texturesDir"
"--assetDir $(Join-Path $settings.MinecraftDir assets)"
"--width $($settings.WindowedWidth)"
"--height $($settings.WindowedHeight)"
)

if ($server){
    $config += "-server $server" 
}

<# If you wish to add --hwid and --launcherversion:

You can parse them by launching Lunar Client with the official Launcher and typing this in PowerShell:

(Get-WmiObject Win32_Process -Filter "name = 'javaw.exe'").CommandLine.Split(' ') | Select-Object -Last 8

#>

$Parameters = @{

    FilePath = $settings.Java_Executable
    WorkingDirectory = Join-Path $settings.LCDirectory offline/$ver
        # Makes it so we don't have to specify a path for each file in $jars

    ArgumentList = @($libraries;$JVM_Arguments;$jars;$config) -join ' '
    NoNewWindow = $true
}

if ($Verbose){

    Write-Verbose "JRE"
    $Parameters.FilePath

    Write-Verbose "Working Directory"
    $Parameters.WorkingDirectory
    
    Write-Verbose "Libraries"
    $libraries -Split ' '
    
    Write-Verbose "JVM Arguments"
    $JVM_Arguments -Split ' '

    Write-Verbose "Agents (split by ;)"
    $jars -Split ';'
    
    Write-Verbose "Config"
    $config
}

Start-Process @Parameters

Start-Sleep 10
exit