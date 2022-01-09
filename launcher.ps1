param([float]$ver,[string]$ip)

$script:settings = @{

    DedicatedGigaBytesOfRam = 2.5
    # You likely won't need more, unless you're gonna play in big maps with a shit ton of mods (Default: 2.5)

    WindowedHeight = 480
    WindowedWidth = 854
    # This will only affect Windowed resolution (Default: 480,854)

    LunarClientCosmetics = $false
    # Set this to false to completly disable Lunar's cosmetics
    # I have no idea what it's effect is if you are using LCProxy / Solar Tweaks

    LCDirectory = "$env:USERPROFILE\.lunarclient"
    MinecraftDir = "$env:APPDATA\.minecraft"
    # If you're using a custom Minecraft directory, make sure it has an asset folder, else it'll fail to load the textures
    # You can copy your asset folder from one of your default Minecraft directory

    Java_Executable = ""
    # Feel free to put a path to your JRE here (it'll automatic detect GraalVM in ProgramData/LC's Zulu of you don't set anything)
    # Remember to surround it by single/double quotes

}

$JVM_Arguments = @(

    '-XX:+UseZGC'
    # Try removing that if your Minecraft tends to freeze / crash, this is an optimized garbage collector

    "-Xms$($settings.DedicatedGigaBytesOfRam*1024)m"
    "-Xmx$($settings.DedicatedGigaBytesOfRam*1024)m"
    '-XX:+DisableAttachMechanism'
    "-Djava.library.path=$(Join-Path $settings.LCDirectory offline\$ver\natives) " # This needs to be in here for some reason
        

) -join ' '
    # If the JRE path contains 'GraalVM', it'll append extra JVM arguments which you can find later down


if (-Not($settings.Java_Executable)){ # If you don't set anything up there (by default), this'll find one for you

    $Temurin = (Get-Command temurin17-javaw.exe -Ea Ignore).Source | Sort-Object -Descending | Select-Object -Last 1
    $GraalVM = Convert-Path "$env:ProgramData\GraalVM\bin\javaw.exe" -ErrorAction Ignore
    $Zulu = Convert-Path "$env:USERPROFILE\.lunarclient\jre\zulu*-jre*-win_x*\bin\javaw.exe" -Ea Ignore | Sort-Object -Descending | Select-Object -Last 1
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
    1.7{Set-Variable -Name version -Value 1.7.10}
    1.8{Set-Variable -Name version -Value 1.8.9}
    1.12{Set-Variable -Name version -Value 1.12.2}
    1.16{Set-Variable -Name version -Value 1.16.5}
    1.17{Set-Variable -Name version -Value 1.17.1}
    1.18{Set-Variable -Name version -Value 1.18.1}
    default{Write-Warning "Uknown version provided: $ver"
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

if ($ip){
    $config += "-server $ip" 
}

<# If you wish to add --hwid and --launcherversion:

You can parse them by launching Lunar Client with the official Launcher and typing this in PowerShell:

(Get-WmiObject Win32_Process -Filter "name = 'javaw.exe'").CommandLine.Split(' ') | Select-Object -Last 8

#>

$Parameters = @{

    FilePath = $settings.Java_Executable
    WorkingDirectory = Join-Path $settings.LCDirectory offline/$ver
        # Makes it so we don't have to specify a path for each file in $jars

    ArgumentList = @($libraries;$JVM_Arguments;$natives;$jars;$config) -join ' '
    NoNewWindow = $true
}
if ($Verbose){$Parameters | Format-Table}

Start-Process @Parameters

Start-Sleep 10
exit