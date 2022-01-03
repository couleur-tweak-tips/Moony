param([float]$ver,[string]$ip)
    # Parses the given settings & version then launches Lunar Client
    # It is recommended you tune the most common setting which I've regrouped at the start for your convenience

$DedicatedGigaBytesOfRam = 2.5
    # You likely won't need more, unless you're gonna play in big maps with a shit ton of mods (Default: 2.5)

$WindowedHeight = 480
$WindowedWidth = 854
    # This will only affect Windowed resolution (Default: 480,854)

$LunarClientCosmetics = $false
    # Set this to $false to completly disable Lunar's cosmetics
    # I have no idea what it's effect is if you are using LCProxy / Solar Tweaks

$LCDirectory = "$env:USERPROFILE\.lunarclient"
$MinecraftDir = "$env:APPDATA\.minecraft"
    # If you're using a custom Minecraft directory, make sure it has an asset folder, else it'll fail to load the textures
    # You can copy your asset folder from one of your default Minecraft directory

$Java_Executable = ""
    # Feel free to put a path to your JRE here (it'll automatic detect GraalVM in ProgramData/LC's Zulu of you don't set anything)
    # Remember to surround it by single or double quotes

$JVM_Arguments = @(

   # '-XX:+UseZGC'
        # Try removing that if your Minecraft tends to freeze / crash, this is an optimized garbage collector

    "-Xms$($DedicatedGigaBytesOfRam*1024)m"
    "-Xmx$($DedicatedGigaBytesOfRam*1024)m"
    '-XX:+DisableAttachMechanism'
    "-Djava.library.path=$(Join-Path $LCDirectory offline\$ver\natives) " # This needs to be in here for some reason
        
    # You can find GraalVM specific args later down

) -join ' '

if (-Not($Java_Executable)){ # If you don't set anything up there (by default), this'll find one for you

    $Temurin = (Get-Command temurin17-javaw.exe -Ea Ignore).Source | Sort-Object -Descending | Select-Object -Last 1
    $GraalVM = Convert-Path "$env:ProgramData\GraalVM\bin\javaw.exe" -ErrorAction Ignore
    $Zulu = Convert-Path "$env:USERPROFILE\.lunarclient\jre\zulu*-jre*-win_x*\bin\javaw.exe" -Ea Ignore | Sort-Object -Descending | Select-Object -Last 1
    $FallbackJRE = (Get-Command javaw.exe -Ea Ignore).Source | Sort-Object -Descending | Select-Object -First 1

    if ($Temurin){$Java_Executable = $Temurin}
    elseif ($GraalVM){$Java_Executable = $GraalVM}
    elseif($Zulu){$Java_Executable = $Zulu}
    elseif ($FallbackJRE){$Java_Executable = $FallbackJRE

@"
Could not find Lunar Client's java executable, using javaw.exe from path (may fail)

Will use the following JRE: $Javaw_Executable
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


if ($Java_Executable -like "*GraalVM*"){ # Appends these JVM arguments only if path contains 'GraalVM'

    $JVM_Arguments += @(

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

if ($LunarClientCosmetics){

    $texturesDir = $(Join-Path $LCDirectory textures)

}else{
    $texturesDir = "`"`""
}

if(-Not($WindowedHeight)){$WindowedHeight = 480}
if(-Not($WindowedWidth)){$WindowedWidth = 854}


$settings = @(
'com.moonsworth.lunar.patcher.LunarMain'
"--version $ver"
'--accessToken 0'
"--assetIndex $version"
'--userProperties {}'
"--gameDir $MinecraftDir"
"--texturesDir $texturesDir"
"--assetDir $(Join-Path $MinecraftDir assets)"
"--width $WindowedWidth"
"--height $WindowedHeight"
)

if ($ip){
    $settings += "-server $ip" 
}

<# If you wish to add --hwid and --launcherversion:

You can parse them by launching Lunar Client with the official Launcher and typing this in PowerShell:

(Get-WmiObject Win32_Process -Filter "name = 'javaw.exe'").CommandLine.Split(' ') | Select-Object -Last 8

#>
$Arguments = @($libraries;$JVM_Arguments;$natives;$jars;$settings) -join ' '

# Set-Clipboard "$Java_Executable $Arguments"


Start-Process "$Java_Executable" -WorkingDirectory $(Join-Path $LCDirectory offline/$ver) -ArgumentList "$Arguments" -Verbose -NoNewWindow

Start-Sleep 10
exit
<#
$offline = "$HOME\.lunarclient\offline"
$MCDir = "D:\Scoop\Minecraft\1.7-1.8"
$Ver = "1.7"
$Version = "1.7.10"

$Java_Executable = "D:\Scoop\Java Runtime Environments\graalvm-ce-java17-21.3.0\bin\javaw.exe"

$libraries = @(
'--add-modules jdk.naming.dns'
'--add-exports jdk.naming.dns/com.sun.jndi.dns=java.naming'
"-Djna.boot.library.path=$offline\$ver\natives"
'--add-opens java.base/java.io=ALL-UNNAMED'
) -join ' '

$JVM_Arguments = @(
'-Xms3G'
'-Xmx3G'
'-XX:+DisableAttachMechanism'
'-XX:+UnlockExperimentalVMOptions'
'-XX:+UseZGC'
'-XX:MaxGCPauseMillis=50'

# GraalVM specific
'-XX:+EnableJVMCI'
'-XX:+UseJVMCICompiler'
'-XX:+EagerJVMCI'
'-Djvmci.Compiler=graal'
) -join ' '

$natives = "-Djava.library.path=$offline\$ver\natives"

$jars = @(
"-cp $offline\1.7\lunar-assets-prod-1-optifine.jar"
"$offline\1.7\lunar-assets-prod-2-optifine.jar"
"$offline\1.7\lunar-assets-prod-3-optifine.jar"
"$offline\1.7\lunar-libs.jar"
"$offline\1.7\lunar-prod-optifine.jar"
"$offline\1.7\OptiFine.jar"
"$offline\1.7\vpatcher-prod.jar com.moonsworth.lunar.patcher.LunarMain"
) -join ';'

$settings = @(
"--version $ver"
'--accessToken 0'
"--assetIndex $version"
'--userProperties {}'
"--gameDir $MCDir"
'--width 854'
'--height 480'
'--texturesDir " "'
"--assetsDir $(Join-Path $MCDir assets)"
) -join ' '

Start-Process "$Java_Executable" -ArgumentList "$libraries $JVM_arguments $natives $jars $settings"
#"$Java_Executable $libraries $JVM_arguments $natives $jars $settings"
#>