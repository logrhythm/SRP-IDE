# ###########################################
#
# License JSON list builder
#
# ###############
#
# (c) 2019, LogRhythm
#
# ###############
#
# Change Log:
#
# v1.0 - 2019-06-29 - Tony Massé (tony.masse@logrhythm.com)
# - Load RTF files from Disk
# - Build 2x JSON documents and save it to Disk
#   - 1x for the Local Cache
#   - 1x for the Cloud repository
#
# ################

# Go to where the script is
$basePath = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path
cd $basePath

# Put all this in a hash table
$LicenseList = New-Object System.Collections.ArrayList

# Get all the RTF files of the directory
$Licensefiles = Get-ChildItem "*.rtf"
foreach ($LicenseFile in $LicenseFiles) 
{
    # Load the content
    $LicenseText = Get-Content -Raw -Path $LicenseFile
    # Check if this is the default LogRhythm one
    if ($LicenseFile.BaseName -like "*LogRhythm*")
    {
        # If it is, it will be selected by default in the UI
        $IsSelected = $true
    }
    else
    {
        $IsSelected = $false
    }

    # Add to my list
    $LicenseList.Add(@{"Name" = $LicenseFile.BaseName ; "Text" = $LicenseText.ToString() ; "IsSelected" = $IsSelected}) | Out-Null
}

$TimeStampFormatForJSON = "yyyy-MM-ddTHH:mm:ss.fffZ"

$LicenseListExport = @{"DocType" = "LicensesList"
                      #;"LastUpdateTime" = (Get-Date).tostring($TimeStampFormatForJSON)
                      ;"LicensesList" = $LicenseList
                      }

# Export for the Cloud doc
$LicenseListExport | ConvertTo-Json | Out-File -FilePath "LicenseList.json"

# Add and timestamp and export for the Local cache doc
$LicenseListExport.LastUpdateTime = (Get-Date).tostring($TimeStampFormatForJSON)
$LicenseListExport | ConvertTo-Json | Out-File -FilePath "LicenseListLocal.json"


<#
From $LicenseList | select Name, IsSelected, Text

Name                       IsSelected Text                                                                                   
----                       ---------- ----                                                                                   
Apache License 2.0              False {\rtf1\adeflang1025\ansi\ansicpg1252\uc1\adeff31507\deff0\stshfdbch31505\stshfloch31...
GNU GPLv3                       False {\rtf1\adeflang1025\ansi\ansicpg1252\uc1\adeff31507\deff0\stshfdbch31505\stshfloch31...
GNU LGPLv3                      False {\rtf1\adeflang1025\ansi\ansicpg1252\uc1\adeff31507\deff0\stshfdbch31505\stshfloch31...
LogRhythm Code Sample            True {\rtf1\adeflang1025\ansi\ansicpg1252\uc1\adeff0\deff0\stshfdbch31506\stshfloch0\stsh...
MIT License                     False {\rtf1\adeflang1025\ansi\ansicpg1252\uc1\adeff31507\deff0\stshfdbch31505\stshfloch31...
Mozilla Public License 2.0      False {\rtf1\adeflang1025\ansi\ansicpg1252\uc1\adeff31507\deff0\stshfdbch31505\stshfloch31...
The Unlicense                   False {\rtf1\adeflang1025\ansi\ansicpg1252\uc1\adeff31507\deff0\stshfdbch31505\stshfloch31...
__ None __                      False {\rtf1}                                                                                


From the initial XAML
    <ComboBoxItem Content="LogRhythm Code Sample" IsSelected="True"/>
    <ComboBoxItem Content="MIT License"/>
    <ComboBoxItem Content="Apache License 2.0"/>
    <ComboBoxItem Content="GNU GPLv3"/>
    <ComboBoxItem Content="GNU LGPLv3"/>
    <ComboBoxItem Content="GNU AGPLv3"/>
    <ComboBoxItem Content="Mozilla Public License 2.0"/>
    <ComboBoxItem Content="The Unlicense"/>
    <ComboBoxItem Content="__ None __"/>

#>