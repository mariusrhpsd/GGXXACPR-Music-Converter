# Stuff
$ErrorActionPreference= 'silentlycontinue'
$computername=$env:computername
New-Item ".\output" -itemType Directory  | Out-Null
New-Item ".\bin\input_wav" -itemType Directory  | Out-Null
Add-Type -AssemblyName System.Windows.Forms | Out-Null
$TextInfo = (Get-Culture).TextInfo
# Arranges of characters and their respective track number
$characters = [System.Collections.Generic.List[System.Object]](Get-Content -Path .\bin\characters.txt )
$charas = $characters.tolower()
$track = @(Get-Content -Path .\bin\tracks.txt)
#$charas = @('anji','axl','baiken','select','chipp','dizzy','faust','ino','jam','johnny','ky','may','millia','potemkin','slayer','sol','testament','venom','bridget','zappa','eddie','robo-ky','kliff','justice','aba','order sol','boss','same1','same2','existence','noontide','no mercy','still in the dark','keep the flag flying','construction site','construction site night','continue','game over','grief','main menu','staff1','staff2','staff3','versus')
#$characters = [System.Collections.Generic.List[System.Object]]('Anji','Axl','Baiken','Select','Chipp','Dizzy','Faust','Ino','Jam','Johnny','Ky','May','Millia','Potemkin','Slayer','Sol','Testament','Venom','Bridget','Zappa','Eddie','Robo-Ky','Kliff','Justice','Aba','Order Sol','Boss','Same1','Same2','Existence','Noontide','No Mercy','Still in the Dark','Keep The Flag Flying','Construction Site','Construction Site Night','Continue','Game Over','Grief','Main Menu','Staff1','Staff2','Staff3','Versus') | Sort-Object
#$track = @('00','02','03','05','06','08','09',11,12,13,14,16,17,19,20,21,23,24,26,27,28,32,33,34,42,43,15,'04',36,'01',22,35,37,44,40,41,'07',10,38,39,29,30,31,25)
$tracks = @()
$inputmp3 = @()
$mp3input =
$song =

# Checks for files in the output folder

$testpath = Test-Path .\output\*
if ($testpath -eq "True"){
    $deletefiles = Get-ChildItem -Path .\output -File -Recurse
    $deletefiles.Name
    $confirm = Read-Host "There are files in the output folder, do you want to delete them? (Y/N)"
    $confirm = $confirm.ToLower()
    if ($confirm -eq "Y"){
        Get-ChildItem -Path .\output -File -Recurse | ForEach-Object {$_.Delete()}
    Read-Host "Files in the output folder were deleted. Press enter to continue."
    }
}
# Input Box for folders
Write-Host "A folder popup should appear now, please select the folder containing the mp3's you want to convert."
$FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{ Description = "Select the folder with the source mp3's"}
$result = $FolderBrowser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
if ($result -eq [Windows.Forms.DialogResult]::OK){
    $FolderBrowser.SelectedPath
}
else {
    exit
}
$mp3input =  Get-ChildItem -Path $FolderBrowser.SelectedPath*.mp3
Write-Host "The following files will be processed`n"
$mp3input.Name
Read-Host "`nPress enter to continue"
Clear-Host
# Assigns a track ID for each MP3
foreach ($mp3 in $mp3input){
    Clear-Host
    Write-Host "PLEASE SELECT YOUR CHARACTER FOR`n"$mp3":"
    $characters |Select-Object @{Name='String';Expression={$_}}|Format-Wide String -Column 3
    $song = Read-Host "`nSkip = next file `nConvert = go to convert`nEQuit = Quit the program"
    $song = $song.ToLower()
    if ($song -eq 'skip'){continue}
    if ($song -eq 'exit'){break}
    if ($song -eq 'quit'){exit}
    while ($charas -notcontains $song){
        $song = Read-Host "Please select an item from the list"
        $song = $song.ToLower()
        if ($song -eq 'skip'){continue}
        if ($song -eq 'convert'){break}
        if ($song -eq 'quit'){exit}
    }
    $index = $charas.indexof($song)
    $tracks += "$index"
    $inputmp3 += $mp3
    Read-Host "Track"$mp3 '='$characters[$index]"`nPress enter to continue..."
    $characters.RemoveAt($index)
}
Clear-Host
foreach ($show in $inputmp3){
$showindex = $inputmp3.indexof($show)
$showtrack =  $charas[$tracks[$showindex]]
Write-Host "Original file:"$show.Name"for"$TextInfo.ToTitleCase($showtrack)}

Read-Host "`nThe following files will be converted, press Enter to start"

# Converts MP3 to XWMA with proper track number
foreach ($mp3 in $inputmp3){
    $trackindex = $inputmp3.indexof($mp3)
    $trackname = $track[$tracks[$trackindex]]
    .\bin\lame.exe --decode $mp3.FullName bin\input_wav\$trackname.wav
    .\bin\xWMAEncode.exe .\bin\input_wav\$trackname.wav .\output\$trackname.xwma}
# Cleans files

Get-ChildItem -Path .\bin\input_wav -File -Recurse | ForEach-Object {$_.Delete()}

# Shows output folder

Read-Host "Conversion complete, press enter to end process and show output folder and the acpr folder (might fail)"

#Define the variable to hold the location of Currently Installed Programs
    $UninstallKey='SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' 
#Create an instance of the Registry Object and open the HKLM base key
    $reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computername) 
#Drill down into the Uninstall key using the OpenSubKey Method
    $regkey=$reg.OpenSubKey($UninstallKey) 
#Retrieve an array of string that contain all the subkey names
    $subkeys=$regkey.GetSubKeyNames()

#Open each Subkey and use the GetValue Method to return GGACPR install folder
foreach ($key in $subkeys){
    $thiskey=$UninstallKey+"\"+$key
    $thissubkey=$reg.OpenSubKey($thiskey)
    $DisplayName=$thissubkey.GetValue("DisplayName")
    $InstallLocation=$thissubkey.GetValue("InstallLocation")

    if ($DisplayName -eq "GUILTY GEAR XX ACCENT CORE PLUS R"){
        $ACPRFolder=$InstallLocation+"\Resource\BGM"
    }
    continue
}
Invoke-Item $ACPRFolder
Invoke-Item .\output