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
# - Add and Modify Actions
# - Build navigation panel programatically
# - Order Actions
# - Add and Modify Parameters
# - Order Parameters
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

#  888     888                  d8b          888      888                              .d8888b.                             888                      888             
#  888     888                  Y8P          888      888                             d88P  Y88b                            888                      888             
#  888     888                               888      888                             888    888                            888                      888             
#  Y88b   d88P  8888b.  888d888 888  8888b.  88888b.  888  .d88b.  .d8888b            888         .d88b.  88888b.  .d8888b  888888  8888b.  88888b.  888888 .d8888b  
#   Y88b d88P      "88b 888P"   888     "88b 888 "88b 888 d8P  Y8b 88K                888        d88""88b 888 "88b 88K      888        "88b 888 "88b 888    88K      
#    Y88o88P   .d888888 888     888 .d888888 888  888 888 88888888 "Y8888b.           888    888 888  888 888  888 "Y8888b. 888    .d888888 888  888 888    "Y8888b. 
#     Y888P    888  888 888     888 888  888 888 d88P 888 Y8b.          X88 d8b       Y88b  d88P Y88..88P 888  888      X88 Y88b.  888  888 888  888 Y88b.       X88 
#      Y8P     "Y888888 888     888 "Y888888 88888P"  888  "Y8888   88888P' 88P        "Y8888P"   "Y88P"  888  888  88888P'  "Y888 "Y888888 888  888  "Y888  88888P' 
#                                                                           8P                                                                                       
#                                                                           "                                                                                        
#                                                                                                                                                                    
#  88888888888                                            .d8888b.           8888888888                            888    d8b                                        
#      888                                               d88P  "88b          888                                   888    Y8P                                        
#      888                                               Y88b. d88P          888                                   888                                               
#      888     888  888 88888b.   .d88b.  .d8888b         "Y8888P"           8888888    888  888 88888b.   .d8888b 888888 888  .d88b.  88888b.  .d8888b              
#      888     888  888 888 "88b d8P  Y8b 88K            .d88P88K.d88P       888        888  888 888 "88b d88P"    888    888 d88""88b 888 "88b 88K                  
#      888     888  888 888  888 88888888 "Y8888b.       888"  Y888P"        888        888  888 888  888 888      888    888 888  888 888  888 "Y8888b.             
#      888     Y88b 888 888 d88P Y8b.          X88       Y88b .d8888b        888        Y88b 888 888  888 Y88b.    Y88b.  888 Y88..88P 888  888      X88             
#      888      "Y88888 88888P"   "Y8888   88888P'        "Y8888P" Y88b      888         "Y88888 888  888  "Y8888P  "Y888 888  "Y88P"  888  888  88888P'             
#                   888 888                                                                                                                                          
#              Y8b d88P 888                                                                                                                                          
#               "Y88P"  888                                                                                                                                          

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

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
                              [string]$FieldName
                              [string]$FieldCode
                              [string]$ConstantValue
                              [string]$Switch
                              [string]$ValidationRule
    SRPActionParameter ()
    {
    }
    SRPActionParameter ([string]$Name)
    {
        $this.Name = $Name
    }
    SRPActionParameter ([string]$Name, [string]$Type)
    {
        $this.Name = $Name
        $this.Type = $Type
    }
}

class SRPAction
{
    [ValidateNotNullOrEmpty()][string]$Name
    [ValidateNotNullOrEmpty()][guid]$GUID
    [ValidateNotNullOrEmpty()][string]$Command
   #[ValidateNotNullOrEmpty()][SRPActionParameter[]]$Parameters  # Old style Array of type. Moved on, and now using ArrayList
   #[ValidateNotNullOrEmpty()][System.Collections.ArrayList]$Parameters # Silly me, this fails because I both want to create an empty object, and at the same time prevent empty object...
                              [System.Collections.ArrayList]$Parameters
    SRPAction ()
    {
        $this.Parameters = New-Object System.Collections.ArrayList
    }
    SRPAction ([string]$Name)
    {
        $this.Parameters = New-Object System.Collections.ArrayList
        $this.Name = $Name
    }
    SRPAction ([string]$Name, [guid]$GUID)
    {
        $this.Parameters = New-Object System.Collections.ArrayList
        $this.Name = $Name
        $this.GUID = $GUID
    }
    SRPAction ([string]$Name, [guid]$GUID, [string]$Switch)
    {
        $this.Parameters = New-Object System.Collections.ArrayList
        $this.Name = $Name
        $this.GUID = $GUID
        $this.Switch = $Switch
    }
}


class SRPTestParameter
{
    [ValidateNotNullOrEmpty()][string]$Name
    [ValidateNotNullOrEmpty()][string]$Code
                              [string]$Value
}

class SRPTest
{
    [ValidateNotNullOrEmpty()][bool]$Enable
    [ValidateNotNullOrEmpty()][string]$Action
                              [System.Collections.ArrayList]$Parameters
    SRPTest ()
    {
        $this.Parameters = New-Object System.Collections.ArrayList
    }
    SRPTest ($Action)
    {
        $this.Parameters = New-Object System.Collections.ArrayList
        $this.Action = $Action
        $this.Enable = $true
    }
    SRPTest ($Action, $Enable)
    {
        $this.Parameters = New-Object System.Collections.ArrayList
        $this.Action = $Action
        $this.Enable = $Enable
    }

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
#                      ; "Actions" = @() # I moved from the good old Array to an ArrayList object, as it offers built-in item management functions
                       ; "Actions" = New-Object System.Collections.ArrayList
                       ; "Output" =
                           @{"Folder" = '%SRP_Project%\Output'
                           ; "OneFolderPerVersion" = $true
                           }
                       ; "Preferences" =
                           @{"LicenseFile" =
                               @{"Name" = ""
                               ; "Text" = ""
                               }
                           ; "GenerateSingleScriptFile" = $false
                           ; "GenerateLPIAtBuildTime" = $false
                           }
                       ; "Language" =
                           @{"ScriptingLanguage" = "PowerShell"
                           ; "Command" = "powershell.exe"
                           ; "DefaultParameters" = 
                               @{"Type" = "Constant"
                               ; "Name" = "Script"
                               ; "MapToField" = ""
                               ; "ConstantValue" = ""
                               ; "Switch" = '-file "%SRP"'
                               ; "ValidationRule" = ""
                               }
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
                       ; "Tests" = New-Object System.Collections.ArrayList
                       }

$LoadedNew = @{"Actions" = $false
             ; "Preferences" = $false
             }


#  8888888b.  d8b                           888                     d8b                                                888        .d888 d8b 888                         
#  888  "Y88b Y8P                           888                     Y8P                                                888       d88P"  Y8P 888                         
#  888    888                               888                                                                        888       888        888                         
#  888    888 888 888d888  .d88b.   .d8888b 888888  .d88b.  888d888 888  .d88b.  .d8888b         8888b.  88888b.   .d88888       888888 888 888  .d88b.  .d8888b        
#  888    888 888 888P"   d8P  Y8b d88P"    888    d88""88b 888P"   888 d8P  Y8b 88K                "88b 888 "88b d88" 888       888    888 888 d8P  Y8b 88K            
#  888    888 888 888     88888888 888      888    888  888 888     888 88888888 "Y8888b.       .d888888 888  888 888  888       888    888 888 88888888 "Y8888b.       
#  888  .d88P 888 888     Y8b.     Y88b.    Y88b.  Y88..88P 888     888 Y8b.          X88       888  888 888  888 Y88b 888       888    888 888 Y8b.          X88       
#  8888888P"  888 888      "Y8888   "Y8888P  "Y888  "Y88P"  888     888  "Y8888   88888P'       "Y888888 888  888  "Y88888       888    888 888  "Y8888   88888P'       
#                                                                                                                                                                       
#                                                                                                                                                                       
#                                                                                                                                                                       

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

#  888                                 d8b                   
#  888                                 Y8P                   
#  888                                                       
#  888       .d88b.   .d88b.   .d88b.  888 88888b.   .d88b.  
#  888      d88""88b d88P"88b d88P"88b 888 888 "88b d88P"88b 
#  888      888  888 888  888 888  888 888 888  888 888  888 
#  888      Y88..88P Y88b 888 Y88b 888 888 888  888 Y88b 888 
#  88888888  "Y88P"   "Y88888  "Y88888 888 888  888  "Y88888 
#                         888      888                   888 
#                    Y8b d88P Y8b d88P              Y8b d88P 
#                     "Y88P"   "Y88P"                "Y88P"  

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


#   .d8888b.                    888                      .d8888b.            .d8888b.  888                        888 
#  d88P  Y88b                   888                     d88P  "88b          d88P  Y88b 888                        888 
#  888    888                   888                     Y88b. d88P          888    888 888                        888 
#  888         8888b.   .d8888b 88888b.   .d88b.         "Y8888P"           888        888  .d88b.  888  888  .d88888 
#  888            "88b d88P"    888 "88b d8P  Y8b       .d88P88K.d88P       888        888 d88""88b 888  888 d88" 888 
#  888    888 .d888888 888      888  888 88888888       888"  Y888P"        888    888 888 888  888 888  888 888  888 
#  Y88b  d88P 888  888 Y88b.    888  888 Y8b.           Y88b .d8888b        Y88b  d88P 888 Y88..88P Y88b 888 Y88b 888 
#   "Y8888P"  "Y888888  "Y8888P 888  888  "Y8888         "Y8888P" Y88b       "Y8888P"  888  "Y88P"   "Y88888  "Y88888 
#                                                                                                                     
#                                                                                                                     
#                                                                                                                     

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

# Local copy of the Languages List JSON
$LanguagesListJSONLocalFile = Join-Path -Path $cachePath -ChildPath "LanguagesListLocal.json"

# Local copy of the Licenses List JSON
$LicensesListJSONLocalFile = Join-Path -Path $cachePath -ChildPath "LicenseListLocal.json"



#  Y88b   d88P        d8888 888b     d888 888            8888888b.                                                       d8b                   
#   Y88b d88P        d88888 8888b   d8888 888            888   Y88b                                                      Y8P                   
#    Y88o88P        d88P888 88888b.d88888 888            888    888                                                                            
#     Y888P        d88P 888 888Y88888P888 888            888   d88P 888d888  .d88b.   .d8888b  .d88b.  .d8888b  .d8888b  888 88888b.   .d88b.  
#     d888b       d88P  888 888 Y888P 888 888            8888888P"  888P"   d88""88b d88P"    d8P  Y8b 88K      88K      888 888 "88b d88P"88b 
#    d88888b     d88P   888 888  Y8P  888 888            888        888     888  888 888      88888888 "Y8888b. "Y8888b. 888 888  888 888  888 
#   d88P Y88b   d8888888888 888   "   888 888            888        888     Y88..88P Y88b.    Y8b.          X88      X88 888 888  888 Y88b 888 
#  d88P   Y88b d88P     888 888       888 88888888       888        888      "Y88P"   "Y8888P  "Y8888   88888P'  88888P' 888 888  888  "Y88888 
#                                                                                                                                          888 
#                                                                                                                                     Y8b d88P 
#                                                                                                                                      "Y88P"  

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


#   .d8888b.  888                     888    d8b                   
#  d88P  Y88b 888                     888    Y8P                   
#  Y88b.      888                     888                          
#   "Y888b.   888888  8888b.  888d888 888888 888 88888b.   .d88b.  
#      "Y88b. 888        "88b 888P"   888    888 888 "88b d88P"88b 
#        "888 888    .d888888 888     888    888 888  888 888  888 
#  Y88b  d88P Y88b.  888  888 888     Y88b.  888 888  888 Y88b 888 
#   "Y8888P"   "Y888 "Y888888 888      "Y888 888 888  888  "Y88888 
#                                                              888 
#                                                         Y8b d88P 
#                                                          "Y88P"  

# Starting SmartResponse Plug-In Editor
LogInfo "Starting SmartResponse Plug-In Editor"
LogInfo ("Version: " + $Version)


#  8888888b.                         888        .d8888b.                     .d888 d8b          
#  888   Y88b                        888       d88P  Y88b                   d88P"  Y8P          
#  888    888                        888       888    888                   888                 
#  888   d88P  .d88b.   8888b.   .d88888       888         .d88b.  88888b.  888888 888  .d88b.  
#  8888888P"  d8P  Y8b     "88b d88" 888       888        d88""88b 888 "88b 888    888 d88P"88b 
#  888 T88b   88888888 .d888888 888  888       888    888 888  888 888  888 888    888 888  888 
#  888  T88b  Y8b.     888  888 Y88b 888       Y88b  d88P Y88..88P 888  888 888    888 Y88b 888 
#  888   T88b  "Y8888  "Y888888  "Y88888        "Y8888P"   "Y88P"  888  888 888    888  "Y88888 
#                                                                                           888 
#                                                                                      Y8b d88P 
#                                                                                       "Y88P"  

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


#  8888888b.                         888       Y88b   d88P        d8888 888b     d888 888      
#  888   Y88b                        888        Y88b d88P        d88888 8888b   d8888 888      
#  888    888                        888         Y88o88P        d88P888 88888b.d88888 888      
#  888   d88P  .d88b.   8888b.   .d88888          Y888P        d88P 888 888Y88888P888 888      
#  8888888P"  d8P  Y8b     "88b d88" 888          d888b       d88P  888 888 Y888P 888 888      
#  888 T88b   88888888 .d888888 888  888         d88888b     d88P   888 888  Y8P  888 888      
#  888  T88b  Y8b.     888  888 Y88b 888        d88P Y88b   d8888888888 888   "   888 888      
#  888   T88b  "Y8888  "Y888888  "Y88888       d88P   Y88b d88P     888 888       888 88888888 
#                                                                                              
#                                                                                              
#                                                                                              

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
#[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
$reader=(New-Object System.Xml.XmlNodeReader $XAML) 
try{$SRPEditorForm=[Windows.Markup.XamlReader]::Load( $reader )}
catch{LogError "Unable to load Windows.Markup.XamlReader for ConfigReader.MainWindow. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}


##################################
# Store Form Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $SRPEditorForm.FindName($_.Name)}


#  8888888b.                                                            888     888 8888888 
#  888   Y88b                                                           888     888   888   
#  888    888                                                           888     888   888   
#  888   d88P 888d888  .d88b.  88888b.   8888b.  888d888  .d88b.        888     888   888   
#  8888888P"  888P"   d8P  Y8b 888 "88b     "88b 888P"   d8P  Y8b       888     888   888   
#  888        888     88888888 888  888 .d888888 888     88888888       888     888   888   
#  888        888     Y8b.     888 d88P 888  888 888     Y8b.           Y88b. .d88P   888   
#  888        888      "Y8888  88888P"  "Y888888 888      "Y8888         "Y88888P"  8888888 
#                              888                                                          
#                              888                                                          
#                              888                                                          


##############################
# Hide the Tabs of my TabItems
ForEach ($TabItem in $tcTabs.Items) {
    $TabItem.Visibility="Hidden"
}


#   .d8888b.                             
#  d88P  Y88b                            
#  Y88b.                                 
#   "Y888b.    8888b.  888  888  .d88b.  
#      "Y88b.     "88b 888  888 d8P  Y8b 
#        "888 .d888888 Y88  88P 88888888 
#  Y88b  d88P 888  888  Y8bd8P  Y8b.     
#   "Y8888P"  "Y888888   Y88P    "Y8888  
#                                        
#                                        
#                                        

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
                LogInfo "Saving project to file..."
                $ProjectMemoryObject | Export-Clixml -Path $SaveToFile
                LogInfo ("Project saved to file ""{0}""." -f $SaveToFile)
            }
            catch
            {
                LogError ("Failed to save the Project File ""{0}"". Exception: {0}" -f $SaveToFile, $_.Exception.Message)
            }
        }
        catch
        {
            LogError ("Failed to save the Project File. Exception: {0}" -f $_.Exception.Message)
        }
    }
}

