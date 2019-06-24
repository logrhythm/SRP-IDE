Function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = “All files (*.*)| *.*”
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

# *** Entry Point to Script ***

#Get-FileName -initialDirectory "c:fso"


Function Get-DirectoryName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
 $OpenFileDialog.ShowNewFolderButton = $true
 $OpenFileDialog.RootFolder = $initialDirectory
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.SelectedPath
}

#Get-DirectoryName -initialDirectory ""
#Get-DirectoryName -initialDirectory MyDocuments



[System.Reflection.Assembly]::LoadWithPartialName(“System.windows.forms”) |
 Out-Null

$OpenFileDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$OpenFileDialog.Description = "Aaaa"
$OpenFileDialog.SelectedPath = 'C:\Users\tony.masse\Box Sync\Tony.Masse\Projets\20190312.SRP IDE\Current_Dev'
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.SelectedPath
