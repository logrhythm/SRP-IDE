Add-Type –assemblyName WindowsBase
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName PresentationFramework
cls
[string]$stXAML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="MainWindow" Height="350" Width="525">
    <StackPanel>
                                                            <ComboBox Name="cbTestParameters" Height="28" Margin="6,6,11,0" VerticalAlignment="Top" Background="#FF1F2121" Foreground="#FFCCCCCC" FontSize="16" BorderBrush="#FF1F2121">
                                                                <ComboBox.Effect>
                                                                    <DropShadowEffect Opacity="0.4" BlurRadius="10" ShadowDepth="3"/>
                                                                </ComboBox.Effect>
                                                                <ComboBox.GroupStyle>
                                                                    <GroupStyle>
                                                                        <GroupStyle.HeaderTemplate>
                                                                            <DataTemplate>
                                                                                <TextBlock Text="{Binding Name}"/>
                                                                            </DataTemplate>
                                                                        </GroupStyle.HeaderTemplate>
                                                                    </GroupStyle>
                                                                </ComboBox.GroupStyle>
                                                                <ComboBox.ItemTemplate>
                                                                    <DataTemplate>
                                                                        <TextBlock Text="{Binding Name}"/>
                                                                    </DataTemplate>
                                                                </ComboBox.ItemTemplate>
                                                            </ComboBox>

    </StackPanel>
</Window>
"@

[xml]$XAML = $stXAML
$stXAML = $stXAML -replace 'x:Class=".*.MainWindow"'," "
$stXAML = $stXAML -replace 'mc:Ignorable="d"',""
#$stXAML = $stXAML -replace 'x:Name="([^"]*)"','x:Name="$1" Name="$1"'  # Turns out, this cause a lot of troubles :D Getting rid of it :)
$stXAML = $stXAML -replace 'x:Name="([^"]*)"','Name="$1"'


$reader = (New-Object Xml.XmlNodeReader $XAML) 
$GUIWindow = [Windows.Markup.XamlReader]::Load( $reader ) 

$xaml.SelectNodes("//*[@Name]") | % {Set-Variable -Name ($_.Name) -Value $GUIWindow.FindName($_.Name)}


    $ParameterFieldListArray = @()
    #$ParameterFieldListArray += New-Object PSObject -Property @{Name=$null;Family="Recent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Severity";Family="Classification"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Vendor Message ID";Family="Classification"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Vendor Info";Family="Classification"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Threat Name";Family="Classification"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Threat ID";Family="Classification"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="CVE";Family="Classification"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="User (Origin)";Family="Identity"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="User (Impacted)";Family="Identity"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Sender";Family="Identity"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Recipient";Family="Identity"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Group";Family="Identity"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="MAC Address (Origin)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="MAC Address (Impacted)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Interface (Origin)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Interface (Impacted)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="IP Address (Origin)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="IP Address (Impacted)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="NAT IP Address (Origin)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="NAT IP Address (Impacted)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Hostname (Origin)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Hostname (Impacted)";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Serial Number";Family="Host"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Domain (Impacted)";Family="Network "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Domain (Origin)";Family="Network "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Protocol (Number)";Family="Network "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Protocol (Name)";Family="Network "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="TCP/UDP Port (Origin)";Family="Network "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="TCP/UDP Port (Impacted)";Family="Network "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="NAT TCP/UDP Port (Origin)";Family="Network "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="NAT TCP/UDP Port (Impacted)";Family="Network "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Object";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Object Name";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Object Type";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Hash";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Policy";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Result";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="URL";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="User Agent";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Response Code";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Subject";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Version";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Command";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Reason";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Action";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Status";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Session Type";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Process Name";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Process ID";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Parent Process ID";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Parent Process Name";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Parent Process Path";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Quantity ";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Amount";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Size";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Rate";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Session";Family="Application"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Time Start";Family="Duration"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Time End";Family="Duration"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Duration in Days";Family="Duration"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Duration in Hours";Family="Duration"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Duration in Minutes";Family="Duration"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Duration in Seconds";Family="Duration"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Duration in Milliseconds";Family="Duration"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Duration in Microsecond";Family="Duration"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Duration in Nanosecond";Family="Duration"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Bits received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Bytes received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Kilobits received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="KiloBytes received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Megabits received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="MegaBytes received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Gigabits received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="GigaBytes received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Terabits received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="TeraBytes received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Petabits received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="PetaBytes received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Bits";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Bytes";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Kbits";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="KBytes";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Megabits";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="MegaBytes";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Gigabits";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="GigaBytes";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Terabits";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="TeraBytes";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Petabits";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="PetaBytes";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Bits sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Bytes sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Kbits sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="KBytes sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Megabits sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="MegaBytes sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Gigabits sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="GigaBytes sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Terabits sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="TeraBytes sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Petabits sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="PetaBytes sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Packet Received";Family="Host (Impacted) Traffic Received"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="Packet Sent";Family="Host (Impacted) Traffic Sent"}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="<tag1> ";Family="Special Sub-Rule Tags "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="<tag2> ";Family="Special Sub-Rule Tags "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="<tag3> ";Family="Special Sub-Rule Tags "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="<tag4> ";Family="Special Sub-Rule Tags "}
    $ParameterFieldListArray += New-Object PSObject -Property @{Name="<tag5> ";Family="Special Sub-Rule Tags "}

    $ListView = [System.Windows.Data.ListCollectionView]$ParameterFieldListArray
    $ListView.GroupDescriptions.Add((new-object System.Windows.Data.PropertyGroupDescription "Family"))
    $cbTestParameters.ItemsSource = $ListView


$GUIWindow.ShowDialog() | out-null