#######
# Save button
$btSave.Add_Click({
    SaveProjectMemoryObectToDisk
})


#  888b    888                   d8b                   888    d8b                   
#  8888b   888                   Y8P                   888    Y8P                   
#  88888b  888                                         888                          
#  888Y88b 888  8888b.  888  888 888  .d88b.   8888b.  888888 888  .d88b.  88888b.  
#  888 Y88b888     "88b 888  888 888 d88P"88b     "88b 888    888 d88""88b 888 "88b 
#  888  Y88888 .d888888 Y88  88P 888 888  888 .d888888 888    888 888  888 888  888 
#  888   Y8888 888  888  Y8bd8P  888 Y88b 888 888  888 Y88b.  888 Y88..88P 888  888 
#  888    Y888 "Y888888   Y88P   888  "Y88888 "Y888888  "Y888 888  "Y88P"  888  888 
#                                         888                                       
#                                    Y8b d88P                                       
#                                     "Y88P"                                        

############
# Navigation

# The Buttons at the bottom of the window
$btPrevious.Add_Click({
   if ($lvStep.SelectedIndex -gt 0)
   {
       $lvStep.SelectedIndex = $lvStep.SelectedIndex - 1
   }
})

$btNext.Add_Click({
   $lvStep.SelectedIndex = $lvStep.SelectedIndex + 1
})

# The Navigation tree on the left of the window
$lvStep.Add_SelectionChanged({

    if ($lvStep.Items.Count -gt 0)
    {
        # Move the right tab
        ($tcTabs.Items | where {$_.Header -eq $lvStep.Items[$lvStep.SelectedIndex].GoToTab}).IsSelected = $true
    
        # Check if we are entering a tab that requires refresh
        # If we are, fill the screen with the relevant data
        switch -wildcard ($lvStep.Items[$lvStep.SelectedIndex].GoToTab) {
            "Actions"
            {
                if ($script:LoadedNew.Actions)
                {
                    LogInfo ("New Actions have been loaded. Refresh the dgActionsOrder Grid.")
                    #$dgActionsOrder.Items = $script:ProjectMemoryObject.Actions | select Name
                    try
                    {
                        $dgActionsOrder.Items.Clear()
                        foreach ($Action in $script:ProjectMemoryObject.Actions)
                        {
                            $dgActionsOrder.Items.Add($Action)
                        }
                        $script:LoadedNew.Actions = $false
                    }
                    catch
                    {
                        LogError ("Failed to add Actions to dgActionsOrder Grid. Exception: {0}." -f $_.Exception.Message)
                    }
                }
                break
            }
            "Action_X"
            {
                try
                {
                    # Find which Action we are talking about
                    $CurrentAction=$script:ProjectMemoryObject.Actions | where {$_.GUID -eq $lvStep.Items[$lvStep.SelectedIndex].GUID}

                    # Update the common fields
                    $lbActionXActionName.Content = ("Action: {0}" -f $CurrentAction.name)
                    $lbActionXGUID.Content = ("GUID: {0}" -f $CurrentAction.GUID)
                    $tbActionXCommand.Text = $CurrentAction.Command
                    $cbActionXParamType.SelectedIndex = 1 # String
                    $tbActionXParamName.Text = ""
                    $cbActionXFieldMappingField.SelectedIndex = 0
                    $tbActionXFieldMappingValue.Text = ""
                    $tbActionXFieldSwitch.Text = ""
                    $cbActionXFieldValidation.SelectedIndex = 0

                    # Bring in the Parameters for that Action
                    $dgActionXOrder.Items.Clear()
                    foreach ($Parameter in $CurrentAction.Parameters)
                    {
                        $dgActionXOrder.Items.Add($Parameter)
                    }
                }
                catch
                {
                    LogError ("Failed to update Action X UI. Exception: {0}." -f $_.Exception.Message)
                }
                break
            }
            "Output"
            {
                try
                {
                    # The Folder field
                    $tbOutputFolder.Text = $script:ProjectMemoryObject.Output.Folder
                    # The Folder option Radio Buttons (either OnePerVersion or SingleFolder)
                    if ($script:ProjectMemoryObject.Output.OneFolderPerVersion)
                    {
                        $rbOutputFolderOptionOnePerVersion.IsChecked = $true
                    }
                    else
                    {
                        $rbOutputFolderOptionSingleFolder.IsChecked = $true
                    }
                }
                catch
                {
                    LogError ("Failed to update Output folder or option UI. Exception: {0}." -f $_.Exception.Message)
                }
                break
            }
            "Pref"
            {
                try
                {
                    # The License File drop down list
                    $cbPreferencesLicenseFile.SelectedItem = $cbPreferencesLicenseFile.Items | where {$_.Name -eq $script:ProjectMemoryObject.Preferences.LicenseFile.Name}
                    # The Script File option Radio Buttons (either Single File or Dual File)
                    if ($script:ProjectMemoryObject.Preferences.GenerateSingleScriptFile)
                    {
                        $rbPreferencesScriptFileOptionSingleFile.IsChecked = $true
                    }
                    else
                    {
                        $rbPreferencesScriptFileOptionDualFile.IsChecked = $true
                    }
                    # The LPI generation option (either Do NOt Generate or Generate LPI File)
                    if ($script:ProjectMemoryObject.Preferences.GenerateLPIAtBuildTime)
                    {
                        $rbPreferencesPlugInLPIFileOptionGenerateLPI.IsChecked = $true
                    }
                    else
                    {
                        $rbPreferencesPlugInLPIFileOptionDoNotGenerate.IsChecked = $true
                    }
                }
                catch
                {
                    LogError ("Failed to update Preferences UI. Exception: {0}." -f $_.Exception.Message)
                }
                break
            }
            "Language"
            {
                try
                {
                    # 
                }
                catch
                {
                    LogError ("Failed to update Language UI. Exception: {0}." -f $_.Exception.Message)
                }
                break
            }
            "Mod/Ext"
            {
                try
                {
                    # 
                }
                catch
                {
                    LogError ("Failed to update Modules/Extensions UI. Exception: {0}." -f $_.Exception.Message)
                }
                break
            }
            "Sign"
            {
                try
                {
                    # 
                }
                catch
                {
                    LogError ("Failed to update Signature UI. Exception: {0}." -f $_.Exception.Message)
                }
                break
            }
            "Build"
            {
                try
                {
                    # 
                }
                catch
                {
                    LogError ("Failed to update Build UI. Exception: {0}." -f $_.Exception.Message)
                }
                break
            }
            "Test"
            {
                try
                {
                    # 
                }
                catch
                {
                    LogError ("Failed to update Test UI. Exception: {0}." -f $_.Exception.Message)
                }
                break
            }
            default 
            {

                break
            }
        }                


    }
})

