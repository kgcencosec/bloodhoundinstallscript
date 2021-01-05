<#
This is a script to download and install all the necessary components to run Bloodhound and Sharphound. 
It will also install Firefox, if you don't want or need that, comment it out or remove it.
WARNING: Both Bloodhound.exe and Sharpound.exe will be detected and blocked by most AVs so prep accordingly.

By Kyle Gustafson
#>

#Set Up a directory for Bloodhound
cd "C:\"

mkdir Bloodhound -ErrorAction SilentlyContinue

cd "C:\Bloodhound"

#Variables

$bloodHoundDir = "C:\Bloodhound"

$SourceURL = "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US" 
$firefoxInstaller = $bloodHoundDir + "\firefox.msi" 

$openJDKUrl = "https://download.java.net/openjdk/jdk11/ri/openjdk-11+28_windows-x64_bin.zip"

$neo4JUrl = "https://neo4j.com/artifact.php?name=neo4j-community-4.2.1-windows.zip"

$bloodHoundUrl = "https://github.com/BloodHoundAD/BloodHound/releases/download/4.0.1/BloodHound-win32-x64.zip"

$neo4jBin = "C:\Bloodhound\neo4j\neo4j-community-4.2.1\bin"

$sharpHoundUrl = "https://github.com/BloodHoundAD/BloodHound/raw/master/Collectors/SharpHound.exe"

# Unattended Install of Firefox


wget $SourceURL -OutFile $firefoxInstaller -ErrorAction SilentlyContinue
Start-Process -FilePath $firefoxInstaller -Args "/q" -ErrorAction SilentlyContinue

Start-Sleep 30

Remove-Item $firefoxInstaller

#Install OpenJDK 11
cd $bloodHoundDir

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

wget $openJDKURL -OutFile openjdk.zip -ErrorAction SilentlyContinue
Expand-Archive .\openjdk.zip -DestinationPath "C:\Program Files\Java" -ErrorAction SilentlyContinue

setx -m JAVA_HOME "C:\Program Files\Java\jdk-11"
setx -m PATH "%PATH%;%JAVA_HOME%\bin";

#Install Neo4j
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

wget $neo4JUrl -OutFile neo4j.zip -erroraction 'silentlycontinue'

Expand-Archive .\neo4j.zip -DestinationPath "C:\Bloodhound\neo4j"

[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-11")

cd $neo4jbin

cmd.exe /c ".\neo4j.bat install-service"

cmd.exe /c "net start neo4j"

#Install Bloodhound

cd $bloodHoundDir

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget $bloodHoundUrl -OutFile BloodHound.zip -ErrorAction SilentlyContinue

Expand-Archive .\Bloodhound.zip -ErrorAction SilentlyContinue

function set-shortcut {

param ( [string]$SourceLnk, [string]$DestinationPath )

    $WshShell = New-Object -comObject WScript.Shell

    $Shortcut = $WshShell.CreateShortcut($SourceLnk)

    $Shortcut.TargetPath = $DestinationPath

    $Shortcut.Save()

    }

set-shortcut "C:\Users\Public\Desktop\BloodHound.lnk" "C:\Bloodhound\Bloodhound\BloodHound-win32-x64\BloodHound.exe" -ErrorAction SilentlyContinue


#Install Sharphound

cd $bloodHoundDir

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
wget $sharpHoundUrl -OutFile SharpHound.exe -ErrorAction SilentlyContinue
set-shortcut "C:\Users\Public\Desktop\SharpHound.lnk" "C:\Bloodhound\sharphound.exe" -ErrorAction SilentlyContinue

Write-Host "Open a web browser and navigate to http://localhost:7474/. You should see the neo4j web console.
Authenticate to neo4j in the web console with username neo4j, password neo4j. You’ll be prompted to change this password. 

To run SharpHound with Defaults, double click on the link. To run it with arguments, open a command prompt and cd to the C:\Bloodhound directory."