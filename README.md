# TheForestDS_Installation
* Launch an AWS instance as follows:
	* Microsoft Windows Server 2016 Base
	* I went with T2.Medium; not sure it needs to be that big
	* I went with 100GB of GP SSD storage; again, up to you
	* Security group:
		* Allow TCP & UDP 27015 from anywhere
		* Allow TCP & UDP 8766 from anywhere
		* Allow RDP from only your IP
* RDP into your new instance when it's ready
*  While you are waiting for it to be ready, go make a steamServerAccount token and put it somewhere handy: https://steamcommunity.com/dev/managegameservers
* Once you get in, you might want to change the Administrator password or create a different account.  How you manage your server is up to you.  Whatever you decide to do, though, know that your server will be running with that account signed in at all times once the process is complete.
* Open up Powershell, paste the following commands, and hit enter:
  ```powershell
	register-packagesource -Name chocolatey -Provider Powershellget -Trusted -Location http://chocolatey.org/api/v2/ -Verbose
	Install-Package git -ProviderName chocolatey
	start-process (Get-ChildItem C:\Chocolatey\bin -Include "*64-bit*" -Recurse)
  ```
* Be patient-- it may take a few minutes; say yes to all the prompts
* Install git; I didn't change any of the defaults except for selecting "Use Windows' Default Console Window"
* When Git is done installing, in the same powershell window, paste and hit enter:
  ```powershell
	New-Alias -Name git -Value "$Env:ProgramFiles\Git\bin\git.exe"
	New-Item -Path C:\TheForestDSAdminScripts -ItemType directory
	cd C:\TheForestDSAdminScripts
	Git clone https://github.com/leahlouisa/TheForestDS_Installation.git #this throws an error but works anyway
	C:\TheForestDSAdminScripts\TheForestDS_Installation\InitialSetupForTheForestDS.ps1
    ```
* Again, be patient
* Enter your server preferences when prompted (servername, password, etc)
* Enter the Windows credentials for the currently logged in user when prompted inside of Autologon
	* If you are worried about doing this, feel free to research Windows Sysinternals Autologon, and read over my code to see what it is doing with your creds.  The reason the script needs them is that, try as I might, I could not get the TFDS server to function as a background process-- it has to run in the context of an interactive session.  So the server needs to be logged into at all times in order for it to function, and Autologon makes that painless.
* The TFDS instance will launch at the bottom of the script.  In order to keep it running, DO NOT log out of your RDP session.  Disconnect instead.  From henceforth, after a reboot, the TFDS process will automatically restart.

## Notes:
* There is a script called UpdateTFDSToLatestVersion.ps1 included in the package.  Run it whenever the devs release a new version TFDS to update your server to the latest version.
* Thanks to https://roadtoalm.com/2015/08/27/using-oneget-packagemanager-in-windows-10-and-windows-2016-server-container/ and https://www.develves.net/blogs/asd/articles/using-git-with-powershell-on-windows-10/ for part of these instructions