# ########
# Build or Re-build the list of pages in the Navigation panel on the left of the screen (lvSteps)

$MarginLevel = @("0,0,0,0", "20,0,0,0", "40,0,0,0", "60,0,0,0", "80,0,0,0")

Function BuildNavigationTree()
{
    param
    (
        [int] $ItemToSelect = 0 # Send -1 or less, and this will not be used.
    )

    try
    {
        $script:lvStep.Items.Clear()
    }
    catch
    {
        LogDebug ("BuildNavigationTree: lvStep.Items.Clear failed. Exception: {0}" -f $_.Exception.Message)
    }
    $script:lvStep.Items.Add([PSCustomObject]@{Name = "Plug in" ; LaMarge = $script:MarginLevel[0] ; IconName = $script:SRPEditorForm.FindResource("IconPlugIn") ; Tag = "Panel:PlugIn" ; GoToTab = "PlugIn"}) | Out-Null
    $script:lvStep.Items.Add([PSCustomObject]@{Name = "Actions" ; LaMarge = $script:MarginLevel[1] ; IconName = $script:SRPEditorForm.FindResource("IconOrder") ; Tag = "Panel:Actions" ; GoToTab = "Actions"}) | Out-Null
    foreach ($Action in $script:ProjectMemoryObject.Actions)
    {
        #$lvStep.Items.Add([PSCustomObject]@{Name = "Action: XYZ" ; GUID = New-Guid ; LaMarge = $script:MarginLevel[2] ; IconName = $script:SRPEditorForm.FindResource("IconRocket") ; Tag = "Panel:Action_X" ; GoToTab = "Action_X"}) | Out-Null
        $script:lvStep.Items.Add([PSCustomObject]@{Name = ("Action: {0}" -f $Action.Name) ; GUID = $Action.GUID ; LaMarge = $script:MarginLevel[2] ; IconName = $script:SRPEditorForm.FindResource("IconRocket") ; Tag = "Panel:Action_X" ; GoToTab = "Action_X"}) | Out-Null
    }
    $script:lvStep.Items.Add([PSCustomObject]@{Name = "Output" ; LaMarge = $script:MarginLevel[1] ; IconName = $script:SRPEditorForm.FindResource("IconOutput") ; Tag = "Panel:Output" ; GoToTab = "Output"}) | Out-Null
    $script:lvStep.Items.Add([PSCustomObject]@{Name = "Preferences" ; LaMarge = $script:MarginLevel[1] ; IconName = $script:SRPEditorForm.FindResource("IconPreferenceCogs") ; Tag = "Panel:Pref" ; GoToTab = "Pref"}) | Out-Null
    $script:lvStep.Items.Add([PSCustomObject]@{Name = "Language" ; LaMarge = $script:MarginLevel[2] ; IconName = $script:SRPEditorForm.FindResource("IconLanguage") ; Tag = "Panel:Language" ; GoToTab = "Language"}) | Out-Null
    $script:lvStep.Items.Add([PSCustomObject]@{Name = "Modules/Extensions" ; LaMarge = $script:MarginLevel[2] ; IconName = $script:SRPEditorForm.FindResource("IconPrebuiltFunctions") ; Tag = "Panel:Mod/Ext" ; GoToTab = "Mod/Ext"}) | Out-Null
    $script:lvStep.Items.Add([PSCustomObject]@{Name = "Sign" ; LaMarge = $script:MarginLevel[1] ; IconName = $script:SRPEditorForm.FindResource("IconFingerPrint") ; Tag = "Panel:Sign" ; GoToTab = "Sign"}) | Out-Null
    $script:lvStep.Items.Add([PSCustomObject]@{Name = "Build" ; LaMarge = $script:MarginLevel[1] ; IconName = $script:SRPEditorForm.FindResource("IconBuild") ; Tag = "Panel:Build" ; GoToTab = "Build"}) | Out-Null
    $script:lvStep.Items.Add([PSCustomObject]@{Name = "Test" ; LaMarge = $script:MarginLevel[1] ; IconName = $script:SRPEditorForm.FindResource("IconTest") ; Tag = "Panel:Test" ; GoToTab = "Test"}) | Out-Null

    if ($ItemToSelect -ge 0)
    {
        $script:lvStep.SelectedIndex = $ItemToSelect
    }
}


#  8888888b.  888                          d8b                 .d8888b.  888                        888       88888888888                                 888          888                      
#  888   Y88b 888                          Y8P                d88P  Y88b 888                        888           888                                     888          888                      
#  888    888 888                                             888    888 888                        888           888                                     888          888                      
#  888   d88P 888 888  888  .d88b.         888 88888b.        888        888  .d88b.  888  888  .d88888           888      .d88b.  88888b.d88b.  88888b.  888  8888b.  888888  .d88b.  .d8888b  
#  8888888P"  888 888  888 d88P"88b        888 888 "88b       888        888 d88""88b 888  888 d88" 888           888     d8P  Y8b 888 "888 "88b 888 "88b 888     "88b 888    d8P  Y8b 88K      
#  888        888 888  888 888  888 888888 888 888  888       888    888 888 888  888 888  888 888  888           888     88888888 888  888  888 888  888 888 .d888888 888    88888888 "Y8888b. 
#  888        888 Y88b 888 Y88b 888        888 888  888       Y88b  d88P 888 Y88..88P Y88b 888 Y88b 888           888     Y8b.     888  888  888 888 d88P 888 888  888 Y88b.  Y8b.          X88 
#  888        888  "Y88888  "Y88888        888 888  888        "Y8888P"  888  "Y88P"   "Y88888  "Y88888           888      "Y8888  888  888  888 88888P"  888 "Y888888  "Y888  "Y8888   88888P' 
#                               888                                                                                                              888                                            
#                          Y8b d88P                                                                                                              888                                            
#                           "Y88P"                                                                                                               888                                            

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
    $caPlugInDownloadCloudRefreshStatus.ToolTip = $null
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
                $sbPlugInDownloadCloudRefreshStatusAlert.Begin($caPlugInDownloadCloudRefreshStatus)
                #$rttbPlugInCloudTemplateList.Fill = "#FFFF661E"
            }
        }
        catch
        {
            $TmpMsg = ("Failed to download Plug In Templates from the Cloud ({0})." -f $configJson.PlugInCloudTemplateURL)
            LogError $TmpMsg
            $caPlugInDownloadCloudRefreshStatus.ToolTip = $TmpMsg
            $caPlugInDownloadCloudRefreshStatus.Visibility = "Visible"
            $sbPlugInDownloadCloudRefreshStatusAlert.Begin($caPlugInDownloadCloudRefreshStatus)
            #$rttbPlugInCloudTemplateList.Fill = "#FFFF661E"
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


#  8888888888 d8b 888                 .d8888b.           8888888b.  d8b                           888                                     .d88888b.                             
#  888        Y8P 888                d88P  "88b          888  "Y88b Y8P                           888                                    d88P" "Y88b                            
#  888            888                Y88b. d88P          888    888                               888                                    888     888                            
#  8888888    888 888  .d88b.         "Y8888P"           888    888 888 888d888  .d88b.   .d8888b 888888  .d88b.  888d888 888  888       888     888 88888b.   .d88b.  88888b.  
#  888        888 888 d8P  Y8b       .d88P88K.d88P       888    888 888 888P"   d8P  Y8b d88P"    888    d88""88b 888P"   888  888       888     888 888 "88b d8P  Y8b 888 "88b 
#  888        888 888 88888888       888"  Y888P"        888    888 888 888     88888888 888      888    888  888 888     888  888       888     888 888  888 88888888 888  888 
#  888        888 888 Y8b.           Y88b .d8888b        888  .d88P 888 888     Y8b.     Y88b.    Y88b.  Y88..88P 888     Y88b 888       Y88b. .d88P 888 d88P Y8b.     888  888 
#  888        888 888  "Y8888         "Y8888P" Y88b      8888888P"  888 888      "Y8888   "Y8888P  "Y888  "Y88P"  888      "Y88888        "Y88888P"  88888P"   "Y8888  888  888 
#                                                                                                                              888                   888                        
#                                                                                                                         Y8b d88P                   888                        
#                                                                                                                          "Y88P"                    888                        

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
    LogDebug "NOT IMPLEMENTED YET"
    # Goofing around, trying to find a nice visual way to show that there was an issue
    #$rttbPlugInCloudTemplateList.Fill = "#FFFF661E" ## This is a test
    #$caPlugInDownloadCloudRefreshStatus.Visibility = "Hidden" ## This is a test
    #$caPlugInDownloadCloudRefreshStatus.Visibility = "Visible" ## This is a test
    #$sbPlugInDownloadCloudRefreshStatusAlert.Begin($caPlugInDownloadCloudRefreshStatus)
    
})



