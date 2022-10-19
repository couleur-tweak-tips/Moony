param( # First and only argument can also be a preset, see line 
	[Parameter(Position=0)][string]$ver, 
	[Parameter(Position=1)][string]$serv,
	[Parameter(Position=2)][string]$acc
)   [bool]$Verbose = ($VerbosePreference -eq 'Continue'); $mnver = 0.7

$DedicatedGigaBytesOfRam = 3
	# You likely won't need more, unless you're gonna play in big maps with a shit ton of mods (Default: 3)

$settings = @{

	Java_Executable = ""
		# Feel free to put a path to your JRE (jre-name-1.5.69/bin/javaw.exe) here
		# Remember to surround it by single/double quotes
	
		
	JVM_Arguments = @(
	"-Xms$($DedicatedGigaBytesOfRam*1024)m"
	"-Xmx$($DedicatedGigaBytesOfRam*1024)m"
	"-XX:+UseLargePages"
	"-Xlog:gc+init"
	"-XX:+DisableAttachMechanism"
	)-join' '


	WindowedHeight = 480
	WindowedWidth = 854
		# This will only affect Windowed resolution (Default: 480,854)

	LCDirectory = "$HOME/.lunarclient"
		# You most likely won't need to change this since Lunar Client does not allow you to change their install directory, still adding this for the smart LFL/PL fellas
    MinecraftDir = if (!$IsLinux){"$env:APPDATA/.minecraft"} else {"$HOME/.minecraft"}
    # I've made it equal to an if statement to make it cross platform but you can replace it with a string with quotes like for LCDirectory

    Use_Solar = $True
        # Use Solar Tweaks' java agent if available

	Use_Sodium = $True
		# For newer versions

	Cooldown = 10
		# The minimized window will stay open for specified length in seconds
		# I recommend leaving this as is until you're certain about the stability of Moony and your configuration
		# So that you can catch any errors that might be threwn
		# Set this to -1 for it to stay open indefinitely (e.g for logs with java.exe)

}

$agents = @(
# Hey! Add your agents in this multi-line string:
@"


"@)

$Aliases = @{
	# Feel free to add your own, here's a template (don't forget to add quotation marks at the start and end!):
	#'region.domain.tld' = @('serv','server')

	# FULL SERVER IP	# ALIASES
	'pvpgym.net'		= @('pg'	,'pvpgym')
	'eu.minemen.club'	= @('em'	,'eu','eummc','eu.minemen.club')
	'na.minemen.club'	= @('nm'	,'na','mmc','nammc','na.minemen.club')
	'as.minemen.club'	= @('as'	,'asmmc','as.minemen.club','am')
	'na.lunar.gg'		= @('nl'	,'lunar','nalunar','lunarna','lunar.gg')
	'west.lunar.gg'		= @('wl'	,'lunarw','lunarwest','westlunar','wlunar','west.lunar.gg')
	'eu.lunar.gg'		= @('el'	,'eulunar','lunareu','eu.lunar.gg')
	'akuma.gg'			= @('ak'	,'akuma','akuma.gg')
	'anteiku.us'		= @('an'	,'anteiku','anteiku.us','ant')
	'mpl.gg'			= @('mpl'	,'mpl.gg')
	'vipermc.com'		= @('viper'	,'viperhcf','vipermc')
	'pvplegacy.net'		= @('pl'	,'pvplegacy','pvplegacy.net')

	'hypixel.net'		= @('hy'	,'h','hypixel','hypixel.net')
	'play.manacube.com'	= @('mana'	,'manacube')
	
	'mush.com.br'		= @('mush'	,'mush.com')
	'pateta.online'		= @('pt'	,'pateta') # yw coquetel
	'pvpdojo.com'		= @('pd', 	,'pvpdojo')

	'play.rinaorc.com'	= @('rn'	,'rina','rinaorc')
	'play.craftok.fr'	= @('ct'	,'craftok')
	'mc.erisium.com'	= @('eri'	,'erisium','erisium.com','mc.erisium.com')
}

if (!$ver){
	return @"
Moony is ridiculously simple to use, you can just call it from the Run window (Windows+R) as "mn"

Here's a few examples:

> mn <version> <server> <account> -Verbose
	There's also a few utilities like 'edit' to open up the script to tune it and 'stop' to kill javaw

> mn 8 hy
	Launches Lunar Client in version 1.8.9, with whatever account you previously had selected

> mn 7 em sweatyPvPalt420
	Launches Minecraft in version 1.7.10, join eu.minemen.club, and switch to the sweatyPvPalt420 account
	Tip: you can also just type the first few letters of your name

> mn edit
	Opens the config file in VSCode, Notepad++ or Notepad, you can also just say e instead of edit ;)

> mn MyPreset
If you take a second to tune the script, you can set a custom version, server and account as a preset and call it from the Run window

Also if you are a CLI lover I made it so you can also call it from the command line (s/o minimoony <3)
"@
exit
}

