if ((Test-Path C:\steamcmd\steamapps\common\TheForestDedicatedServer\config\serverConfigs.csv) -and (Test-Path C:\steamcmd\steamapps\common\TheForestDedicatedServer\TheForestDedicatedServer.exe))
{
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 -Type Unicast -InterfaceAlias eth*).IPAddress.tostring()
    $customServerConfigs = Import-CSV -Path C:\steamcmd\steamapps\common\TheForestDedicatedServer\config\serverConfigs.csv
    $serverName = ($customServerConfigs | where { $_.Name -eq "ServerName" }).Value
    $serverPassword = ($customServerConfigs | where { $_.Name -eq "ServerPassword" }).Value
    $serverAdminPassword = ($customServerConfigs | where { $_.Name -eq "ServerAdminPassword" }).Value
    $serverToken = ($customServerConfigs | where { $_.Name -eq "ServerToken" }).Value
    $argList = "-serverip $ipAddress -nosteamclient -serversteamport 8766 -servergameport 27015 -serverqueryport 27016 -enableVAC -servername $serverName -serverplayers 8 -difficulty Normal -inittype Continue -slot 1 -serverpassword $serverPassword -serverpassword_admin $serverAdminPassword -serversteamaccount $serverToken"
    Start-Process C:\steamcmd\steamapps\common\TheForestDedicatedServer\TheForestDedicatedServer -ArgumentList $argList
}

else { "Looks like the custom config file is missing :/" }
