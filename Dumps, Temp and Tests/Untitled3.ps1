Add-Type –assemblyName WindowsBase
Add-Type –assemblyName PresentationCore
Add-Type –assemblyName PresentationFramework
cls
[string]$stXAML = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Window5" Height="167.797" Width="310.911">
    <Window.Resources>
       <Style x:Key="FocusVisual">
            <Setter Property="Control.Template">
                <Setter.Value>
                    <ControlTemplate>
                        <Rectangle Margin="2" SnapsToDevicePixels="true" Stroke="{DynamicResource {x:Static SystemColors.ControlTextBrushKey}}" StrokeThickness="1" StrokeDashArray="1 2"/>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <!-- COMBO -->
        <!-- Definition of the ComboBox override. This way, they look like the ones in the LogRhythm Web UI -->
        <ControlTemplate x:Key="ComboBoxToggleButton" TargetType="{x:Type ToggleButton}">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition />
                    <ColumnDefinition Width="20" />
                </Grid.ColumnDefinitions>
                <Border
                  x:Name="Border" 
                  Grid.ColumnSpan="2"
                  CornerRadius="0"
                  BorderBrush="#FF000000"
                  BorderThickness="0" >
                    <Border.Background>
                        <LinearGradientBrush EndPoint="0.5,1" StartPoint="0.5,0">
                            <GradientStop Color="#FF484B4D" Offset="0"/>
                            <GradientStop Color="#FF3B3C3E" Offset="1"/>
                        </LinearGradientBrush>
                    </Border.Background>
                </Border>
                <Border 
                  Grid.Column="0"
                  CornerRadius="0" 
                  Margin="1" 
                  BorderBrush="#FF97A0A5"
                  BorderThickness="0,0,0,0"/>
                <Path 
                  x:Name="Arrow"
                  Grid.Column="1"     
                  Fill="#FFCCCCCC"
                  HorizontalAlignment="Center"
                  VerticalAlignment="Center"
                  StrokeThickness="0.22764234" Data="M 10 0 4.9970745 5 0 0 Z"
                />
            </Grid>
            <ControlTemplate.Triggers>
                <Trigger Property="ToggleButton.IsMouseOver" Value="true">
                    <Setter TargetName="Border" Property="Background" Value="#FF6C6C6C" />
                </Trigger>
                <!--<Trigger Property="ToggleButton.IsChecked" Value="true">
                <Setter TargetName="Border" Property="Background" Value="#E0E0E0" />
            </Trigger>
            <Trigger Property="IsEnabled" Value="False">
                <Setter TargetName="Border" Property="Background" Value="#EEEEEE" />
                <Setter TargetName="Border" Property="BorderBrush" Value="#AAAAAA" />
                <Setter Property="Foreground" Value="#888888"/>
                <Setter TargetName="Arrow" Property="Fill" Value="#888888" />
            </Trigger>-->
            </ControlTemplate.Triggers>
        </ControlTemplate>

        <ControlTemplate x:Key="ComboBoxTextBox" TargetType="{x:Type TextBox}">
            <Border x:Name="PART_ContentHost" Focusable="False" Background="{TemplateBinding Background}" />
        </ControlTemplate>

        <Style x:Key="{x:Type ComboBox}" TargetType="{x:Type ComboBox}">
            <Setter Property="SnapsToDevicePixels" Value="true"/>
            <Setter Property="OverridesDefaultStyle" Value="true"/>
            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility" Value="Auto"/>
            <Setter Property="ScrollViewer.VerticalScrollBarVisibility" Value="Auto"/>
            <Setter Property="ScrollViewer.CanContentScroll" Value="true"/>
            <Setter Property="MinWidth" Value="120"/>
            <Setter Property="MinHeight" Value="20"/>
            <Setter Property="Foreground" Value="#FFCCCCCC"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type ComboBox}">
                        <Grid>
                            <ToggleButton 
                            Name="ToggleButton" 
                            Template="{StaticResource ComboBoxToggleButton}" 
                            Grid.Column="2" 
                            Focusable="false"
                            IsChecked="{Binding Path=IsDropDownOpen,Mode=TwoWay,RelativeSource={RelativeSource TemplatedParent}}"
                            ClickMode="Press">
                            </ToggleButton>
                            <ContentPresenter Name="ContentSite" IsHitTestVisible="False"  Content="{TemplateBinding SelectionBoxItem}"
                            ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}"
                            ContentTemplateSelector="{TemplateBinding ItemTemplateSelector}"
                            Margin="3,3,23,3"
                            VerticalAlignment="Center"
                            HorizontalAlignment="Left" />
                            <TextBox x:Name="PART_EditableTextBox"
                            Style="{x:Null}" 
                            Template="{StaticResource ComboBoxTextBox}" 
                            HorizontalAlignment="Left" 
                            VerticalAlignment="Center" 
                            Margin="3,3,23,3"
                            Focusable="True" 
                            Background="#FF3F3F3F"
                            Foreground="Green"
                            Visibility="Hidden"
                            IsReadOnly="{TemplateBinding IsReadOnly}"/>
                            <Popup 
                            Name="PART_Popup"
                            Placement="Bottom"
                            IsOpen="{TemplateBinding IsDropDownOpen}"
                            AllowsTransparency="True" 
                            Focusable="False"
                            PopupAnimation="Slide">

                                <Grid Name="DropDown"
                              SnapsToDevicePixels="True"                
                              MinWidth="{TemplateBinding ActualWidth}"
                              MaxHeight="{TemplateBinding MaxDropDownHeight}">
                                    <Border 
                                x:Name="DropDownBorder"

                                BorderThickness="1"
                                BorderBrush="#FF595959">
                                        <Border.Background>
                                            <LinearGradientBrush EndPoint="0.5,1" StartPoint="0.5,0">
                                                <GradientStop Color="#FF484B4D" Offset="0"/>
                                                <GradientStop Color="#FF3B3C3E" Offset="1"/>
                                            </LinearGradientBrush>
                                        </Border.Background>
                                    </Border>
                                    <ScrollViewer Margin="4,6,4,6" SnapsToDevicePixels="True">
                                        <!--<StackPanel IsItemsHost="True" KeyboardNavigation.DirectionalNavigation="Contained" />-->
                                        <ItemsPresenter x:Name="ItemsPresenter" KeyboardNavigation.DirectionalNavigation="Contained" SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}"/>
                                    </ScrollViewer>
                                </Grid>
                            </Popup>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="HasItems" Value="false">
                                <Setter TargetName="DropDownBorder" Property="MinHeight" Value="95"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="false">
                                <Setter Property="Foreground" Value="#888888"/>
                            </Trigger>
                            <Trigger Property="IsGrouping" Value="true">
                                <Setter Property="ScrollViewer.CanContentScroll" Value="false"/>
                            </Trigger>
                            <Trigger SourceName="PART_Popup" Property="Popup.AllowsTransparency" Value="true">
                                <Setter TargetName="DropDownBorder" Property="CornerRadius" Value="0"/>
                                <Setter TargetName="DropDownBorder" Property="Margin" Value="0,2,0,0"/>
                            </Trigger>
                            <Trigger Property="IsEditable"  Value="true">
                                <Setter Property="IsTabStop" Value="false"/>
                                <Setter TargetName="PART_EditableTextBox" Property="Visibility" Value="Visible"/>
                                <Setter TargetName="ContentSite" Property="Visibility" Value="Hidden"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
            </Style.Triggers>
        </Style>

        <!-- SimpleStyles: ComboBoxItem -->
        <Style x:Key="{x:Type ComboBoxItem}" TargetType="{x:Type ComboBoxItem}">
            <Setter Property="SnapsToDevicePixels" Value="true"/>
            <Setter Property="Foreground" Value="#FFCCCCCC"/>
            <Setter Property="OverridesDefaultStyle" Value="true"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type ComboBoxItem}">
                        <Border Name="Border"
                              Padding="2"
                              BorderThickness="0,0,0,1"
                              SnapsToDevicePixels="true" BorderBrush="#FF555555">
                            <ContentPresenter />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsHighlighted" Value="true">
                                <Setter TargetName="Border" Property="Background" Value="#FF6C6C6C"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="false">
                                <Setter Property="Foreground" Value="#888888"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <!-- End of Definition for the ComboBox override. -->
    </Window.Resources>
    <Grid>
        <ComboBox x:Name="cbTestParameters" Height="28" Margin="6,6,11,0" VerticalAlignment="Top" Background="#FF1F2121" Foreground="#FFCCCCCC" FontSize="16" BorderBrush="#FF1F2121">
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
    </Grid>
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

    #$ParameterFieldListArray | ConvertTo-Json

$GUIWindow.ShowDialog() | out-null