Foreach($ServerAlias in $Aliases.Keys) { # Loops through the hashtable above
	if ($server){continue}
	if ($serv -in $Aliases.$ServerAlias){
		$server = $ServerAlias
	}
}
if (!$server){$server = $serv} # If no server was found, use it as the ip to connect to


switch ($ver){ # Argument 1: Version / Preset
	{$_ -eq 'f'}{$server = 'eu.minemen.club';$script:ver = 1.7;$acc = 'Couleur'}
	# Hey reader! If you want to make your own fast preset, you can add it here to set a server IP, version and account
	# I recommend just making it one letter so it's faster to type, you'll get blazing fast muscle memory in no time


	{$_ -eq 'stop'}{"Stopping Java";Get-Process javaw -Ea Ignore | Stop-Process -Ea Ignore;exit}
	# If often use this to kill Minecraft after debugging
	
	{$_ -in (7,1.7,1.7.10)}				{$script:ver = '1.7'; 	$script:version = '1.7.10'; $indexVer = '1.7.10';	$v_er = '1_7'}
	{$_ -in (8,1.8,1.8.9)}				{$script:ver = '1.8'; 	$script:version = '1.8.9'; 	$indexVer = '1.8';  	$v_er = '1_8'}
	{$_ -in (12,1.12,1.12.2)}			{$script:ver = '1.12';	$script:version = '1.12.2'; $indexVer = '1.12'; 	$v_er = '1_12'}
	{$_ -in (16,1.16,1.16.5)}			{$script:ver = '1.16';	$script:version = '1.16.5'; $indexVer = '1.16'; 	$v_er = '1_16'}
	{$_ -in (17,1.17,1.17.1)}			{$script:ver = '1.17';	$script:version = '1.17.1'; $indexVer = '1.17'; 	$v_er = '1_17'}
	{$_ -in (18,1.18)}					{$script:ver = '1.18';	$script:version = '1.18'; 	$indexVer = '1.18'; 	$v_er = '1_18'}
	{$_ -in ('18.2','1.18.2')}			{$script:ver = '1.18';	$script:version = '1.18.2'; $indexVer = '1.18'; 	$v_er = '1_18'}
	{$_ -in ('latest',19,'1.19')}		{$script:ver = '1.19';	$script:version = '1.19.2'; $indexVer = '1_19'; 	$v_er = '1_19'}
		# If you're struggling with 1.18 and Lunar updated to 1.18.x that might be why it's not launching

	{$_ -in ('pika','pk')}{$server = 'play.pika-network.net';$script:ver = 1.8}
	{$_ -in ('em')}{$server = 'eu.minemen.club';$script:ver = 1.7}
	{$_ -in ('pg')}{$server = 'pvpgym.net';$script:ver = 1.7}
	{$_ -in ('nl')}{$server = 'na.lunar.gg';$script:ver = 1.7}
	{$_ -in ('hy')}{$server = 'hypixel.net';$script:ver = 1.8}
	{$_ -in 'e','edit','conf','config','settings'}{

		# IF YOU ARE EXPERIENCING ISSUES WITH EDITING MOONY, COMMENT THE LINE BELOW
		if (!$isLinux -or !$isMacOS){
			& rundll32.exe shell32.dll,OpenAs_RunDLL $MyInvocation.MyCommand.Path
		}else{
			if (!$EDITOR){
				Write-Host "EDITOR environment variable not set, open it yourself:`n$($MyInvocation.MyCommand.Path)"
			}else{
				& $($EDITOR) $($MyInvocation.MyCommand.Path)
			}
		}
		# AND UNCOMMENT THIS BLOCK OF 6 LINES BELOW
		# $Assoc = (Get-ItemProperty REGISTRY::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\Open\Command).'(default)'
        # if ($Assoc -notlike "*powershell.exe*"){
		# 	Invoke-Item $MyInvocation.MyCommand.Path
		# }else{
		# 	notepad.exe $MyInvocation.MyCommand.Path
		# }
		exit
	}
	default {
		return @"
Could not determine what version to expand to with: [$ver]
"@
exit
	}
}

