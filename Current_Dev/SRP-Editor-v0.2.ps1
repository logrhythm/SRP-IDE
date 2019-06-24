# ###########################################
#
# LogRhythm SmartResponse Plug-In Editor
#
# ###############
#
# (c) 2019, LogRhythm
#
# ###############
#
# Change Log:
#
# v0.1 - 2019-04-28 - Tony Massé (tony.masse@logrhythm.com)
# - Skeleton
# - Load UI from external YAML
#
# v0.2 - 2019-05-13 - Tony Massé (tony.masse@logrhythm.com)
# - Commenting some old code, to remove error messages
# - Loading local copy of the Cloud Template List into the UI
# - First Config file
# - First PlugInCloudTemplateList file
# - Download from Cloud, parse, update and save locally the PlugInCloudTemplateList
#
# ################
#
# TO DO
# - Everything...
#
# ################



########################################################################################################################
##################################### Variables, Constants and Function declaration ####################################
########################################################################################################################


# Version
$VersionNumber = "0.2"
$VersionDate   = "2019-05-13"
$VersionAuthor = "Tony Massé (tony.masse@logrhythm.com)"
$Version       = "v$VersionNumber - $VersionDate - $VersionAuthor"

# Time formats
$TimeStampFormatForJSON = "yyyy-MM-ddTHH:mm:ss.fffZ"
$TimeStampFormatForLogs = "yyyy.MM.dd HH:mm:ss"

# Project image object
# The types we need for it
class SRPActionParameter
{
    [ValidateNotNullOrEmpty()][string]$Type
    [ValidateNotNullOrEmpty()][string]$Name
    [ValidateNotNullOrEmpty()][string]$MapToField
    [ValidateNotNullOrEmpty()][string]$Switch
    [ValidateNotNullOrEmpty()][string]$ValidationRule
}

class SRPAction
{
    [ValidateNotNullOrEmpty()][string]$Name
    [ValidateNotNullOrEmpty()][string]$Command
    [ValidateNotNullOrEmpty()][SRPActionParameter[]]$Parameters
}

class SRPTestParameter
{
    [ValidateNotNullOrEmpty()][string]$Name
    [ValidateNotNullOrEmpty()][string]$Value
}

class SRPTest
{
    [ValidateNotNullOrEmpty()][bool]$Enable
    [ValidateNotNullOrEmpty()][string]$Action
    [ValidateNotNullOrEmpty()][SRPActionParameter[]]$Parameters
}

# The memory object itself
$ProjectMemoryObject = @{"File" = 
                           @{"Type" = "SmartResponse PlugIn Project"
                           ; "TypeVersion" = $VersionNumber
                           }
                       ; "Generated" = 
                           @{"By" = "LogRhythm SmartResponse Plug-In Editor - " + $Version 
                           ; "Automatically" = $true
                           ; "At" = (Get-Date).tostring($TimeStampFormatForJSON)
                           }
                       ; "PlugIn" =
                           @{"Name" = ""
                           ; "ProjectFolder" = ""
                           ; "FileName" = ""
                           ; "Author" = ""
                           ; "Version" =
                               @{"Major" = ""
                               ; "Minor" = ""
                               ; "Build" = ""
                               ; "BuildAutoIncrment" = $true
                               }
                           }
                       ; "Actions" = @()
                       ; "Output" =
                           @{"Folder" = ""
                           ; "OneFolderPerVersion" = $true
                           }
                       ; "Preferences" =
                           @{"LicenseFile" = "LogRhythm Code Sample"
                           ; "GenerateSignleScriptFile" = $false
                           ; "GenerateLPIAtBuildTime" = $false
                           }
                       ; "Language" =
                           @{"ScriptingLanguage" = "PowerShell"
                           }
                       ; "ModulesExtensions" = 
                           @{"APIWrappers" = @()
                           ; "Simplifiers" = @()
                           }
                       ; "Signature" =
                           @{"BuiltInProcess" = $true
                           ; "AutoSignEveryBuild" = $false
                           ; "UseCertificateStore" = $true
                           ; "CertificatePath" = "Cert:\CurrentUser\My"
                           ; "CustomSigningScriptPath" = ""
                           }
                       ; "Build" =
                           @{"CreateOneFunctionPerAction" = $true
                           ; "ParameterValidation" = "Hard Validation"
                           ; "PreBuildExternalScriptPath" = ""
                           ; "PostBuildExternalScriptPath" = ""
                           }
                       ; "Tests" = @()
                       }


# Directories and files information
# Base directory
$basePath = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path
cd $basePath

# Last Browse directory
$LastBrowsePath = $basePath