#  88888888888                   888    888888b.                                             888 d8b      888          888    d8b                   
#      888                       888    888  "88b                                            888 Y8P      888          888    Y8P                   
#      888                       888    888  .88P                                            888          888          888                          
#      888      .d88b.  888  888 888888 8888888K.   .d88b.  888  888       888  888  8888b.  888 888  .d88888  8888b.  888888 888  .d88b.  88888b.  
#      888     d8P  Y8b `Y8bd8P' 888    888  "Y88b d88""88b `Y8bd8P'       888  888     "88b 888 888 d88" 888     "88b 888    888 d88""88b 888 "88b 
#      888     88888888   X88K   888    888    888 888  888   X88K         Y88  88P .d888888 888 888 888  888 .d888888 888    888 888  888 888  888 
#      888     Y8b.     .d8""8b. Y88b.  888   d88P Y88..88P .d8""8b.        Y8bd8P  888  888 888 888 Y88b 888 888  888 Y88b.  888 Y88..88P 888  888 
#      888      "Y8888  888  888  "Y888 8888888P"   "Y88P"  888  888         Y88P   "Y888888 888 888  "Y88888 "Y888888  "Y888 888  "Y88P"  888  888 
#                                                                                                                                                   
#                                                                                                                                                   
#                                                                                                                                                   

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



#  888                        8888888b.  888               888    888                           .d888 d8b          888      888          
#  888                        888   Y88b 888               888    888                          d88P"  Y8P          888      888          
#  888                        888    888 888               888    888                          888                 888      888          
#  888       .d88b.   .d88b.  888   d88P 88888b.  888  888 888888 88888b.  88888b.d88b.        888888 888  .d88b.  888  .d88888 .d8888b  
#  888      d88""88b d88P"88b 8888888P"  888 "88b 888  888 888    888 "88b 888 "888 "88b       888    888 d8P  Y8b 888 d88" 888 88K      
#  888      888  888 888  888 888 T88b   888  888 888  888 888    888  888 888  888  888       888    888 88888888 888 888  888 "Y8888b. 
#  888      Y88..88P Y88b 888 888  T88b  888  888 Y88b 888 Y88b.  888  888 888  888  888       888    888 Y8b.     888 Y88b 888      X88 
#  88888888  "Y88P"   "Y88888 888   T88b 888  888  "Y88888  "Y888 888  888 888  888  888       888    888  "Y8888  888  "Y88888  88888P' 
#                         888                          888                                                                               
#                    Y8b d88P                     Y8b d88P                                                                               
#                     "Y88P"                       "Y88P"                                                                                

# ########
# Build the list of Parameter fields (LogRhythm MDI fields)

<#  Doubt this is still needed
$ComboBoxList = $null

function ParameterFieldArray()
{
    param
    (
        [Switch] $DownloadFromCloud = $False
    )

}
#>

# Update the list of the LogRhythm fields in the right ComboBoxes
Function ParameterFieldUpdate()
{
    param
    (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [System.Windows.Controls.ComboBox[]] $ComboBoxes = $(Throw("-ComboBoxes is required")),
        [Switch] $DownloadFromCloud = $False
    )

    # Start with a fresh Array
    $ParameterFieldListArray = @()

    if ($DownloadFromCloud)
    {
        LogError ("NOT IMPLEMENTED YET ({0})" -f "LanguageFieldUpdate -DownloadFromCloud")
    }

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


#  888                                                                              
#  888                                                                              
#  888                                                                              
#  888       8888b.  88888b.   .d88b.  888  888  8888b.   .d88b.   .d88b.  .d8888b  
#  888          "88b 888 "88b d88P"88b 888  888     "88b d88P"88b d8P  Y8b 88K      
#  888      .d888888 888  888 888  888 888  888 .d888888 888  888 88888888 "Y8888b. 
#  888      888  888 888  888 Y88b 888 Y88b 888 888  888 Y88b 888 Y8b.          X88 
#  88888888 "Y888888 888  888  "Y88888  "Y88888 "Y888888  "Y88888  "Y8888   88888P' 
#                                  888                        888                   
#                             Y8b d88P                   Y8b d88P                   
#                              "Y88P"                     "Y88P"                    

# Update the list of the Languages in the right ComboBoxes

Function LanguageFieldUpdate()
{
    param
    (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [System.Windows.Controls.ComboBox[]] $ComboBoxes = $(Throw("-ComboBoxes is required")),
        [Switch] $DownloadFromCloud = $False
    )

    # Start with a fresh Array
    $LanguagesListArray = @()

    if ($DownloadFromCloud)
    {
        LogError ("NOT IMPLEMENTED YET ({0})" -f "LanguageFieldUpdate -DownloadFromCloud")
    }

    $LanguagesListArray = Get-Content -Raw -Path $LanguagesListJSONLocalFile  | ConvertFrom-Json

    # Look for ComboBoxes that have Tag="NeedList:LRFields"
    # Then assign them $ListView to the ItemsSource property
    # ...
    # Gave up, and did it by sending them by hand in a parameter.
    foreach ($ComboBox in $ComboBoxes)
    {
        $ListView = [System.Windows.Data.ListCollectionView]$LanguagesListArray
        #$ListView.GroupDescriptions.Add((new-object System.Windows.Data.PropertyGroupDescription "Family"))
        $ComboBox.ItemsSource = $ListView
    }
}


#  888      d8b                                                       
#  888      Y8P                                                       
#  888                                                                
#  888      888  .d8888b  .d88b.  88888b.  .d8888b   .d88b.  .d8888b  
#  888      888 d88P"    d8P  Y8b 888 "88b 88K      d8P  Y8b 88K      
#  888      888 888      88888888 888  888 "Y8888b. 88888888 "Y8888b. 
#  888      888 Y88b.    Y8b.     888  888      X88 Y8b.          X88 
#  88888888 888  "Y8888P  "Y8888  888  888  88888P'  "Y8888   88888P' 
#                                                                     
#                                                                     
#                                                                     

# Update the list of the Licenses in the right ComboBoxes

Function LicenseUpdate()
{
    param
    (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [System.Windows.Controls.ComboBox[]] $ComboBoxes = $(Throw("-ComboBoxes is required")),
        [Switch] $DownloadFromCloud = $False
    )

    # Start with a fresh Array
    $LicensesListArray = @()

    if ($DownloadFromCloud)
    {
        LogError ("NOT IMPLEMENTED YET ({0})" -f "LicenseUpdate -DownloadFromCloud")
    }

    $LicensesListArray = Get-Content -Raw -Path $LicensesListJSONLocalFile  | ConvertFrom-Json
    if ($LicensesListArray.DocType -eq "LicenseList")
    {
        # Go through the list of ComboBoxes and assign them $ListView to the ItemsSource property
        foreach ($ComboBox in $ComboBoxes)
        {
            $ListView = [System.Windows.Data.ListCollectionView]$LicensesListArray.LicenseList
            $ComboBox.ItemsSource = $ListView
            $ComboBox.SelectedItem = $ComboBox.Items | where {$_.Name -eq ($LicensesListArray.LicenseList | where {$_.IsSelected -eq $true}).Name}
        }
    }
    else
    {
        LogError ("Cannot load Licenses List from the file ""{0}"". Document of the wrong format." -f $LicensesListJSONLocalFile)
    }

}


#  888     888 8888888                 8888888b.  888                   8888888                888             888      
#  888     888   888                   888   Y88b 888                     888                  888             888      
#  888     888   888                   888    888 888                     888                  888             888      
#  888     888   888         d8b       888   d88P 888 888  888  .d88b.    888   88888b.        888888  8888b.  88888b.  
#  888     888   888         Y8P       8888888P"  888 888  888 d88P"88b   888   888 "88b       888        "88b 888 "88b 
#  888     888   888                   888        888 888  888 888  888   888   888  888       888    .d888888 888  888 
#  Y88b. .d88P   888         d8b       888        888 Y88b 888 Y88b 888   888   888  888       Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888       Y8P       888        888  "Y88888  "Y88888 8888888 888  888        "Y888 "Y888888 88888P"  
#                                                                   888                                                 
#                                                              Y8b d88P                                                 
#                                                               "Y88P"                                                  

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
            BuildNavigationTree -ItemToSelect 0
            $script:LoadedNew.Actions = $true
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
    LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
})

# ########
# UI : PlugIn tab : Import LPI button

$btPlugInImportLPI.Add_Click({
    Get-FileName -Filter "LPI Compiled SmartResponse files (*.lpi)|*.lpi|All files (*.*)| *.*" -Title "Open an LPI Compiled SmartResponse file" -CheckFileExists -ReadOnlyChecked -ShowReadOnly
    LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
})



#  888     888 8888888                        d8888          888    d8b                                  888             888      
#  888     888   888                         d88888          888    Y8P                                  888             888      
#  888     888   888                        d88P888          888                                         888             888      
#  888     888   888         d8b           d88P 888  .d8888b 888888 888  .d88b.  88888b.  .d8888b        888888  8888b.  88888b.  
#  888     888   888         Y8P          d88P  888 d88P"    888    888 d88""88b 888 "88b 88K            888        "88b 888 "88b 
#  888     888   888                     d88P   888 888      888    888 888  888 888  888 "Y8888b.       888    .d888888 888  888 
#  Y88b. .d88P   888         d8b        d8888888888 Y88b.    Y88b.  888 Y88..88P 888  888      X88       Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888       Y8P       d88P     888  "Y8888P  "Y888 888  "Y88P"  888  888  88888P'        "Y888 "Y888888 88888P"  
#                                                                                                                                 
#                                                                                                                                 
#                                                                                                                                 

# ########
# UI : Actions tab
##########################################################

# ########
# Function to Add an action to the differnet lists