if($acc){

	$file = Convert-Path "$($settings.LCDirectory)\settings\game\accounts.json" -ErrorAction Stop

	$json = Get-Content -Path $file | ConvertFrom-Json

	ForEach($account in ($json.accounts | Get-Member -MemberType Properties).Name){

		if ($json.accounts.$($account).MinecraftProfile.name -like "$acc*"){
			
			$switchedAcc = ($json.accounts.$($account).MinecraftProfile.name)
			$json.activeAccountLocalId = $account

			Set-Content $file -Value $($json | ConvertTo-Json -Depth 10) -Force -ErrorAction SilentlyContinue

			$script:Succeed = $true
		}
	}
	if (!$Succeed){
		Write-Warning "Could not find a matching account that is connected with the IGN $acc"
		''
		Write-Host "Lunar Client will launch (and may join a server if you specified it) with the account: $($json.accounts.($json.activeAccountLocalId).minecraftProfile.name)"
		pause
	}
}
$Host.UI.RawUI.WindowTitle = "Moony [$mnver]"
Write-Host "Launching Lunar Client version $ver$(if ($server){", joining server $server"})$(if ($switchedAcc){" and switching to account $switchedAcc"})`n" -ForegroundColor Green

if (!$settings.Java_Executable){
    if ($isLinux -or $isMacOS){
    $Pattern = "zulu16*-ca-fx-jdk16*-linux_x64"
	$filename = "java"
    }else{
    $Pattern = "zulu17*-ca-jre17*-win_x64"
	$filename = "javaw.exe"
    }
    # 40 ?'s because that's the length of their new checksum like folders
	$Zulu = Convert-Path "$($settings.LCDirectory)/jre/$("?" * 40)/$Pattern/bin/$filename" -Ea Ignore
	$BestJRE = $Zulu | Where-Object {$PSItem -Like "*$ver*"}

	if ($BestJRE){$JRE = $BestJRE}
	elseif($Zulu){$JRE = $Zulu}
	else{
		return @"
Could not find a JRE to use to launch Lunar, please launch Lunar in the version you want to launch atleast once
Reminder: Moony NEEDS Lunar's files to launch, Moony is simply a script that launches LC using their files.
"@
	exit
	}
}elseif(-Not(Test-Path $settings.Java_Executable)){
	return @"
The JRE path you provided [$($settings.Java_Executable)] does not exist, please edit moony (with `mn edit` in cmd) to fix this
"@
	exit
}else{
	if (!$JRE){
		$JRE = $settings.Java_Executable
	}
}


$libraries = @(
'--add-modules jdk.naming.dns'
'--add-exports jdk.naming.dns/com.sun.jndi.dns=java.naming'
'-Djna.boot.library.path=natives'
'-Dlog4j2.formatMsgNoLookups=true' # Fixes that java exploit
'--add-opens java.base/java.io=ALL-UNNAMED'
) -join ' '



if ($settings.Use_Solar){
    $patcher = "$($settings.LCDirectory)\solartweaks\solar-patcher.jar"
    $conf = "$($settings.LCDirectory)\solartweaks\config.json"
    if (Test-Path $patcher, $conf){
        $agents += @(
            "$patcher=$conf"
        )
    }
}