# Config directory and file
$configPath = Join-Path -Path $basePath -ChildPath "config"
if (-Not (Test-Path $configPath))
{
	New-Item -ItemType directory -Path $configPath | out-null
}

$configFile = Join-Path -Path $configPath -ChildPath "config.json"

# Log directory and file
$logsPath = Join-Path -Path $basePath -ChildPath "logs"
if (-Not (Test-Path $logsPath))
{
	New-Item -ItemType directory -Path $logsPath | out-null
}

$logFile = Join-Path -Path $logsPath -ChildPath ("LogRhythm.SRP-Editor." + (Get-Date).tostring("yyyyMMdd") + ".log")
if (-Not (Test-Path $logFile))
{
	New-Item $logFile -type file | out-null
}

# Logging functions
function LogMessage([string] $logLevel, [string] $message)
{
    $Msg  = ([string]::Format("{0}|{1}|{2}", (Get-Date).tostring("$TimeStampFormatForLogs"), $logLevel, $message))
	$Msg | Out-File -FilePath $logFile  -Append        
    Write-Host $Msg
}

function LogInfo([string] $message)
{
	LogMessage "INFO" $message
}

function LogError([string] $message)
{
	LogMessage "ERROR" $message
}

function LogDebug([string] $message)
{
	LogMessage "DEBUG" $message
}

# Cache directory
$cachePath = Join-Path -Path $configPath -ChildPath "Local Cache"
if (-Not (Test-Path $cachePath))
{
	New-Item -ItemType directory -Path $cachePath | out-null
}

# Local copy of the Plug-In Cloud Template List JSON
$PlugInCloudTemplateListJSONLocalFile = Join-Path -Path $cachePath -ChildPath "PlugInCloudTemplateListLocal.json"

# Local copy of the LogRhythm Fields List JSON
$LogRhythmFieldsListJSONLocalFile = Join-Path -Path $cachePath -ChildPath "LogRhythmFieldsListLocal.json"


# ########
# Functions used to decompress/decode compressed/encoded UI XAML:
# - Get-DecompressedByteArray
# - Get-Base64DecodedDecompressedXML

# Function to decompress the XAML. 
function Get-DecompressedByteArray {
	[CmdletBinding()]
    Param (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [byte[]] $byteArray = $(Throw("-byteArray is required"))
    )
	Process {
	    Write-Verbose "Get-DecompressedByteArray"
        $input = New-Object System.IO.MemoryStream( , $byteArray )
	    $output = New-Object System.IO.MemoryStream
        $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)
	    $gzipStream.CopyTo( $output )
        $gzipStream.Close()
		$input.Close()
		[byte[]] $byteOutArray = $output.ToArray()
        Write-Output $byteOutArray
    }
}

# Function to Decode the decompressed XAML. Used to decompress/decode compressed/encoded UI XAML
function Get-Base64DecodedDecompressedXML {
	[CmdletBinding()]
    Param (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $Base64EncodedCompressedXML = $(Throw("-Base64EncodedCompressedXML is required"))
    )
    Begin {
        [System.Text.Encoding] $enc = [System.Text.Encoding]::UTF8
    }

	Process {
        [byte[]]$DecodedBytes = [System.Convert]::FromBase64String($Base64EncodedCompressedXML)
        [string]$DecodedText = $enc.GetString( $DecodedBytes )
        $decompressedByteArray = Get-DecompressedByteArray -byteArray $DecodedBytes
        Write-Output $enc.GetString( $decompressedByteArray )
    }
}

# Starting SmartResponse Plug-In Editor
LogInfo "Starting SmartResponse Plug-In Editor"
LogInfo ("Version: " + $Version)

# Reading config file
if (-Not (Test-Path $configFile))
{
	LogError "File 'config.json' doesn't exists."
    $SRPEditorForm.ShowDialog() | out-null
	#LogError "File 'config.json' doesn't exists. Exiting"
	return
}
else
{
    LogInfo "File 'config.json' exists."
}

try
{
	$configJson = Get-Content -Raw -Path $configFile | ConvertFrom-Json
	ForEach ($attribute in @("DocType", "PlugInCloudTemplateURL")) {
		if (-Not (Get-Member -inputobject $configJson -name $attribute -Membertype Properties) -Or [string]::IsNullOrEmpty($configJson.$attribute))
		{
			LogError ($attribute + " has not been specified in 'config.json' file.")
		}
	}
    LogInfo "File 'config.json' parsed correctly."
}
catch
{
	LogError "Could not parse 'config.json' file. Exiting"
	return
}

# #################
# Reading XAML file
$XAMLFile = "SRP_IDE\SRP_IDE\MainWindow.xaml"

