#First, download and unzip SteamCMD
New-Item -Path C:\steamcmd -ItemType directory
Invoke-WebRequest https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -OutFile C:\steamcmd\steamcmd.zip
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory("C:\steamcmd\steamcmd.zip", "C:\steamcmd")

#Now, launch SteamCMD and download The Forest Dedicated Server application
#For some reason it often seems to take multiple attempts to download the file from steamcmd
$loopingVariable = $true

while ($loopingVariable) {
    $steam = Start-Process -filePath "C:\steamcmd\steamcmd.exe" -ArgumentList "+login anonymous +app_update 556450 +quit" -PassThru
    
    # keep track of steam timeout event
    $timedOut = $false 

    # wait up to 90 seconds for normal termination
    $steam | Wait-Process -Timeout 150 -ErrorAction 0 -ErrorVariable timedOut

    if ($timedOut)
    {
        # terminate the processes
        Stop-Process -Name steamcmd -Force
        Start-Sleep -s 15
    } else { $loopingVariable = $false}

}

#Open up Windows Firewall for The Forest DS
New-NetFirewallRule -DisplayName "Allow The Forest DS" -Direction Inbound -Program C:\steamcmd\steamapps\common\TheForestDedicatedServer\TheForestDedicatedServer.exe -Action Allow

#Figure out IP address
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 -Type Unicast -InterfaceAlias eth*).IPAddress.tostring()

#Ask user for info, which means creating a winform form
Add-Type -AssemblyName System.Windows.Forms
$Form = New-Object system.Windows.Forms.Form
$Form.Text = "The Forest DS Server Config Info"
$form.TopMost =  $True
$Form.AutoSize = $true

$yValue = 20

$serverNameLabel = New-Object System.Windows.Forms.Label
$serverNameLabel.Text = "Server Name"
$serverNameLabel.Location = New-Object System.Drawing.Size(300,$yValue)
$serverNameLabel.AutoSize = $True
$Form.Controls.Add($serverNameLabel)
$serverNameTextBox = New-Object System.Windows.Forms.TextBox 
$serverNameTextBox.AcceptsTab = $True
$serverNameTextBox.Location = New-Object System.Drawing.Size(10,$yValue) 
$serverNameTextBox.Size = New-Object System.Drawing.Size(260,20) 
$Form.Controls.Add($serverNameTextBox)
$yValue += 30

$serverPasswordLabel = New-Object System.Windows.Forms.Label
$serverPasswordLabel.Text = "Server Password (leave empty if none)"
$serverPasswordLabel.Location = New-Object System.Drawing.Size(300,$yValue)
$serverPasswordLabel.AutoSize = $True
$Form.Controls.Add($serverPasswordLabel)
$serverPasswordTextBox = New-Object System.Windows.Forms.TextBox 
$serverPasswordTextBox.AcceptsTab = $True
$serverPasswordTextBox.Location = New-Object System.Drawing.Size(10,$yValue) 
$serverPasswordTextBox.Size = New-Object System.Drawing.Size(260,20) 
$Form.Controls.Add($serverPasswordTextBox)
$yValue += 30

$serverPasswordAdminLabel = New-Object System.Windows.Forms.Label
$serverPasswordAdminLabel.Text = "Server Admin Password (leave empty if none)"
$serverPasswordAdminLabel.Location = New-Object System.Drawing.Size(300,$yValue)
$serverPasswordAdminLabel.AutoSize = $True
$Form.Controls.Add($serverPasswordAdminLabel)
$serverPasswordAdminTextBox = New-Object System.Windows.Forms.TextBox 
$serverPasswordAdminTextBox.AcceptsTab = $True
$serverPasswordAdminTextBox.Location = New-Object System.Drawing.Size(10,$yValue) 
$serverPasswordAdminTextBox.Size = New-Object System.Drawing.Size(260,20) 
$Form.Controls.Add($serverPasswordAdminTextBox)
$yValue += 30

$serverTokenLabel = New-Object System.Windows.Forms.Label
$serverTokenLabel.Text = "Server Name Token (leave empty if anonymous)"
$serverTokenLabel.Location = New-Object System.Drawing.Size(300,$yValue)
$serverTokenLabel.AutoSize = $True
$Form.Controls.Add($serverTokenLabel)
$serverTokenTextBox = New-Object System.Windows.Forms.TextBox 
$serverTokenTextBox.AcceptsTab = $True
$serverTokenTextBox.Location = New-Object System.Drawing.Size(10,$yValue) 
$serverTokenTextBox.Size = New-Object System.Drawing.Size(260,20) 
$Form.Controls.Add($serverTokenTextBox)
$yValue += 30

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,$yValue)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$Form.Close() | out-null})
$Form.Controls.Add($OKButton)


$Form.ShowDialog()

$serverNameTextBox.text = '"' + $serverNameTextBox.text + '"'

#Write out to a file so that on subsequent server launches we can refer back to the file
$serverConfigInfo = @{ServerName=$serverNameTextBox.text.ToString(); ServerPassword=$serverPasswordTextBox.text.ToString(); ServerAdminPassword=$serverPasswordAdminTextBox.text.ToString(); ServerToken=$serverTokenTextBox.text.ToString()}
$serverConfigInfo.GetEnumerator() | Export-CSV -NoTypeInformation -Path C:\steamcmd\steamapps\common\TheForestDedicatedServer\serverConfigs.csv


#Download Autologon from the Sysinternals Suite
New-Item C:\SysInternalsSuite -ItemType directory
Invoke-WebRequest https://download.sysinternals.com/files/AutoLogon.zip -OutFile C:\SysInternalsSuite\AutoLogon.zip
[io.compression.zipfile]::ExtractToDirectory("C:\SysInternalsSuite\AutoLogon.zip", "C:\SysInternalsSuite")

#Gotta have an account autologon because the server for The Forest DS can't seem to run as a service
start-process C:\SysInternalsSuite\Autologon.exe

#Put a batch file to initialize the server into the startup folder
Copy-Item -Path C:\TheForestDSAdminScripts\TheForestDS_Installation\LaunchTheForestDSAfterInitialSetup.bat -Destination "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\LaunchTheForestDSAfterInitialSetup.bat"

#Start the server, and we're done!
$argList = "-serverip $ipAddress -nosteamclient -serversteamport 8766 -servergameport 27015 -serverqueryport 27016 -enableVAC -servername " + $serverConfigInfo.ServerName + " -serverplayers 8 -difficulty Normal -inittype Continue -slot 1 -serverpassword " + $serverConfigInfo.ServerPassword + " -serverpassword_admin " + $serverConfigInfo.ServerAdminPassword + " -serversteamaccount " + $serverConfigInfo.ServerToken
Start-Process C:\steamcmd\steamapps\common\TheForestDedicatedServer\TheForestDedicatedServer -ArgumentList $argList

#You can use this command to stop the process if you so desire
#Stop-Process -Name TheForestDedicatedServer