$jars = @(
    'genesis-0.1.0-SNAPSHOT-all.jar'
    'common-0.1.0-SNAPSHOT-all.jar'
    'lunar-lang.jar'
    'lunar-emote.jar'
    'lunar.jar'
    "v$v_er-0.1.0-SNAPSHOT-all.jar"
)

if(-Not($settings.WindowedHeight)){$settings.WindowedHeight = 480}
if(-Not($settings.WindowedWidth)){$settings.WindowedWidth = 854}

$config = @(
#"--assetDir $(Join-Path $settings.MinecraftDir assets)"
"--version $version"
'--accessToken 0'
"--assetIndex $indexVer"
'--userProperties {}'
"--gameDir $($settings.MinecraftDir)"
"--texturesDir $(Join-Path $settings.LCDirectory textures)"
"--width $($settings.WindowedWidth)"
"--height $($settings.WindowedHeight)"
'--workingDirectory .'
'--classpathDir .'
)

if ($settings.Use_Sodium -and ([version]$ver -gt [version]1.12)){ # Bless version type
    Write-Host "Using Sodium" -ForegroundColor DarkRed
    $jars += @(
        "fabric-0.1.0-SNAPSHOT-all.jar"
        "fabric-0.1.0-SNAPSHOT-v$v_er.jar"
        "argon-0.1.0-SNAPSHOT-all.jar"
        "sodium-0.1.0-SNAPSHOT-all.jar"
    )
	$config += @(
        "--ichorClassPath"
        $jars -join ","
		'--ichorExternalFiles'
		"Phosphor_v$v_er.jar"
		"Sodium_v$v_er.jar"
		"Indium_v$v_er.jar"
		"Iris_v$v_er.jar"
	)
}else{
    Write-Host "Using OptiFine" -ForegroundColor Magenta
    $jars += 'optifine-0.1.0-SNAPSHOT-all.jar'
	$config += @(
        "--ichorClassPath"
        $jars -join ","
		'--ichorExternalFiles',
		"OptiFine_v$v_er.jar"
	)

}

if ($server){
    $config += "-server $server" 
}

<# If you wish to add --hwid and --launcherversion:

You can parse them by launching Lunar Client with the official Launcher and typing this in PowerShell:

(Get-WmiObject Win32_Process -Filter "name = 'javaw.exe'").CommandLine.Split(' ')

#>

$Seperator = if($IsLinux -or $IsMacOS){':'}else{';'}

$Parameters = @{

    FilePath = $JRE
    WorkingDirectory = Join-Path $settings.LCDirectory offline/multiver
        # Makes it so we don't have to specify a path for each file in $jars

    ArgumentList = @(
        $libraries
        $settings.JVM_Arguments -split "`n" -join " "
        "-Djava.library.path=natives"
        "-cp", $($jars -join $Seperator)
        "com.moonsworth.lunar.genesis.Genesis"
        $config
    ) -join ' '
    NoNewWindow = $true
}

if ($settings.Cooldown -eq -1){
	$Paramters += {Wait = $True}
}
if ($agents){
	$Parameters.ArgumentList += (' ' + $agents -join ' ')
}

if ($Verbose){
    $JRE
    Write-Host $Parameters.ArgumentList -ForegroundColor DarkGray
    ($Parameters.ArgumentList -split " ")
    Write-Verbose "JRE"
    $Parameters.FilePath

    Write-Verbose "Working Directory"
    $Parameters.WorkingDirectory

    Write-Verbose "Libraries"
    $libraries -Split ' '

    Write-Verbose "JVM Arguments"
    $settings.JVM_Arguments -Split ' '

    Write-Verbose "Agents (split by $Seperator)"
    $jars -Split $Seperator

    Write-Verbose "Config"
    $config
}

Start-Process @Parameters

if ($settings.Cooldown -ne -1){
	Start-Sleep $settings.Cooldown
	exit
}else{
	pause
}