if (Test-Path $XAMLFile)
{
    LogInfo ("File '{0}' exists." -f $XAMLFile)

    try
    {
        LogInfo ("Loading '{0}'..." -f $XAMLFile)
	    [string]$stXAML = Get-Content -Raw -Path $XAMLFile
        LogInfo "Loaded."
    }
    catch
    {
	    LogError ("Could not load '{0}' file. Exiting" -f $XAMLFile)
	    return
    }

}
else 
{
	LogInfo ("External UI definition file '{0}' doesn't exists. Loading from internal description instead." -f $XAMLFile)

# ##########
# "$ConfigEditorv1_6" extracted on 2019-04-04 15:29:43 from ".\MainWindow - Copy - 20190404 - v1.6 Minimal.xaml".
# Sanitised                          : False
# Raw XAML Size                      : 65677 bytes
# Compressed XAML Size               : 8677 bytes (saving: 57000 bytes)
# Base64 Encoded Compressed XAML Size: 11572 bytes (saving: 54105 bytes)

$ConfigEditorv1_6 = ""

$stXAML = Get-Base64DecodedDecompressedXML -Base64EncodedCompressedXML $ConfigEditorv1_6

}

##########
# Sanitise the XAML produced by Visual Studio
$stXAML = $stXAML -replace 'x:Class=".*.MainWindow"'," "
$stXAML = $stXAML -replace 'mc:Ignorable="d"',""
#$stXAML = $stXAML -replace 'x:Name="([^"]*)"','x:Name="$1" Name="$1"'  # Turns out, this cause a lot of troubles :D Getting rid of it :)
$stXAML = $stXAML -replace 'x:Name="([^"]*)"','Name="$1"'
$stXAML = $stXAML -replace '%VERSIONNUMBER%',$VersionNumber
$stXAML = $stXAML -replace '%VERSIONDATE%',$VersionDate
$stXAML = $stXAML -replace '%VERSIONAUTHOR%',$VersionAuthor
         
#########
# Pass the String into an XML
try
{
    LogInfo ("Formatting UI..." -f $XAMLFile)
    [xml]$XAML = $stXAML
    #$stXAML | Out-File -FilePath "C:\Users\tony.masse\Box Sync\Tony.Masse\Projets\20190219.Azure - Network Watcher's NSG flow log\stXAML.xaml"
    LogInfo "Formatted."
}
catch
{
	LogError ("Failed to format and load the UI design into XML ""{0}"". Exiting" -f $stXAML)
	return
}

