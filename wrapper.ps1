switch ($args[0]){ # Argument 1: Version
    
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
        # I recommend just making it one letter so it's faster to type 

}

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

    <#

    Feel free to add your own, here's a template (don't forget to add quotation marks at the start and end!), template:

    {$_ -in ('serv','server')}{$script:server = 'region.domain.tld'}

    #>

    default{$script:server = $_} # If you're using a plain IP it replugs

}

if (($args | Select-Object -Last 1) -eq '-Verbose'){
    $VerbosePreference = 'Continue'
    $script:Verbose = $true
    $null = $args | Select-Object -Last 1
}

if($args[2]){

    $file = "$env:USERPROFILE\.lunarclient\settings\game\accounts.json"

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

& "$PSScriptRoot\launcher.ps1" $ver $server