Function Add-SRPAction()
{
    param
    (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $ActionNameToAdd,
        [Switch] $DoNotAddToNavigation = $false, # Do not add it to the navigation panel on the left
        [Switch] $DoNotAddToActionsOrderList = $false,
        [Switch] $DoNotAddToMemoryObjectActionsList = $false,
        [Switch] $DoNotAddDefaultParameters = $false, # That is the default parameter that is coming with/from the Language
        [Switch] $DoNotCreateGUID = $false
    )

    $ReturnValue = $false
    try
    {
        if (-not [string]::IsNullOrEmpty($ActionNameToAdd))
        {
            $GoodToAdd = $true
            foreach ($Action in $script:ProjectMemoryObject.Actions)
            {
                if ($Action.Name -eq $ActionNameToAdd)
                {
                    #$GoodToAdd = $false
                }
            }
            if ($GoodToAdd)
            {
                # ########
                # Create the Action

                # With or without GUID
                if ($DoNotCreateGUID) # Not sure why on earth you would want that. But hey, not here to judge...
                {
                   #$ActionToAdd = [SRPAction]@{ Name = "$ActionNameToAdd"}
                    $ActionToAdd = [SRPAction]::New($ActionNameToAdd)
                }
                else
                {
                   $ActionToAdd = [SRPAction]@{ Name = "$ActionNameToAdd" ; GUID = New-Guid}
                    $GUID = New-Guid
                   # $ActionToAdd = [SRPAction]::New($ActionNameToAdd, $GUID)
                }

                # With or without the default parameters, based on the selected language
                if (-Not $DoNotAddDefaultParameters) # Not sure why on earth you would want that. But hey, not here to judge...
                {
                    foreach($Parameter in $script:ProjectMemoryObject.Language.DefaultParameters)
                    {
                        if (-Not [string]::IsNullOrEmpty($Parameter.MapToField))
                        {
                            $FieldNameToAdd = ($cbActionXFieldMappingField.Items | where {$_.Code -eq $Parameter.MapToField}).Name
                        }
                        else
                        {
                            $FieldNameToAdd = ""
                        }
                        $ActionToAdd.Parameters.Add([SRPActionParameter]@{ Type = $Parameter.Type ;
                                                                           Name = $Parameter.Name ;
                                                                           FieldCode = $Parameter.MapToField ;
                                                                           FieldName = $FieldNameToAdd ;
                                                                           ConstantValue = $Parameter.ConstantValue ;
                                                                           Switch = $Parameter.Switch ;
                                                                           ValidationRule = $Parameter.ValidationRule 
                                                                         })
                    }
                    $ActionToAdd.Command = $script:ProjectMemoryObject.Language.Command
                }

                # Insert the Action in the Memory Object
                if (-Not $DoNotAddToMemoryObjectActionsList)
                {
                    $script:ProjectMemoryObject.Actions.Add($ActionToAdd)
                }

                # Insert the Action in the Order grid
                if (-Not $DoNotAddToActionsOrderList)
                {
                    $dgActionsOrder.Items.Add($ActionToAdd)
                }

                # Insert the Action into the navigation panel (lvStep)
                if (-Not $DoNotAddToNavigation)
                {
                    $WhereToInsert = 2 # Right after the "Actions" item
                    for ($i = 0 ; $i -lt $lvStep.Items.Count ; $i++)
                    {
                        if ($lvStep.Items.Item($i).Name -eq "Output") # Right before the "Output" item
                        {
                            $WhereToInsert = $i
                            Break
                        }
                    }
                    $lvStep.Items.Insert($WhereToInsert, [PSCustomObject]@{Name = ("Action: {0}" -f $ActionToAdd.Name) ; GUID = $ActionToAdd.GUID ; LaMarge = $script:MarginLevel[2] ; IconName = $SRPEditorForm.FindResource("IconRocket") ; Tag = "Panel:Action_X" ; GoToTab = "Action_X"}) | Out-Null
                }
            }
            $ReturnValue = $true
        } # if (-not [string]::IsNullOrEmpty($ActionNameToAdd))
        else
        {
            LogInformation "Not possible to add a new Action with an empty name. Get your act together mate..."
        }
    }
    catch
    {
        LogError ("Error adding Action ""{0}"". Exception: {1}" -f $ActionNameToAdd, $_.Exception.Message)
    }
    return $ReturnValue
}

# ########
# Function to Update an action's name to the different lists

Function Update-SRPActionName()
{
    param
    (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [guid] $ActionGUID,
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $ActionNameToModify,
        [Switch] $DoNotModifyInNavigation = $false, # Do not modify it to the navigation panel on the left
        [Switch] $DoNotModifyInActionsOrderList = $false,
        [Switch] $DoNotModifyInMemoryObjectActionsList = $false
    )

    $ReturnValue = $false
    try
    {
        if (-not [string]::IsNullOrEmpty($ActionNameToModify) -and $ActionGUID -ne $null)
        {
            $ActionNameToModify = $ActionNameToModify.Trim()
            $GoodToModify = $true
<#
            foreach ($Action in $script:ProjectMemoryObject.Actions)
            {
                if ($Action.Name -eq $ActionNameToModify)
                {
                    $GoodToAdd = $false
                }
            }
#>
            if ($GoodToModify)
            {
                # Update the Action in the Memory Object
                if (-Not $DoNotModifyInMemoryObjectActionsList)
                {
                    LogDebug "ModifyInMemoryObjectActionsList"
                    ($script:ProjectMemoryObject.Actions | where {$_.GUID -eq $ActionGUID}).Name = $ActionNameToModify
                }

                # Update the Action in the Order grid
                if (-Not $DoNotModifyInActionsOrderList)
                {
                    LogDebug "ModifyInActionsOrderList"
                    if ($script:dgActionsOrder.SelectedIndex -ge 0)
                    {
                        $script:dgActionsOrder.SelectedItem.Name = $ActionNameToModify
                        $script:dgActionsOrder.Items.Refresh()
                    }
                }

                # Update the Action into the navigation panel (lvStep)
                if (-Not $DoNotModifyInNavigation)
                {
                    LogDebug "ModifyInNavigation"
                    ($script:lvStep.Items | where {$_.GUID -eq $ActionGUID}).Name = ("Action: {0}" -f $ActionNameToModify)
                    $script:lvStep.Items.Refresh()
                }
            }
            $ReturnValue = $true
        } # if (-not [string]::IsNullOrEmpty($ActionNameToAdd))
        else
        {
            LogInformation "Not possible to update the Action to an empty name. Get your act together mate..."
        }
    }
    catch
    {
        LogError ("Error updating Action ""{0}""." -f $ActionNameToModify)
    }
    return $ReturnValue
}

# ########
# UI : Actions tab : Adding an action to the list

$btActionsNameAdd.Add_Click({
    if(-Not [string]::IsNullOrEmpty($tbActionsName.Text.Trim()))
    {
        Add-SRPAction -ActionNameToAdd $tbActionsName.Text.Trim()
    }
})

# ########
# UI : Actions tab : Adding an action to the list

$btActionsNameRefresh.Add_Click({
    $GUIDToUpdate = $dgActionsOrder.SelectedItem.GUID
    if ($GUIDToUpdate -ne $null)
    {
        Update-SRPActionName -ActionGUID $GUIDToUpdate -ActionNameToModify $tbActionsName.Text
    }
})

# ########
# UI : Actions tab : Import from Template drop down list

$cbActionsImportFromTemplate.Add_SelectionChanged({
    LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    #$cbActionsImportFromTemplate
})

# ########
# UI : Actions tab : Deleting an action from the list

$btActionsDelete.Add_Click({
    $ActionToDeleteIndex = $dgActionsOrder.SelectedIndex
    $GUIDToDelete = $dgActionsOrder.SelectedItem.GUID
    if ($GUIDToDelete -ne $null)
    {
        # Remove in the Action Order Data Grid
        $dgActionsOrder.Items.RemoveAt($ActionToDeleteIndex)
        # Remove from the Memory Object
        $script:ProjectMemoryObject.Actions.RemoveAt($ActionToDeleteIndex)
        # Remove from the Navigation panel
        $ActionIndex = $script:lvStep.Items.IndexOf(($script:lvStep.Items | where {$_.Name -eq "Actions"}))
        $lvStep.Items.RemoveAt($ActionToDeleteIndex + $ActionIndex + 1)

        # In the rder Data Grid, pick the Action just above the one just deleted
        if ($ActionToDeleteIndex -gt 0)
        {
            $dgActionsOrder.SelectedIndex = $ActionToDeleteIndex - 1
        }
        else
        {
            $dgActionsOrder.SelectedIndex = 0
        }
    }
})

# ########
# UI : Actions tab : Moving Actions in the different lists