###########
# Read XAML
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
$reader=(New-Object System.Xml.XmlNodeReader $XAML) 
try{$SRPEditorForm=[Windows.Markup.XamlReader]::Load( $reader )}
catch{LogError "Unable to load Windows.Markup.XamlReader for ConfigReader.MainWindow. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}


##################################
# Store Form Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $SRPEditorForm.FindName($_.Name)}


##############################
# Hide the Tabs of my TabItems
ForEach ($TabItem in $tcTabs.Items) {
    $TabItem.Visibility="Hidden"
}

#######
# Create a Hash table of ListView items on the left and their respective Tab controls
$ListViewToTab=@{
    0 = 0; # PlugIn
    1 = 1; # Actions
    2 = 2; # Action_X
    3 = 3; # Output
    4 = 4; # Preferences
    5 = 5; # Language
    6 = 6; # Modules / Extensions
    7 = 7; # Sign
    8 = 8; # Build
    9 = 9; # Test
  }

############################
# Add events to Form Objects

function SaveProjectMemoryObectToDisk()
{
    if (($script:ProjectMemoryObject.PlugIn.ProjectFolder -ne "") -and ($script:ProjectMemoryObject.PlugIn.FileName -ne ""))
    {
        try
        {
        $SaveToFile = Join-Path -Path $script:ProjectMemoryObject.PlugIn.ProjectFolder -ChildPath ($script:ProjectMemoryObject.PlugIn.FileName)
        if (-Not (Test-Path $SaveToFile))
        {
	        New-Item $SaveToFile -type file | out-null
        }
            try
            {
                $script:ProjectMemoryObject.PlugIn.Name = $tbPlugInName.Text.Trim()
                $script:ProjectMemoryObject.PlugIn.ProjectFolder = $tbPlugInProjectFolder.Text.Trim()
                $script:ProjectMemoryObject.PlugIn.Author = $tbPlugInAuthor.Text.Trim()
                $script:ProjectMemoryObject.PlugIn.Version.Major = $tbPlugInVersionMajor.Text.ToDecimal($Null)
                $script:ProjectMemoryObject.PlugIn.Version.Minor = $tbPlugInVersionMinor.Text.ToDecimal($Null)
                $script:ProjectMemoryObject.PlugIn.Version.Build = $tbPlugInVersionBuild.Text.ToDecimal($Null)

                $script:ProjectMemoryObject.Generated.At = (Get-Date).tostring($TimeStampFormatForJSON)
                $ProjectMemoryObject | Export-Clixml -Path $SaveToFile
            }
            catch
            {
                LogError ("Failed to save the Project File ""{0}"". Exception: {0}" -f $SaveToFile)
            }
        }
        catch
        {
            LogError ("Failed to save the Project File. Exception: {0}" -f $SaveToFile)
        }
    }
}

#######
# Save button
$btSave.Add_Click({
    SaveProjectMemoryObectToDisk
})

############
# Navigation
$btPrevious.Add_Click({
   if ($lvStep.SelectedIndex -gt 0)
   {
       $lvStep.SelectedIndex = $lvStep.SelectedIndex - 1
   }
})

$btNext.Add_Click({
   $lvStep.SelectedIndex = $lvStep.SelectedIndex + 1
})


$lvStep.Add_SelectionChanged({
   if (($lvStep.SelectedIndex -ge 0) -and ($lvStep.SelectedIndex -le $tcTabs.Items.Count))
   {
       $tcTabs.SelectedIndex = $ListViewToTab.($lvStep.SelectedIndex)
   }
    
})

# ########
# Build the list of Plug-in Cloud Templates

function PlugInDownloadCloudRefresh()
{
    param
    (
        [Switch] $DownloadFromCloud = $False
    )

    # Start with a fresh Array
    $PlugInCloudTemplateListArray = @()

    # Clean any error info on the UI
    $caPlugInDownloadCloudRefreshStatus.ToolTip = ""
    $caPlugInDownloadCloudRefreshStatus.Visibility = "Hidden"

    # Download the JSON template list TO the local disk
    # URL to download from is in: $configJson.PlugInCloudTemplateURL

    if ($DownloadFromCloud)
    {
        try
        {
            LogInfo ("Downloading Plug In Templates from the Cloud ({0})..." -f $configJson.PlugInCloudTemplateURL)
            # Get from the Cloud
            $PlugInCloudTemplateListTempRaw = Invoke-WebRequest -Uri $configJson.PlugInCloudTemplateURL #-OutFile $output
            # Pass the JSON content into an object
            LogInfo "Parsing Plug In Templates JSON..."
            $PlugInCloudTemplateListTempJSON = $PlugInCloudTemplateListTempRaw.Content | ConvertFrom-Json
            LogInfo "Parsed."
            LogInfo ("Downloaded document of DocType: ""{0}"" // Last Updated on: {1}." -f $PlugInCloudTemplateListTempJSON.DocType, $PlugInCloudTemplateListTempJSON.LastUpdateTime)
            if ($PlugInCloudTemplateListTempJSON.DocType -eq  "PlugInCloudTemplateList")
            {
                $PlugInCloudTemplateListTempJSON | Add-Member -MemberType NoteProperty -Name 'DownloadTime' -Value (Get-Date).tostring($TimeStampFormatForJSON)
                LogInfo ("Cloud document contains {0} templates." -f $PlugInCloudTemplateListTempJSON.PlugInCloudTemplateList.Count)
                LogInfo ("Writing template document locally ({0})." -f $PlugInCloudTemplateListJSONLocalFile)
                if (-Not (Test-Path $PlugInCloudTemplateListJSONLocalFile))
                {
	                New-Item $PlugInCloudTemplateListJSONLocalFile -type file | out-null
                }
                # Write the Config into the Config file
                $PlugInCloudTemplateListTempJSON | ConvertTo-Json -Depth 100 | Out-File -FilePath $PlugInCloudTemplateListJSONLocalFile
            }
            else
            {
                $TmpMsg = ("Wrong file type ({0})." -f $PlugInCloudTemplateListTempJSON.DocType)
                LogError $TmpMsg
                $caPlugInDownloadCloudRefreshStatus.ToolTip = $TmpMsg
                $caPlugInDownloadCloudRefreshStatus.Visibility = "Visible"
                $rttbPlugInCloudTemplateList.Fill = "#FFFF661E"
            }
        }
        catch
        {
            $TmpMsg = ("Failed to download Plug In Templates from the Cloud ({0})." -f $configJson.PlugInCloudTemplateURL)
            LogError $TmpMsg
            $caPlugInDownloadCloudRefreshStatus.ToolTip = $TmpMsg
            $caPlugInDownloadCloudRefreshStatus.Visibility = "Visible"
            $rttbPlugInCloudTemplateList.Fill = "#FFFF661E"
        }
    }

    # Load the JSON template list FROM the local disk
    if (Test-Path $PlugInCloudTemplateListJSONLocalFile)
    {
        try
        {
            $PlugInCloudTemplateListJSON = Get-Content -Raw -Path $PlugInCloudTemplateListJSONLocalFile | ConvertFrom-Json
	        ForEach ($attribute in @("DocType", "PlugInCloudTemplateList")) {
		        if (-Not (Get-Member -inputobject $PlugInCloudTemplateListJSON -name $attribute -Membertype Properties) -Or [string]::IsNullOrEmpty($PlugInCloudTemplateListJSON.$attribute))
		        {
			        LogError ($attribute + " has not been specified in '{0}' file." -f $PlugInCloudTemplateListJSONLocalFile)
		        }
	        }
            LogInfo ("File '{0}' parsed correctly." -f $PlugInCloudTemplateListJSONLocalFile)

            # All Good!
            # Build the array for the UI DataGrid from the JSON template list
            if ($PlugInCloudTemplateListJSON.DocType -eq 'PlugInCloudTemplateList') # OK, we have the right Doc Type
            {
                ForEach ($TemplateItem in $PlugInCloudTemplateListJSON.PlugInCloudTemplateList)
                {
                    $PlugInCloudTemplateItem = select-object -inputobject "" Name,Version,Author,Description,LastUpdated
                    $PlugInCloudTemplateItem.Name = $TemplateItem.Name
                    $PlugInCloudTemplateItem.Version = $TemplateItem.Version
                    $PlugInCloudTemplateItem.Author = $TemplateItem.Author
                    $PlugInCloudTemplateItem.Description = $TemplateItem.Description
                    $PlugInCloudTemplateItem.LastUpdated = $TemplateItem.LastUpdated
                    $PlugInCloudTemplateListArray += $PlugInCloudTemplateItem
                }
            }
        }
        catch
        {
	        LogError ("Could not parse '{0}' file. Going on empty." -f $PlugInCloudTemplateListJSONLocalFile)
        }
    }
    else
    {
	    LogInfo ("File '{0}' doesn't exists. Going on empty." -f $PlugInCloudTemplateListJSONLocalFile)
        $PlugInCloudTemplateListJSON = "{}" | ConvertFrom-Json
    }

    # Push the Array to the Data Grid in th UI
    $dgPlugInCloudTemplateList.ItemsSource=$PlugInCloudTemplateListArray
}

# Function to Browse for a folder
Function Get-DirectoryName()
{   
    param
    (
        [string] $InitialDirectory = "",
        [string] $Description = $null,
        [Switch] $ShowNewFolderButton = $False
    )
    try
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

        $OpenFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        $OpenFolderDialog.ShowNewFolderButton = $ShowNewFolderButton
        $OpenFolderDialog.SelectedPath = $InitialDirectory
        $OpenFolderDialog.Description = $Description
        $DialogResult = $OpenFolderDialog.ShowDialog() #| Out-Null
        if ($DialogResult -eq "OK")
        {
            return $OpenFolderDialog.SelectedPath
        }
        else
        {
            return $null
        }
    }
    catch
    {
        LogError "Impossible to browse for directory."
        return $null
    }
}

