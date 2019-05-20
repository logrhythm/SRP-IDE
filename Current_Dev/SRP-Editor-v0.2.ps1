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

# Directories and files information
# Base directory
$basePath = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path

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

# Local copy of the Plug-In Cloud Template List JSON
$PlugInCloudTemplateListJSONLocalFile = Join-Path -Path $configPath -ChildPath "PlugInCloudTemplateList.json"


# Logging functions
function LogMessage([string] $logLevel, [string] $message)
{
    $Msg  = ([string]::Format("{0}|{1}|{2}", (Get-Date).tostring("yyyy.MM.dd HH:mm:ss"), $logLevel, $message))
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

function SimpleQueryGet([string] $SimpleQuery_)
{
    $SimpleQuery_
	$response = Invoke-RestMethod -Uri ($url + $SimpleQuery_) -Method Get -Headers $headers
    $response  | Format-Table -wrap
}
function SimpleQueryPost([string] $SimpleQuery_)
{
    $SimpleQuery_
	$response = Invoke-RestMethod -Uri ($url + $SimpleQuery_) -Method Post -Headers $headers
    $response  | Format-Table -wrap
}

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

$ConfigEditorv1_6 = "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"

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
    5 = 5; # 
  }

############################
# Add events to Form Objects

#######
# Save button
$btSave.Add_Click({

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

function PlugInDownloadCloudRefresh()
{
    # ########
    # Build the list of Plug-in Cloud Templates

    $PlugInCloudTemplateListArray = @()

    # Download the JSON template list TO the local disk
    # URL to download from is in: $configJson.PlugInCloudTemplateURL
    # TODO - XXXXXXXXXXXXXXXXXX

    # Load the JSON template list FROM the local disk
    if (Test-Path $PlugInCloudTemplateListJSONLocalFile)
    {
        try
        {
            $PlugInCloudTemplateListJSON = Get-Content -Raw -Path $PlugInCloudTemplateListJSONLocalFile | ConvertFrom-Json
	        ForEach ($attribute in @("DocType", "PlugInCloudTemplateList")) {
		        if (-Not (Get-Member -inputobject $PlugInCloudTemplateListJSON -name $attribute -Membertype Properties) -Or [string]::IsNullOrEmpty($PlugInCloudTemplateListJSON.$attribute))
		        {
			        LogError ($attribute + " has not been specified in 'PlugInCloudTemplateList.json' file.")
		        }
	        }
            LogInfo "File 'PlugInCloudTemplateList.json' parsed correctly."

            # All Good!
            # Build the array for the UI DataGrid from the JSON template list
            if ($PlugInCloudTemplateListJSON.DocType -eq 'PlugInCloudTemplateList') # OK, we have the right Doc Type
            {
                ForEach ($TemplateItem in $PlugInCloudTemplateListJSON.PlugInCloudTemplateList)
                {
                    $tmpObject = select-object -inputobject "" Name,Version,Author,Description,LastUpdated
                    $tmpObject.Name = $TemplateItem.Name
                    $tmpObject.Version = $TemplateItem.Version
                    $tmpObject.Author = $TemplateItem.Author
                    $tmpObject.Description = $TemplateItem.Description
                    $tmpObject.LastUpdated = $TemplateItem.LastUpdated
                    $PlugInCloudTemplateListArray += $tmpObject
                }
            }
        }
        catch
        {
	        LogError "Could not parse 'PlugInCloudTemplateList.json' file. Going on empty."
        }
    }
    else
    {
	    LogInfo ("File 'PlugInCloudTemplateList.json' doesn't exists. Going on empty.")
        $PlugInCloudTemplateListJSON = "{}" | ConvertFrom-Json
    }

    # Push the Array to the Data Grid in th UI
    $dgPlugInCloudTemplateList.ItemsSource=$PlugInCloudTemplateListArray
}

$btPlugInDownloadCloudRefresh.Add_Click({
    PlugInDownloadCloudRefresh
})


########################################################################################################################
##################################################### Execution!!  #####################################################
########################################################################################################################


# Pre-populate the Cloud Template List
PlugInDownloadCloudRefresh

# Run the UI
$SRPEditorForm.ShowDialog() | out-null

# Time to depart, my old friend...
LogInfo "Exiting SmartResponse Plug-In Editor"
# Didn't we have a joly good time?