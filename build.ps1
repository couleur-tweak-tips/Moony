cd $PSScriptRoot

$Moony = Get-Item .\Moony.ps1

$Version = Get-Content $Moony | Where-Object {$_ -Like "*Host.UI.RawUI.WindowTitle*"}
$Version = $Version.Trim('$Host.UI.RawUI.WindowTitle = "Moony [')
$Version = $Version.Trim(']')
Compress-Archive -Path $Moony -DestinationPath ".\releases\Moony-$Version.zip"