# Function to Browse for a file
Function Get-FileName()
{   
    param
    (
        [string] $Filter = "All files (*.*)| *.*",
        [string] $InitialDirectory = "",
        [string] $Title = "",
        [Switch] $CheckFileExists = $false,
        [Switch] $ReadOnlyChecked = $false,
        [Switch] $ShowReadOnly = $false,
        [Switch] $Multiselect = $false
    )
    try
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $InitialDirectory
        $OpenFileDialog.filter = $Filter
        $OpenFileDialog.CheckFileExists = $CheckFileExists
        $OpenFileDialog.ReadOnlyChecked = $ReadOnlyChecked
        $OpenFileDialog.ShowReadOnly = $ShowReadOnly
        $OpenFileDialog.Multiselect = $Multiselect
        $OpenFileDialog.Title = $Title
        $OpenFileDialog.ShowDialog() | Out-Null
        return $OpenFileDialog.filename
    }
    catch
    {
        LogError "Impossible to browse for files."
        return $null
    }
}

$btPlugInDownloadCloudRefresh.Add_Click({
#    $rttbPlugInCloudTemplateList.Fill = "#FFFF661E"
    PlugInDownloadCloudRefresh -DownloadFromCloud
#    $rttbPlugInCloudTemplateList.Fill = "#FF007BC2"
})