Function MoveActionItem()
{
    param
    (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [int] $FromIndex,
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [int] $ToIndex,
        [Switch] $DoNotMoveInNavigation = $false, # Do not modify it to the navigation panel on the left
        [Switch] $DoNotMoveInActionsOrderList = $false,
        [Switch] $DoNotMoveInMemoryObjectActionsList = $false
    )
    # Update the Action in the Order grid
    if (-Not $DoNotMoveInActionsOrderList)
    {
        #LogDebug "ModifyInActionsOrderList"
        if ($dgActionsOrder.Items.Count -gt 1)
        {
            if (($FromIndex -ge 0) -And ($FromIndex -lt $dgActionsOrder.Items.Count) `
            -And ($ToIndex -ge 0) -And ($ToIndex -lt $dgActionsOrder.Items.Count))
            {
                $ItemToMove = $dgActionsOrder.Items[$FromIndex]
                $dgActionsOrder.Items.RemoveAt($FromIndex)
                $dgActionsOrder.Items.Insert($ToIndex,$ItemToMove)
                $dgActionsOrder.SelectedItem = $dgActionsOrder.Items[$ToIndex]
            }
        }
    }

    # Update the Action into the navigation panel (lvStep)
    if (-Not $DoNotMoveInNavigation)
    {
        #LogDebug "ModifyInNavigation"
        $ActionIndex = $script:lvStep.Items.IndexOf(($script:lvStep.Items | where {$_.Name -eq "Actions"}))
        $OutputIndex = $script:lvStep.Items.IndexOf(($script:lvStep.Items | where {$_.Name -eq "Output"}))
        $NumberOfActions = ($OutputIndex - $ActionIndex - 1)
        if ($NumberOfActions -gt 1)
        {
            if (($FromIndex -ge 0) -And ($FromIndex -lt $NumberOfActions) `
            -And ($ToIndex -ge 0) -And ($ToIndex -lt $NumberOfActions))
            {
                $ItemToMove = $lvStep.Items[$FromIndex + $ActionIndex + 1]
                $lvStep.Items.RemoveAt($FromIndex + $ActionIndex + 1)
                $lvStep.Items.Insert($ToIndex + $ActionIndex + 1,$ItemToMove)
                $script:lvStep.Items.Refresh()
            }
        }
    }

    # Update the Action in the Memory Object
    if (-Not $DoNotMoveInMemoryObjectActionsList)
    {
        #LogDebug "ModifyInMemoryObjectActionsList"
        if ($script:ProjectMemoryObject.Actions.Count -gt 1)
        {
            if (($FromIndex -ge 0) -And ($FromIndex -lt $script:ProjectMemoryObject.Actions.Count) `
            -And ($ToIndex -ge 0) -And ($ToIndex -lt $script:ProjectMemoryObject.Actions.Count))
            {
                
                $ItemToMove = $script:ProjectMemoryObject.Actions[$FromIndex]
                $script:ProjectMemoryObject.Actions.RemoveAt($FromIndex) 
                $script:ProjectMemoryObject.Actions.Insert($ToIndex,$ItemToMove) 
            }
        }
    }
}

# ########
# UI : Actions tab : Move action to the top of the list

$btActionsOrderTop.Add_Click({
    MoveActionItem -FromIndex $dgActionsOrder.SelectedIndex -ToIndex 0
})

# ########
# UI : Actions tab : Move action one level up in the list

$btActionsOrderUp.Add_Click({
    MoveActionItem -FromIndex $dgActionsOrder.SelectedIndex -ToIndex ($dgActionsOrder.SelectedIndex - 1)
})

# ########
# UI : Actions tab : Move action one level down in the list

$btActionsOrderDown.Add_Click({
    MoveActionItem -FromIndex $dgActionsOrder.SelectedIndex -ToIndex ($dgActionsOrder.SelectedIndex + 1)
})

# ########
# UI : Actions tab : Move action to the bottom of the list

$btActionsOrderBottom.Add_Click({
    MoveActionItem -FromIndex $dgActionsOrder.SelectedIndex -ToIndex ($dgActionsOrder.Items.Count - 1)
})

# ########
# UI : Actions tab : Move action to the bottom of the list

$dgActionsOrder.Add_SelectionChanged({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $tbActionsName.Text = $dgActionsOrder.SelectedItem.Name
})



#
#  888     888 8888888                        d8888          888    d8b                   Y88b   d88P 
#  888     888   888                         d88888          888    Y8P                    Y88b d88P  
#  888     888   888                        d88P888          888                            Y88o88P   
#  888     888   888         d8b           d88P 888  .d8888b 888888 888  .d88b.  88888b.     Y888P    
#  888     888   888         Y8P          d88P  888 d88P"    888    888 d88""88b 888 "88b    d888b    
#  888     888   888                     d88P   888 888      888    888 888  888 888  888   d88888b   
#  Y88b. .d88P   888         d8b        d8888888888 Y88b.    Y88b.  888 Y88..88P 888  888  d88P Y88b  
#   "Y88888P"  8888888       Y8P       d88P     888  "Y8888P  "Y888 888  "Y88P"  888  888 d88P   Y88b 
#                                                                                                     
#                                                                                                     
#                                                                                               

# ########
# UI : ActionX tab
##########################################################



<# No need for this, as the change, if any, is only done when clicking on the Update button next to it.
# ########
# UI : ActionX tab : Field mapping drop down

$cbActionXFieldMappingField.Add_SelectionChanged({
    #LogDebug ("cbActionXFieldMappingField::SelectionChanged // Index: {0} / Value: ""{1}"" / Entry: ""{2}""" -f $cbActionXFieldMappingField.SelectedIndex, $cbActionXFieldMappingField.SelectedValue, $cbActionXFieldMappingField.SelectedValue.Name)
    LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
})
#>

# ########
# UI : ActionX tab : Command field

$tbActionXCommand.Add_TextChanged({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $CurrentAction = ($script:ProjectMemoryObject.Actions | where {$_.GUID -eq $script:lvStep.SelectedItem.GUID})
    $CurrentAction.Command = $tbActionXCommand.Text.Trim()
    #$script:ProjectMemoryObject.Output.Folder = $tbOutputFolder.Text.Trim()
})

# ########
# UI : ActionX tab : New item selected in the Order DataGrid

$dgActionXOrder.Add_SelectionChanged({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $cbActionXParamType.SelectedItem = $cbActionXParamType.Items | where {$_.Content -eq $dgActionXOrder.SelectedItem.Type}
    $tbActionXParamName.Text = $dgActionXOrder.SelectedItem.Name
    $cbActionXFieldMappingField.SelectedItem = $cbActionXFieldMappingField.Items | where {$_.Code -eq $dgActionXOrder.SelectedItem.FieldCode}
    $tbActionXFieldMappingValue.Text = $dgActionXOrder.SelectedItem.ConstantValue
    $cbActionXFieldValidation.SelectedItem = $cbActionXFieldValidation.Items | where {$_.Content -eq $dgActionXOrder.SelectedItem.ValidationRule}

    $tbActionXFieldSwitch.Text = $dgActionXOrder.SelectedItem.Switch


    #$tbActionsName.Text = $dgActionXOrder.SelectedItem.Name
})

# ########
# Function to Add an action's parameter to the list

Function Add-SRPActionParameter()
{
    param
    (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [string] $ParameterNameToAdd,
        [Switch] $DoNotAddFieldMapping = $false,
        [Switch] $DoNotAddConstantValue = $false,
        [Switch] $DoNotAddSwitch = $false,
        [Switch] $DoNotAddValidationRule = $false,
        [Switch] $DoNotAddToParametersOrderList = $false,
        [Switch] $DoNotAddToMemoryObjectActionsParametersList = $false
    )

    $ReturnValue = $false
    try
    {
        if (-not [string]::IsNullOrEmpty($ParameterNameToAdd))
        {
            $GoodToAdd = $true
            $CurrentAction=$script:ProjectMemoryObject.Actions | where {$_.GUID -eq $lvStep.Items[$lvStep.SelectedIndex].GUID}
            foreach ($Parameter in $CurrentAction.Paramters)
            {
                if ($Parameter.Name -eq $ParameterNameToAdd)
                {
                    $GoodToAdd = $false
                }
            }
            if ($GoodToAdd)
            {
                # ########
                # Create the Parameter

                $ParameterToAdd = [SRPActionParameter]::New($ParameterNameToAdd, $cbActionXParamType.SelectedItem.Content)

                # With or without Field Mapping
                if ($DoNotAddFieldMapping -and $cbActionXFieldMappingField.SelectedIndex -ge 0)
                {
                   $ParameterToAdd.FieldCode = $cbActionXFieldMappingField.SelectedItem.Code
                   $ParameterToAdd.FieldName = $cbActionXFieldMappingField.SelectedItem.Name
                }

                # With or without Constant Value
                if (-Not $DoNotAddConstantValue)
                {
                   $ParameterToAdd.ConstantValue = $tbActionXFieldMappingValue.Text.Trim()
                }

                # With or without Switch
                if (-Not $DoNotAddSwitch)
                {
                   $ParameterToAdd.Switch = $tbActionXFieldSwitch.Text.Trim()
                }

                # With or without Validation Rule
                if ($DoNotAddValidationRule -and $cbActionXFieldValidation.SelectedIndex -ge 0)
                {
                   $ParameterToAdd.FieldCode = $cbActionXFieldMappingField.SelectedItem.Code
                   $ParameterToAdd.FieldName = $cbActionXFieldMappingField.SelectedItem.Name
                }
                
                # Finally, add to the Memory object
                if (-Not $DoNotAddToMemoryObjectActionsParametersList)
                {
                    $CurrentAction.Parameters.Add($ParameterToAdd)
                }

                # And add to the Order list
                if (-Not $DoNotAddToParametersOrderList)
                {
                    $dgActionXOrder.Items.Add($ParameterToAdd)
                    $CurrentAction.Parameters.Add($ParameterToAdd)
                }
            }
            $ReturnValue = $true
        } # if (-not [string]::IsNullOrEmpty($ParameterNameToAdd))
        else
        {
            LogInformation "Not possible to add a new Parameter with an empty name."
        }
    }
    catch
    {
        LogError ("Error adding Parameter ""{0}"". Exception: {1}" -f $ParameterNameToAdd, $_.Exception.Message)
    }
    return $ReturnValue
}

# ########
# UI : ActionX tab : Add the Parameter to the list

$btActionXParamAdd.Add_Click({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    if(-Not [string]::IsNullOrEmpty($tbActionXParamName.Text.Trim()))
    {
        Add-SRPActionParameter -ParameterNameToAdd $tbActionXParamName.Text.Trim()
    }
    
})

# ########
# UI : ActionX tab : Update the Parameter's Name

$btActionXParamRefresh.Add_Click({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    if(-Not [string]::IsNullOrEmpty($tbActionXParamName.Text.Trim()) -and $cbActionXParamType.SelectedIndex -ge 0 -and $dgActionXOrder.SelectedIndex -ge 0)
    {
        # Find current Action and Parameter in the Memory object
        $CurrentAction=$script:ProjectMemoryObject.Actions | where {$_.GUID -eq $lvStep.Items[$lvStep.SelectedIndex].GUID}
        $CurrentParameter=$CurrentAction.Parameters | where {$_.Name -eq $dgActionXOrder.SelectedItem.Name}
        
        # Update the Memory Object
        $CurrentParameter.Name = $tbActionXParamName.Text.Trim()
        $CurrentParameter.Type = $cbActionXParamType.SelectedItem.Content

        # Update the Order data grid
        $dgActionXOrder.SelectedItem.Name = $tbActionXParamName.Text.Trim()
        $dgActionXOrder.SelectedItem.Type = $cbActionXParamType.SelectedItem.Content
        $dgActionXOrder.Items.Refresh()
    }
})

# ########
# UI : ActionX tab : Update the Parameter's Field Mapping

$btActionXFieldMapFieldRefresh.Add_Click({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    if($cbActionXFieldMappingField.SelectedIndex -ge 0 -and $dgActionXOrder.SelectedIndex -ge 0)
    {
        # Find current Action and Parameter in the Memory object
        $CurrentAction=$script:ProjectMemoryObject.Actions | where {$_.GUID -eq $lvStep.Items[$lvStep.SelectedIndex].GUID}
        $CurrentParameter=$CurrentAction.Parameters | where {$_.Name -eq $dgActionXOrder.SelectedItem.Name}
        
        # Update the Memory Object
        $CurrentParameter.FieldCode = $cbActionXFieldMappingField.SelectedItem.Code
        $CurrentParameter.FieldName = $cbActionXFieldMappingField.SelectedItem.Name

        # Update the Order data grid
        $dgActionXOrder.SelectedItem.FieldCode = $cbActionXFieldMappingField.SelectedItem.Code
        $dgActionXOrder.SelectedItem.FieldName = $cbActionXFieldMappingField.SelectedItem.Name
        $dgActionXOrder.Items.Refresh()
    }
})

# ########
# UI : ActionX tab : Update the Parameter's Constant Value

$btActionXFieldMapValueRefresh.Add_Click({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    if($dgActionXOrder.SelectedIndex -ge 0)
    {
        # Find current Action and Parameter in the Memory object
        $CurrentAction=$script:ProjectMemoryObject.Actions | where {$_.GUID -eq $lvStep.Items[$lvStep.SelectedIndex].GUID}
        $CurrentParameter=$CurrentAction.Parameters | where {$_.Name -eq $dgActionXOrder.SelectedItem.Name}
        
        # Update the Memory Object
        $CurrentParameter.ConstantValue = $tbActionXFieldMappingValue.Text.Trim()

        # Update the Order data grid
        $dgActionXOrder.SelectedItem.ConstantValue = $tbActionXFieldMappingValue.Text.Trim()
        $dgActionXOrder.Items.Refresh()
    }
})

# ########
# UI : ActionX tab : Update the Parameter's Switch

$btActionXFieldSwitchRefresh.Add_Click({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    if($dgActionXOrder.SelectedIndex -ge 0)
    {
        # Find current Action and Parameter in the Memory object
        $CurrentAction=$script:ProjectMemoryObject.Actions | where {$_.GUID -eq $lvStep.Items[$lvStep.SelectedIndex].GUID}
        $CurrentParameter=$CurrentAction.Parameters | where {$_.Name -eq $dgActionXOrder.SelectedItem.Name}
        
        # Update the Memory Object
        $CurrentParameter.Switch = $tbActionXFieldSwitch.Text.Trim()

        # Update the Order data grid
        $dgActionXOrder.SelectedItem.Switch = $tbActionXFieldSwitch.Text.Trim()
        $dgActionXOrder.Items.Refresh()
    }})

# ########
# UI : ActionX tab : Update the Parameter's Validation Rule

$btActionXFieldValidationRefresh.Add_Click({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    if($cbActionXFieldValidation.SelectedIndex -ge 0 -and $dgActionXOrder.SelectedIndex -ge 0)
    {
        # Find current Action and Parameter in the Memory object
        $CurrentAction=$script:ProjectMemoryObject.Actions | where {$_.GUID -eq $lvStep.Items[$lvStep.SelectedIndex].GUID}
        $CurrentParameter=$CurrentAction.Parameters | where {$_.Name -eq $dgActionXOrder.SelectedItem.Name}
        
        # Update the Memory Object
        $CurrentParameter.ValidationRule = $cbActionXFieldValidation.SelectedItem.Content

        # Update the Order data grid
        $dgActionXOrder.SelectedItem.ValidationRule = $cbActionXFieldValidation.SelectedItem.Content
        $dgActionXOrder.Items.Refresh()
    }
})


# ########
# UI : ActionX tab : Moving Parameters in the list

Function MoveParameterItem()
{
    param
    (
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [int] $FromIndex,
		[Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [int] $ToIndex,
        [Switch] $DoNotMoveInParametersOrderList = $false,
        [Switch] $DoNotMoveInMemoryObjectActionsParametersList = $false
    )
    # Update the Parameter in the Order grid
    if (-Not $DoNotMoveInParametersOrderList)
    {
        if ($dgActionXOrder.Items.Count -gt 1)
        {
            if (($FromIndex -ge 0) -And ($FromIndex -lt $dgActionXOrder.Items.Count) `
            -And ($ToIndex -ge 0) -And ($ToIndex -lt $dgActionXOrder.Items.Count))
            {
                $ItemToMove = $dgActionXOrder.Items[$FromIndex]
                $dgActionXOrder.Items.RemoveAt($FromIndex)
                $dgActionXOrder.Items.Insert($ToIndex,$ItemToMove)
                $dgActionXOrder.SelectedItem = $dgActionXOrder.Items[$ToIndex]
            }
        }
    }

    # Update the Parameter in the Memory Object
    if (-Not $DoNotMoveInMemoryObjectActionsParametersList)
    {
        # Find current Action and Parameter in the Memory object
        $CurrentAction=$script:ProjectMemoryObject.Actions | where {$_.GUID -eq $lvStep.Items[$lvStep.SelectedIndex].GUID}

        if ($script:ProjectMemoryObject.Actions.Count -gt 1)
        {
            if (($FromIndex -ge 0) -And ($FromIndex -lt $CurrentAction.Parameters.Count) `
            -And ($ToIndex -ge 0) -And ($ToIndex -lt $CurrentAction.Parameters.Count))
            {
                
                $ItemToMove = $CurrentAction.Parameters[$FromIndex]
                $CurrentAction.Parameters.RemoveAt($FromIndex) 
                $CurrentAction.Parameters.Insert($ToIndex,$ItemToMove) 
            }
        }
    }
}
# ########
# UI : ActionX tab : Move Parameter to the top of the list

$btActionXOrderTop.Add_Click({
    MoveParameterItem -FromIndex $dgActionXOrder.SelectedIndex -ToIndex 0
})

# ########
# UI : ActionX tab : Move Parameter one level up in the list

$btActionXOrderUp.Add_Click({
    MoveParameterItem -FromIndex $dgActionXOrder.SelectedIndex -ToIndex ($dgActionXOrder.SelectedIndex - 1)
})

# ########
# UI : ActionX tab : Move Parameter one level down in the list

$btActionXOrderDown.Add_Click({
    MoveParameterItem -FromIndex $dgActionXOrder.SelectedIndex -ToIndex ($dgActionXOrder.SelectedIndex + 1)
})

# ########
# UI : ActionX tab : Move Parameter to the bottom of the list

$btActionXOrderBottom.Add_Click({
    MoveParameterItem -FromIndex $dgActionXOrder.SelectedIndex -ToIndex ($dgActionXOrder.Items.Count - 1)
})

# ########
# UI : ActionX tab : Deleting an Parameter from the list

$btActionXDelete.Add_Click({
    # Find current Action in the Memory object
    $CurrentAction=$script:ProjectMemoryObject.Actions | where {$_.GUID -eq $lvStep.Items[$lvStep.SelectedIndex].GUID}

    $ParameterToDeleteIndex = $dgActionXOrder.SelectedIndex
    if ($ParameterToDeleteIndex -ge 0)
    {
        # Remove in the Parameter Order Data Grid
        $dgActionXOrder.Items.RemoveAt($ParameterToDeleteIndex)
        # Remove from the Memory Object
        $CurrentAction.Parameters.RemoveAt($ParameterToDeleteIndex)

        # In the Order Data Grid, pick the Parameter just above the one just deleted
        if ($ParameterToDeleteIndex -gt 0)
        {
            $dgActionXOrder.SelectedIndex = $ParameterToDeleteIndex - 1
        }
        else
        {
            $dgActionXOrder.SelectedIndex = 0
        }
    }
})



#  888     888 8888888                  .d88888b.           888                      888          888             888      
#  888     888   888                   d88P" "Y88b          888                      888          888             888      
#  888     888   888                   888     888          888                      888          888             888      
#  888     888   888         d8b       888     888 888  888 888888 88888b.  888  888 888888       888888  8888b.  88888b.  
#  888     888   888         Y8P       888     888 888  888 888    888 "88b 888  888 888          888        "88b 888 "88b 
#  888     888   888                   888     888 888  888 888    888  888 888  888 888          888    .d888888 888  888 
#  Y88b. .d88P   888         d8b       Y88b. .d88P Y88b 888 Y88b.  888 d88P Y88b 888 Y88b.        Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888       Y8P        "Y88888P"   "Y88888  "Y888 88888P"   "Y88888  "Y888        "Y888 "Y888888 88888P"  
#                                                                  888                                                     
#                                                                  888                                                     
#                                                                  888                                                     

# ########
# UI : Output tab
##########################################################

# ########
# UI : Output tab : Output folder

$tbOutputFolder.Add_TextChanged({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $script:ProjectMemoryObject.Output.Folder = $tbOutputFolder.Text.Trim()
})


# ########
# UI : Output tab : Output folder Browse button

$btOutputFolderBrowse.Add_Click({
    LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
})


# ########
# UI : Output tab : Output option

$rbOutputFolderOptionOnePerVersion.Add_Checked({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $script:ProjectMemoryObject.Output.OneFolderPerVersion = $rbOutputFolderOptionOnePerVersion.IsChecked
})

$rbOutputFolderOptionOnePerVersion.Add_UnChecked({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $script:ProjectMemoryObject.Output.OneFolderPerVersion = $rbOutputFolderOptionOnePerVersion.IsChecked
    
})


#  888     888 8888888                 8888888b.                    .d888                                                            888             888      
#  888     888   888                   888   Y88b                  d88P"                                                             888             888      
#  888     888   888                   888    888                  888                                                               888             888      
#  888     888   888         d8b       888   d88P 888d888  .d88b.  888888  .d88b.  888d888  .d88b.  88888b.   .d8888b  .d88b.        888888  8888b.  88888b.  
#  888     888   888         Y8P       8888888P"  888P"   d8P  Y8b 888    d8P  Y8b 888P"   d8P  Y8b 888 "88b d88P"    d8P  Y8b       888        "88b 888 "88b 
#  888     888   888                   888        888     88888888 888    88888888 888     88888888 888  888 888      88888888       888    .d888888 888  888 
#  Y88b. .d88P   888         d8b       888        888     Y8b.     888    Y8b.     888     Y8b.     888  888 Y88b.    Y8b.           Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888       Y8P       888        888      "Y8888  888     "Y8888  888      "Y8888  888  888  "Y8888P  "Y8888         "Y888 "Y888888 88888P"  
#                                                                                                                                                             
#                                                                                                                                                             
#                                                                                                                                                             

# ########
# UI : Preference tab
##########################################################

# ########
# UI : Preference tab : License drop down

$cbPreferencesLicenseFile.Add_SelectionChanged({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $script:ProjectMemoryObject.Preferences.LicenseFile = $cbPreferencesLicenseFile.SelectedItem
})

# ########
# UI : Preference tab : Script File Output option

$rbPreferencesScriptFileOptionSingleFile.Add_Checked({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $script:ProjectMemoryObject.Preferences.GenerateSingleScriptFile = $rbPreferencesScriptFileOptionSingleFile.IsChecked
})

$rbPreferencesScriptFileOptionDualFile.Add_UnChecked({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $script:ProjectMemoryObject.Preferences.GenerateSingleScriptFile = $rbPreferencesScriptFileOptionSingleFile.IsChecked
    
})

# ########
# UI : Preference tab : LPI File Output option

$rbPreferencesPlugInLPIFileOptionGenerateLPI.Add_Checked({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $script:ProjectMemoryObject.Preferences.GenerateLPIAtBuildTime = $rbPreferencesPlugInLPIFileOptionGenerateLPI.IsChecked
})

$rbPreferencesPlugInLPIFileOptionDoNotGenerate.Add_UnChecked({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $script:ProjectMemoryObject.Preferences.GenerateLPIAtBuildTime = $rbPreferencesPlugInLPIFileOptionGenerateLPI.IsChecked
    
})


#  888     888 8888888                 8888888b.                    .d888                                                                            d88P       888                                                                           888             888      
#  888     888   888                   888   Y88b                  d88P"                                                                            d88P        888                                                                           888             888      
#  888     888   888                   888    888                  888                                                                             d88P         888                                                                           888             888      
#  888     888   888         d8b       888   d88P 888d888  .d88b.  888888  .d88b.  888d888  .d88b.  88888b.   .d8888b  .d88b.  .d8888b            d88P          888       8888b.  88888b.   .d88b.  888  888  8888b.   .d88b.   .d88b.        888888  8888b.  88888b.  
#  888     888   888         Y8P       8888888P"  888P"   d8P  Y8b 888    d8P  Y8b 888P"   d8P  Y8b 888 "88b d88P"    d8P  Y8b 88K               d88P           888          "88b 888 "88b d88P"88b 888  888     "88b d88P"88b d8P  Y8b       888        "88b 888 "88b 
#  888     888   888                   888        888     88888888 888    88888888 888     88888888 888  888 888      88888888 "Y8888b.         d88P            888      .d888888 888  888 888  888 888  888 .d888888 888  888 88888888       888    .d888888 888  888 
#  Y88b. .d88P   888         d8b       888        888     Y8b.     888    Y8b.     888     Y8b.     888  888 Y88b.    Y8b.          X88        d88P             888      888  888 888  888 Y88b 888 Y88b 888 888  888 Y88b 888 Y8b.           Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888       Y8P       888        888      "Y8888  888     "Y8888  888      "Y8888  888  888  "Y8888P  "Y8888   88888P'       d88P              88888888 "Y888888 888  888  "Y88888  "Y88888 "Y888888  "Y88888  "Y8888         "Y888 "Y888888 88888P"  
#                                                                                                                                                                                               888                        888                                         
#                                                                                                                                                                                          Y8b d88P                   Y8b d88P                                         
#                                                                                                                                                                                           "Y88P"                     "Y88P"                                          

# ########
# UI : Preference / Language tab
##########################################################

# ########
# UI : Preference / Language tab : Language drop down

$cbLanguageLanguageSelection.Add_SelectionChanged({
    #LogError ("NOT IMPLEMENTED YET ({0})" -f $_.OriginalSource.Name)
    $script:ProjectMemoryObject.Language = $cbLanguageLanguageSelection.SelectedItem
})



#  888     888 8888888                 8888888b.                    .d888                                                                   d88P       888b     d888               888          888                          d88P 8888888888          888                               d8b                                  888             888      
#  888     888   888                   888   Y88b                  d88P"                                                                   d88P        8888b   d8888               888          888                         d88P  888                 888                               Y8P                                  888             888      
#  888     888   888                   888    888                  888                                                                    d88P         88888b.d88888               888          888                        d88P   888                 888                                                                    888             888      
#  888     888   888         d8b       888   d88P 888d888  .d88b.  888888  .d88b.  888d888  .d88b.  88888b.   .d8888b  .d88b.            d88P          888Y88888P888  .d88b.   .d88888 888  888 888  .d88b.  .d8888b      d88P    8888888    888  888 888888  .d88b.  88888b.  .d8888b  888  .d88b.  88888b.  .d8888b        888888  8888b.  88888b.  
#  888     888   888         Y8P       8888888P"  888P"   d8P  Y8b 888    d8P  Y8b 888P"   d8P  Y8b 888 "88b d88P"    d8P  Y8b          d88P           888 Y888P 888 d88""88b d88" 888 888  888 888 d8P  Y8b 88K         d88P     888        `Y8bd8P' 888    d8P  Y8b 888 "88b 88K      888 d88""88b 888 "88b 88K            888        "88b 888 "88b 
#  888     888   888                   888        888     88888888 888    88888888 888     88888888 888  888 888      88888888         d88P            888  Y8P  888 888  888 888  888 888  888 888 88888888 "Y8888b.   d88P      888          X88K   888    88888888 888  888 "Y8888b. 888 888  888 888  888 "Y8888b.       888    .d888888 888  888 
#  Y88b. .d88P   888         d8b       888        888     Y8b.     888    Y8b.     888     Y8b.     888  888 Y88b.    Y8b.            d88P             888   "   888 Y88..88P Y88b 888 Y88b 888 888 Y8b.          X88  d88P       888        .d8""8b. Y88b.  Y8b.     888  888      X88 888 Y88..88P 888  888      X88       Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888       Y8P       888        888      "Y8888  888     "Y8888  888      "Y8888  888  888  "Y8888P  "Y8888        d88P              888       888  "Y88P"   "Y88888  "Y88888 888  "Y8888   88888P' d88P        8888888888 888  888  "Y888  "Y8888  888  888  88888P' 888  "Y88P"  888  888  88888P'        "Y888 "Y888888 88888P"  
#                                                                                                                                                                                                                                                                                                                                                     
#                                                                                                                                                                                                                                                                                                                                                     
#                                                                                                                                                                                                                                                                                                                                                     

# ########
# UI : Preference / Modules/Extensions tab
##########################################################



#  888     888 8888888                  .d8888b.  d8b                         888             888      
#  888     888   888                   d88P  Y88b Y8P                         888             888      
#  888     888   888                   Y88b.                                  888             888      
#  888     888   888         d8b        "Y888b.   888  .d88b.  88888b.        888888  8888b.  88888b.  
#  888     888   888         Y8P           "Y88b. 888 d88P"88b 888 "88b       888        "88b 888 "88b 
#  888     888   888                         "888 888 888  888 888  888       888    .d888888 888  888 
#  Y88b. .d88P   888         d8b       Y88b  d88P 888 Y88b 888 888  888       Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888       Y8P        "Y8888P"  888  "Y88888 888  888        "Y888 "Y888888 88888P"  
#                                                          888                                         
#                                                     Y8b d88P                                         
#                                                      "Y88P"                                          

# ########
# UI : Sign tab
##########################################################



#  888     888 8888888                 888888b.            d8b 888      888       888             888      
#  888     888   888                   888  "88b           Y8P 888      888       888             888      
#  888     888   888                   888  .88P               888      888       888             888      
#  888     888   888         d8b       8888888K.  888  888 888 888  .d88888       888888  8888b.  88888b.  
#  888     888   888         Y8P       888  "Y88b 888  888 888 888 d88" 888       888        "88b 888 "88b 
#  888     888   888                   888    888 888  888 888 888 888  888       888    .d888888 888  888 
#  Y88b. .d88P   888         d8b       888   d88P Y88b 888 888 888 Y88b 888       Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888       Y8P       8888888P"   "Y88888 888 888  "Y88888        "Y888 "Y888888 88888P"  
#                                                                                                          
#                                                                                                          
#                                                                                                          

# ########
# UI : Build tab
##########################################################

#  888     888 8888888                 88888888888                   888          888             888      
#  888     888   888                       888                       888          888             888      
#  888     888   888                       888                       888          888             888      
#  888     888   888         d8b           888      .d88b.  .d8888b  888888       888888  8888b.  88888b.  
#  888     888   888         Y8P           888     d8P  Y8b 88K      888          888        "88b 888 "88b 
#  888     888   888                       888     88888888 "Y8888b. 888          888    .d888888 888  888 
#  Y88b. .d88P   888         d8b           888     Y8b.          X88 Y88b.        Y88b.  888  888 888 d88P 
#   "Y88888P"  8888888       Y8P           888      "Y8888   88888P'  "Y888        "Y888 "Y888888 88888P"  
#                                                                                                          
#                                                                                                          
#                                                                                                          

# ########
# UI : Test tab
##########################################################

# ########
# UI : Test tab : Field drop down

$cbTestParameters.Add_SelectionChanged({
    #LogDebug "cbTestParameters::SelectionChanged"
})



#  8888888888                                     888    d8b                   
#  888                                            888    Y8P                   
#  888                                            888                          
#  8888888    888  888  .d88b.   .d8888b 888  888 888888 888  .d88b.  88888b.  
#  888        `Y8bd8P' d8P  Y8b d88P"    888  888 888    888 d88""88b 888 "88b 
#  888          X88K   88888888 888      888  888 888    888 888  888 888  888 
#  888        .d8""8b. Y8b.     Y88b.    Y88b 888 Y88b.  888 Y88..88P 888  888 
#  8888888888 888  888  "Y8888   "Y8888P  "Y88888  "Y888 888  "Y88P"  888  888 
#                                                                              
#                                                                              
#                                                                              

########################################################################################################################
##################################################### Execution!!  #####################################################
########################################################################################################################


# Pre-populate the Cloud Template List from the local cashed copy
PlugInDownloadCloudRefresh

# Populate the List of Fields in the right ComboBoxes
ParameterFieldUpdate -ComboBoxes ($cbActionXFieldMappingField, $cbTestParameters)

# Populate the List of Languages ComboBoxes
LanguageFieldUpdate -ComboBoxes ($cbLanguageLanguageSelection)

# Populate the List of License ComboBoxes
LicenseUpdate -ComboBoxes ($cbPreferencesLicenseFile)

BuildNavigationTree -ItemToSelect 0


#$cbTestParameters.ItemsSource = ParameterFieldUpdate
#ParameterFieldUpdate -ComboBox $cbTestParameters
#$cbTestParameters.GetType()

# Run the UI
$SRPEditorForm.ShowDialog() | out-null

# Time to depart, my old friend...
LogInfo "Exiting SmartResponse Plug-In Editor"
# Didn't we have a joly good time?
