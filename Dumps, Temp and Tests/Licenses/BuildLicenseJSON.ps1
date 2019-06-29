cls

$basePath = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path
cd $basePath


$LicenseList = New-Object System.Collections.ArrayList

$Licensefiles = Get-ChildItem "*.rtf"
foreach ($LicenseFile in $LicenseFiles) 
{
    $LicenseText = Get-Content -Raw -Path $LicenseFile
    $LicenseList.Add(@{"Name" = $LicenseFile.BaseName ; "Text" = $LicenseText.ToString()})
}

#$LicenseFiles[0].BaseName
#$LicenseList

$LicenseList.ToArray() | ConvertTo-Json | Out-File -FilePath "LicenseList.json"

<#
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