$btPlugInDownloadCloudTemplate.Add_Click({
    # Goofing around, trying to find a nice visual way to show that there was an issue
    $rttbPlugInCloudTemplateList.Fill = "#FFFF661E" ## This is a test
    $caPlugInDownloadCloudRefreshStatus.Visibility = "Visible" ## This is a test
})

# Setting up the TextBox validation function

[System.Windows.RoutedEventHandler]$textChangedHandler = {
			
    try
    {
        $TextBoxTag = $_.OriginalSource.Tag
        if ($TextBoxTag -match '^ValidIf__(.*)')
        {
            if ($matches.Count -gt 0)
            {
                #LogDebug $matches[1]
                $TextBoxValidated = $false
                $TextBoxText = $_.OriginalSource.Text # Doing this as using $_.OriginalSource.Text in the Switch seems to provide weird results...

                switch -wildcard ($matches[1]) {
                   "NotEmpty"
                   {
                       if (-not ([string]::IsNullOrEmpty($TextBoxText))) { $TextBoxValidated = $true }
                       break
                   }
                   "Empty"
                   {
                       if ([string]::IsNullOrEmpty($TextBoxText)) { $TextBoxValidated = $true }
                       break
                   }
                   "RegEx:*"
                   {
                       $PatternAreYouThere = ($matches[1] -match 'RegEx:(.*)')
                       $Pattern = $matches[1]
                       #LogDebug $Pattern
                       if ($TextBoxText -match $Pattern) { $TextBoxValidated = $true }
                       break
                   }
                   default 
                   {
                       LogDebug ("Validation method un-supported for this TextBox ({0})" -f $matches[1])
                       break
                   }
                }                

                #LogInfo $TextBoxValidated
                if ($TextBoxValidated)
                {  # Valid
                    (([Windows.Media.VisualTreeHelper]::GetParent($_.OriginalSource)).Children | Where-Object {$_ -is [System.Windows.Shapes.Rectangle] }).Fill="#FF007BC2"
                }
                else
                {  # Not valid
                    (([Windows.Media.VisualTreeHelper]::GetParent($_.OriginalSource)).Children | Where-Object {$_ -is [System.Windows.Shapes.Rectangle] }).Fill="Red"
                }
            }
        }
    }
    catch
    {
        LogError "TextBox validation failed."
    }
}

$SRPEditorForm.AddHandler([System.Windows.Controls.TextBox]::TextChangedEvent, $textChangedHandler)


# ########
# Build the list of Parameter fields (LogRhythm MDI fields)

$ComboBoxList = $null

function ParameterFieldArray()
{
    param
    (
        [Switch] $DownloadFromCloud = $False
    )

}

function ParameterFieldUpdate()
{
    param
    (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [System.Windows.Controls.ComboBox[]] $ComboBoxes = $(Throw("-ComboBoxes is required")),
        [Switch] $DownloadFromCloud = $False
    )

    # Start with a fresh Array
    $ParameterFieldListArray = @()

    $ParameterFieldListArray = Get-Content -Raw -Path $LogRhythmFieldsListJSONLocalFile  | ConvertFrom-Json

    # Look for ComboBoxes that have Tag="NeedList:LRFields"
    # Then assign them $ListView to the ItemsSource property
    # ...
    # Gave up, and did it by sending them by hand in a parameter.
    foreach ($ComboBox in $ComboBoxes)
    {
        $ListView = [System.Windows.Data.ListCollectionView]$ParameterFieldListArray
        $ListView.GroupDescriptions.Add((new-object System.Windows.Data.PropertyGroupDescription "Family"))
        $ComboBox.ItemsSource = $ListView
    }
}

# ########
# UI : PlugIn tab : Browse button

$btPlugInProjectFolderBrowse.Add_Click({
    
    # No folder, no file name, no author name, then I guess we never ran, so let's grab the user info and store them as the Author name
    if ([string]::IsNullOrEmpty($script:ProjectMemoryObject.PlugIn.ProjectFolder) -and [string]::IsNullOrEmpty($script:ProjectMemoryObject.PlugIn.FileName) -and [string]::IsNullOrEmpty($script:ProjectMemoryObject.PlugIn.Author))
    {
        $script:ProjectMemoryObject.PlugIn.Author = $env:USERNAME.Trim()
        $tbPlugInAuthor.Text = $script:ProjectMemoryObject.PlugIn.Author
    }
    
    # If no folder already specified, use the $LastBrowsePath, otherwise, use the Path of the project
    if ($script:ProjectMemoryObject.PlugIn.ProjectFolder -ne "")
    {
        $BrowseFrom = $script:ProjectMemoryObject.PlugIn.ProjectFolder
    }
    else
    {
        $BrowseFrom = $script:LastBrowsePath
    }

    # Browse for a directory
    $NewProjectDirectory = Get-DirectoryName -ShowNewFolderButton -Description "Select the root of the SmartResponse Project." -InitialDirectory $BrowseFrom
    
    # Check user clicked on OK and everything was fine
    if (-not [string]::IsNullOrEmpty($NewProjectDirectory))
    {
        # Doing this so next time we Browse, we are pointed straight to where we were last time (well, this time)
        $script:LastBrowsePath = $NewProjectDirectory

        LogInfo ("Setting new project folder to: ""{0}""." -f $NewProjectDirectory)
        try
        {
            if (-Not (Test-Path $NewProjectDirectory))
            {
	            New-Item -ItemType directory -Path $NewProjectDirectory | out-null
            }
            try
            {
                # Check if there is already some FileName in the Memory Object. If not, create a new one.
                if ([string]::IsNullOrEmpty($script:ProjectMemoryObject.PlugIn.FileName))
                {
                    $NewProjectName = $tbPlugInName.Text.Trim()
                    if ($NewProjectName.Length -le 0)
                    {
                        $NewProjectName = "SmartResponse Project"
                    }
                    # Assign back to the UI (so if there was nothing before, now it's going to revert back to the default "SmartResponse Project")
                    $tbPlugInName.Text = $NewProjectName
                    $script:ProjectMemoryObject.PlugIn.FileName = $NewProjectName + ".SRPx"
                }

                $NewProjectFile = Join-Path -Path $NewProjectDirectory -ChildPath ($script:ProjectMemoryObject.PlugIn.FileName)
                if (-Not (Test-Path $NewProjectFile))
                {
	                New-Item $NewProjectFile -type file | out-null
                }
            

                # Assign the value to the memory object
                $script:ProjectMemoryObject.PlugIn.ProjectFolder = $NewProjectDirectory
                # Assign new path to the UI
                $tbPlugInProjectFolder.Text = $NewProjectDirectory

                # Save what we have to disk
                SaveProjectMemoryObectToDisk

            }
            catch
            {
                LogError ("Failed to create the new project file: {0}." -f $NewProjectFile)
            }
        }
        catch
        {
            LogError ("Failed to open or create the new project folder: {0}." -f $NewProjectDirectory)
        }
    } # if (-not [string]::IsNullOrEmpty($NewProjectDirectory)

})

# ########
# UI : PlugIn tab : Open button

$btPlugInOpen.Add_Click({
    # Browse for a File
    $ProjectFileToOpen = Get-FileName -Filter "SmartResponse Project files (*.srpx)|*.srpx|All files (*.*)| *.*" -Title "Open a SmartResponse Project files" -CheckFileExists -InitialDirectory $script:LastBrowsePath
    
    # Check user clicked on OK and everything was fine
    if (-not [string]::IsNullOrEmpty($ProjectFileToOpen))
    {
        LogInfo ("Loading ""{0}"" project file..." -f $ProjectFileToOpen)
        try
        {
            $TempProjectObject = Import-Clixml -Path $ProjectFileToOpen
            LogInfo "Loaded from disk."
        }
        catch
        {
            LogError ("Failed to load or parse Project File: ""{0}"". Exception: {1}." -f $ProjectFileToOpen, $_.Exception.Message)
        }

        # Check we are in the right format
        # We should check the version too, but so far all tool versions can open files of all version
        try
        {
            if ($TempProjectObject.File.Type -eq "SmartResponse PlugIn Project")
            {
                $script:ProjectMemoryObject = $TempProjectObject
            }
            else
            {
                LogError "Project File format is not supported."
            }
        }
        catch
        {
            LogError ("Project File format is not supported. Exception: {0}." -f $_.Exception.Message)
        }


        # Refresh the UI
        try
        {
            $tbPlugInName.Text          = $script:ProjectMemoryObject.PlugIn.Name
            $tbPlugInProjectFolder.Text = $script:ProjectMemoryObject.PlugIn.ProjectFolder
            $tbPlugInAuthor.Text        = $script:ProjectMemoryObject.PlugIn.Author
            $tbPlugInVersionMajor.Text  = $script:ProjectMemoryObject.PlugIn.Version.Major.ToString()
            $tbPlugInVersionMinor.Text  = $script:ProjectMemoryObject.PlugIn.Version.Minor.ToString()
            $tbPlugInVersionBuild.Text  = $script:ProjectMemoryObject.PlugIn.Version.Build.ToString()
        }
        catch
        {
            LogError ("Failed to update UI from the Project File. Exception: {0}" -f $_.Exception.Message)
        }

    }
    
})

# ########
# UI : PlugIn tab : Import XML button

$btPlugInImportXML.Add_Click({
    Get-FileName -Filter "XML SmartResponse Config files (*.xml)|*.xml|All files (*.*)| *.*" -Title "Open an XML SmartResponse Configuraion file" -CheckFileExists -ReadOnlyChecked -ShowReadOnly
    LogError "NOT IMPLEMENTED YET"
})

# ########
# UI : PlugIn tab : Import LPI button

$btPlugInImportLPI.Add_Click({
    Get-FileName -Filter "LPI Compiled SmartResponse files (*.lpi)|*.lpi|All files (*.*)| *.*" -Title "Open an LPI Compiled SmartResponse file" -CheckFileExists -ReadOnlyChecked -ShowReadOnly
    LogError "NOT IMPLEMENTED YET"
})


# ########
# UI : Actions tab
##########################################################

# ########
# UI : Actions tab : Adding an action to the list

$btActionsNameAdd.Add_Click({
    #LogError "NOT IMPLEMENTED YET"
    $ActionNameToAdd = $tbActionsName.Text.Trim()
    if (-not [string]::IsNullOrEmpty($ActionNameToAdd))
    {
        $GoodToAdd = $true
        foreach ($Action in $script:ProjectMemoryObject.Actions)
        {
            if ($Action.Name -eq $ActionNameToAdd)
            {
                $GoodToAdd = $false
            }
        }
        if ($GoodToAdd)
        {
            $ActionToAdd = [SRPAction]@{ Name = "$ActionNameToAdd"}
            $script:ProjectMemoryObject.Actions += $ActionToAdd
            $dgActonsOrder.items.Add($ActionToAdd)
        }
    }

    for ($i = 0 ; $i -lt $lvStep.Items.Count ; $i++)
    {
        $lvStep.Items[$i].Content.Children | where { -not [string]::IsNullOrEmpty($_.Text)} | select Text
    }

    $a = $lvStep.Items.Add("Tony")
    LogDebug "Added $a"

})

# ########
# UI : Actions tab : Adding an action to the list

$btActionsNameRefresh.Add_Click({
    LogError "NOT IMPLEMENTED YET"
})

# ########
# UI : Actions tab : Import from Template drop down list

$cbActionsImportFromTemplate.Add_SelectionChanged({
    LogError "NOT IMPLEMENTED YET"
})

# ########
# UI : Actions tab : Deleting an action from the list

$btActonsDelete.Add_Click({
    LogError "NOT IMPLEMENTED YET"
})

# ########
# UI : Actions tab : Move action to the top of the list

$btActonsOrderTop.Add_Click({
    LogError "NOT IMPLEMENTED YET"
})

# ########
# UI : Actions tab : Move action one level up in the list

$btActonsOrderUp.Add_Click({
    LogError "NOT IMPLEMENTED YET"
})

# ########
# UI : Actions tab : Move action one level down in the list

$btActonsOrderDown.Add_Click({
    LogError "NOT IMPLEMENTED YET"
})

# ########
# UI : Actions tab : Move action to the bottom of the list

$btActonsOrderBottom.Add_Click({
    LogError "NOT IMPLEMENTED YET"
})




# ########
# UI : ActionX tab
##########################################################

# ########
# UI : ActionX tab : Field mapping drop down

$cbActionXFieldMappingField.Add_SelectionChanged({
    #LogDebug ("cbActionXFieldMappingField::SelectionChanged // Index: {0} / Value: ""{1}"" / Entry: ""{2}""" -f $cbActionXFieldMappingField.SelectedIndex, $cbActionXFieldMappingField.SelectedValue, $cbActionXFieldMappingField.SelectedValue.Name)
    LogError "NOT IMPLEMENTED YET"
})

# ########
# UI : Test tab
##########################################################

# ########
# UI : Test tab : Field drop down

$cbTestParameters.Add_SelectionChanged({
    #LogDebug "cbTestParameters::SelectionChanged"
})



########################################################################################################################
##################################################### Execution!!  #####################################################
########################################################################################################################


# Pre-populate the Cloud Template List from the local cashed copy
PlugInDownloadCloudRefresh

# Populate the List of Fields in the right ComboBoxes
ParameterFieldUpdate -ComboBoxes ($cbActionXFieldMappingField, $cbTestParameters)



#$cbTestParameters.ItemsSource = ParameterFieldUpdate
#ParameterFieldUpdate -ComboBox $cbTestParameters
#$cbTestParameters.GetType()

# Run the UI
$SRPEditorForm.ShowDialog() | out-null

# Time to depart, my old friend...
LogInfo "Exiting SmartResponse Plug-In Editor"
# Didn't we have a joly good time?
