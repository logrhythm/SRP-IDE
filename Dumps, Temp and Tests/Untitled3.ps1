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
        <Style TargetType="{x:Type ComboBox}">
            <Setter Property="FocusVisualStyle">
                <Setter.Value>
                    <Style>
                        <Setter Property="Control.Template">
                            <Setter.Value>
                                <ControlTemplate>
                                    <Rectangle Margin="2" SnapsToDevicePixels="True" Stroke="{DynamicResource {x:Static SystemColors.ControlTextBrushKey}}" StrokeThickness="1" StrokeDashArray="1 2"/>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Setter.Value>
            </Setter>
            <Setter Property="Background">
                <Setter.Value>
                    <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                        <GradientStop Color="#FFF0F0F0" Offset="0"/>
                        <GradientStop Color="#FFE5E5E5" Offset="1"/>
                    </LinearGradientBrush>
                </Setter.Value>
            </Setter>
            <Setter Property="BorderBrush" Value="#FFACACAC"/>
            <Setter Property="Foreground" Value="{DynamicResource {x:Static SystemColors.WindowTextBrushKey}}"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="ScrollViewer.HorizontalScrollBarVisibility" Value="Auto"/>
            <Setter Property="ScrollViewer.VerticalScrollBarVisibility" Value="Auto"/>
            <Setter Property="Padding" Value="6,3,5,3"/>
            <Setter Property="ScrollViewer.CanContentScroll" Value="True"/>
            <Setter Property="ScrollViewer.PanningMode" Value="Both"/>
            <Setter Property="Stylus.IsFlicksEnabled" Value="False"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type ComboBox}">
                        <Grid x:Name="templateRoot" SnapsToDevicePixels="True">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition MinWidth="{DynamicResource {x:Static SystemParameters.VerticalScrollBarWidthKey}}" Width="0"/>
                            </Grid.ColumnDefinitions>
                            <Popup x:Name="PART_Popup" AllowsTransparency="True" Grid.ColumnSpan="2" IsOpen="{Binding IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}" Margin="1" PopupAnimation="{DynamicResource {x:Static SystemParameters.ComboBoxPopupAnimationKey}}" Placement="Bottom">
                                    <Border x:Name="DropDownBorder" BorderBrush="{DynamicResource {x:Static SystemColors.WindowFrameBrushKey}}" BorderThickness="1" Background="{DynamicResource {x:Static SystemColors.WindowBrushKey}}">
                                        <ScrollViewer x:Name="DropDownScrollViewer">
                                            <Grid x:Name="grid" RenderOptions.ClearTypeHint="Enabled">
                                                <Canvas x:Name="canvas" HorizontalAlignment="Left" Height="0" VerticalAlignment="Top" Width="0">
                                                    <Rectangle x:Name="OpaqueRect" Fill="{Binding Background, ElementName=DropDownBorder}" Height="{Binding ActualHeight, ElementName=DropDownBorder}" Width="{Binding ActualWidth, ElementName=DropDownBorder}"/>
                                                </Canvas>
                                                <ItemsPresenter x:Name="ItemsPresenter" KeyboardNavigation.DirectionalNavigation="Contained" SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}"/>
                                            </Grid>
                                        </ScrollViewer>
                                    </Border>
                            </Popup>
                            <ToggleButton x:Name="toggleButton" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Background="{TemplateBinding Background}" Grid.ColumnSpan="2" IsChecked="{Binding IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}">
                                <ToggleButton.Style>
                                    <Style TargetType="{x:Type ToggleButton}">
                                        <Setter Property="OverridesDefaultStyle" Value="True"/>
                                        <Setter Property="IsTabStop" Value="False"/>
                                        <Setter Property="Focusable" Value="False"/>
                                        <Setter Property="ClickMode" Value="Press"/>
                                        <Setter Property="Template">
                                            <Setter.Value>
                                                <ControlTemplate TargetType="{x:Type ToggleButton}">
                                                    <Border x:Name="templateRoot" BorderBrush="#FFACACAC" BorderThickness="{TemplateBinding BorderThickness}" SnapsToDevicePixels="True">
                                                        <Border.Background>
                                                            <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                <GradientStop Color="#FFF0F0F0" Offset="0"/>
                                                                <GradientStop Color="#FFE5E5E5" Offset="1"/>
                                                            </LinearGradientBrush>
                                                        </Border.Background>
                                                        <Border x:Name="splitBorder" BorderBrush="Transparent" BorderThickness="1" HorizontalAlignment="Right" Margin="0" SnapsToDevicePixels="True" Width="{DynamicResource {x:Static SystemParameters.VerticalScrollBarWidthKey}}">
                                                            <Path x:Name="Arrow" Data="F1M0,0L2.667,2.66665 5.3334,0 5.3334,-1.78168 2.6667,0.88501 0,-1.78168 0,0z" Fill="#FF606060" HorizontalAlignment="Center" Margin="0" VerticalAlignment="Center"/>
                                                        </Border>
                                                    </Border>
                                                    <ControlTemplate.Triggers>
                                                        <MultiDataTrigger>
                                                            <MultiDataTrigger.Conditions>
                                                                <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="true"/>
                                                                <Condition Binding="{Binding IsMouseOver, RelativeSource={RelativeSource Self}}" Value="false"/>
                                                                <Condition Binding="{Binding IsPressed, RelativeSource={RelativeSource Self}}" Value="false"/>
                                                                <Condition Binding="{Binding IsEnabled, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                            </MultiDataTrigger.Conditions>
                                                            <Setter Property="Background" TargetName="templateRoot" Value="White"/>
                                                            <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FFABADB3"/>
                                                            <Setter Property="Background" TargetName="splitBorder" Value="Transparent"/>
                                                            <Setter Property="BorderBrush" TargetName="splitBorder" Value="Transparent"/>
                                                        </MultiDataTrigger>
                                                        <Trigger Property="IsMouseOver" Value="True">
                                                            <Setter Property="Fill" TargetName="Arrow" Value="Black"/>
                                                        </Trigger>
                                                        <MultiDataTrigger>
                                                            <MultiDataTrigger.Conditions>
                                                                <Condition Binding="{Binding IsMouseOver, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                                <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="false"/>
                                                            </MultiDataTrigger.Conditions>
                                                            <Setter Property="Background" TargetName="templateRoot">
                                                                <Setter.Value>
                                                                    <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                        <GradientStop Color="#FFECF4FC" Offset="0"/>
                                                                        <GradientStop Color="#FFDCECFC" Offset="1"/>
                                                                    </LinearGradientBrush>
                                                                </Setter.Value>
                                                            </Setter>
                                                            <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FF7EB4EA"/>
                                                        </MultiDataTrigger>
                                                        <MultiDataTrigger>
                                                            <MultiDataTrigger.Conditions>
                                                                <Condition Binding="{Binding IsMouseOver, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                                <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="true"/>
                                                            </MultiDataTrigger.Conditions>
                                                            <Setter Property="Background" TargetName="templateRoot" Value="White"/>
                                                            <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FF7EB4EA"/>
                                                            <Setter Property="Background" TargetName="splitBorder">
                                                                <Setter.Value>
                                                                    <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                        <GradientStop Color="#FFEBF4FC" Offset="0"/>
                                                                        <GradientStop Color="#FFDCECFC" Offset="1"/>
                                                                    </LinearGradientBrush>
                                                                </Setter.Value>
                                                            </Setter>
                                                            <Setter Property="BorderBrush" TargetName="splitBorder" Value="#FF7EB4EA"/>
                                                        </MultiDataTrigger>
                                                        <Trigger Property="IsPressed" Value="True">
                                                            <Setter Property="Fill" TargetName="Arrow" Value="Black"/>
                                                        </Trigger>
                                                        <MultiDataTrigger>
                                                            <MultiDataTrigger.Conditions>
                                                                <Condition Binding="{Binding IsPressed, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                                <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="false"/>
                                                            </MultiDataTrigger.Conditions>
                                                            <Setter Property="Background" TargetName="templateRoot">
                                                                <Setter.Value>
                                                                    <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                        <GradientStop Color="#FFDAECFC" Offset="0"/>
                                                                        <GradientStop Color="#FFC4E0FC" Offset="1"/>
                                                                    </LinearGradientBrush>
                                                                </Setter.Value>
                                                            </Setter>
                                                            <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FF569DE5"/>
                                                        </MultiDataTrigger>
                                                        <MultiDataTrigger>
                                                            <MultiDataTrigger.Conditions>
                                                                <Condition Binding="{Binding IsPressed, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                                <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="true"/>
                                                            </MultiDataTrigger.Conditions>
                                                            <Setter Property="Background" TargetName="templateRoot" Value="White"/>
                                                            <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FF569DE5"/>
                                                            <Setter Property="Background" TargetName="splitBorder">
                                                                <Setter.Value>
                                                                    <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                        <GradientStop Color="#FFDAEBFC" Offset="0"/>
                                                                        <GradientStop Color="#FFC4E0FC" Offset="1"/>
                                                                    </LinearGradientBrush>
                                                                </Setter.Value>
                                                            </Setter>
                                                            <Setter Property="BorderBrush" TargetName="splitBorder" Value="#FF569DE5"/>
                                                        </MultiDataTrigger>
                                                        <Trigger Property="IsEnabled" Value="False">
                                                            <Setter Property="Fill" TargetName="Arrow" Value="#FFBFBFBF"/>
                                                        </Trigger>
                                                        <MultiDataTrigger>
                                                            <MultiDataTrigger.Conditions>
                                                                <Condition Binding="{Binding IsEnabled, RelativeSource={RelativeSource Self}}" Value="false"/>
                                                                <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="false"/>
                                                            </MultiDataTrigger.Conditions>
                                                            <Setter Property="Background" TargetName="templateRoot" Value="#FFF0F0F0"/>
                                                            <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FFD9D9D9"/>
                                                        </MultiDataTrigger>
                                                        <MultiDataTrigger>
                                                            <MultiDataTrigger.Conditions>
                                                                <Condition Binding="{Binding IsEnabled, RelativeSource={RelativeSource Self}}" Value="false"/>
                                                                <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="true"/>
                                                            </MultiDataTrigger.Conditions>
                                                            <Setter Property="Background" TargetName="templateRoot" Value="White"/>
                                                            <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FFBFBFBF"/>
                                                            <Setter Property="Background" TargetName="splitBorder" Value="Transparent"/>
                                                            <Setter Property="BorderBrush" TargetName="splitBorder" Value="Transparent"/>
                                                        </MultiDataTrigger>
                                                    </ControlTemplate.Triggers>
                                                </ControlTemplate>
                                            </Setter.Value>
                                        </Setter>
                                    </Style>
                                </ToggleButton.Style>
                            </ToggleButton>
                            <ContentPresenter x:Name="contentPresenter" ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}" Content="{TemplateBinding SelectionBoxItem}" ContentStringFormat="{TemplateBinding SelectionBoxItemStringFormat}" HorizontalAlignment="{TemplateBinding HorizontalContentAlignment}" IsHitTestVisible="False" Margin="{TemplateBinding Padding}" SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}" VerticalAlignment="{TemplateBinding VerticalContentAlignment}"/>
                        </Grid>
                        <ControlTemplate.Triggers>
                            <Trigger Property="HasItems" Value="False">
                                <Setter Property="Height" TargetName="DropDownBorder" Value="95"/>
                            </Trigger>
                            <MultiTrigger>
                                <MultiTrigger.Conditions>
                                    <Condition Property="IsGrouping" Value="True"/>
                                    <Condition Property="VirtualizingPanel.IsVirtualizingWhenGrouping" Value="False"/>
                                </MultiTrigger.Conditions>
                                <Setter Property="ScrollViewer.CanContentScroll" Value="False"/>
                            </MultiTrigger>
                            <Trigger Property="CanContentScroll" SourceName="DropDownScrollViewer" Value="False">
                                <Setter Property="Canvas.Top" TargetName="OpaqueRect" Value="{Binding VerticalOffset, ElementName=DropDownScrollViewer}"/>
                                <Setter Property="Canvas.Left" TargetName="OpaqueRect" Value="{Binding HorizontalOffset, ElementName=DropDownScrollViewer}"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
            <Style.Triggers>
                <Trigger Property="IsEditable" Value="True">
                    <Setter Property="IsTabStop" Value="False"/>
                    <Setter Property="Padding" Value="2"/>
                    <Setter Property="Template">
                        <Setter.Value>
                            <ControlTemplate TargetType="{x:Type ComboBox}">
                                <Grid x:Name="templateRoot" SnapsToDevicePixels="True">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition MinWidth="{DynamicResource {x:Static SystemParameters.VerticalScrollBarWidthKey}}" Width="0"/>
                                    </Grid.ColumnDefinitions>
                                    <Popup x:Name="PART_Popup" AllowsTransparency="True" Grid.ColumnSpan="2" IsOpen="{Binding IsDropDownOpen, RelativeSource={RelativeSource TemplatedParent}}" PopupAnimation="{DynamicResource {x:Static SystemParameters.ComboBoxPopupAnimationKey}}" Placement="Bottom">
                                            <Border x:Name="DropDownBorder" BorderBrush="{DynamicResource {x:Static SystemColors.WindowFrameBrushKey}}" BorderThickness="1" Background="{DynamicResource {x:Static SystemColors.WindowBrushKey}}">
                                                <ScrollViewer x:Name="DropDownScrollViewer">
                                                    <Grid x:Name="grid" RenderOptions.ClearTypeHint="Enabled">
                                                        <Canvas x:Name="canvas" HorizontalAlignment="Left" Height="0" VerticalAlignment="Top" Width="0">
                                                            <Rectangle x:Name="OpaqueRect" Fill="{Binding Background, ElementName=DropDownBorder}" Height="{Binding ActualHeight, ElementName=DropDownBorder}" Width="{Binding ActualWidth, ElementName=DropDownBorder}"/>
                                                        </Canvas>
                                                        <ItemsPresenter x:Name="ItemsPresenter" KeyboardNavigation.DirectionalNavigation="Contained" SnapsToDevicePixels="{TemplateBinding SnapsToDevicePixels}"/>
                                                    </Grid>
                                                </ScrollViewer>
                                            </Border>
                                    </Popup>
                                    <ToggleButton x:Name="toggleButton" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Background="{TemplateBinding Background}" Grid.ColumnSpan="2" IsChecked="{Binding IsDropDownOpen, Mode=TwoWay, RelativeSource={RelativeSource TemplatedParent}}">
                                        <ToggleButton.Style>
                                            <Style TargetType="{x:Type ToggleButton}">
                                                <Setter Property="OverridesDefaultStyle" Value="True"/>
                                                <Setter Property="IsTabStop" Value="False"/>
                                                <Setter Property="Focusable" Value="False"/>
                                                <Setter Property="ClickMode" Value="Press"/>
                                                <Setter Property="Template">
                                                    <Setter.Value>
                                                        <ControlTemplate TargetType="{x:Type ToggleButton}">
                                                            <Border x:Name="templateRoot" BorderBrush="#FFACACAC" BorderThickness="{TemplateBinding BorderThickness}" SnapsToDevicePixels="True">
                                                                <Border.Background>
                                                                    <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                        <GradientStop Color="#FFF0F0F0" Offset="0"/>
                                                                        <GradientStop Color="#FFE5E5E5" Offset="1"/>
                                                                    </LinearGradientBrush>
                                                                </Border.Background>
                                                                <Border x:Name="splitBorder" BorderBrush="Transparent" BorderThickness="1" HorizontalAlignment="Right" Margin="0" SnapsToDevicePixels="True" Width="{DynamicResource {x:Static SystemParameters.VerticalScrollBarWidthKey}}">
                                                                    <Path x:Name="Arrow" Data="F1M0,0L2.667,2.66665 5.3334,0 5.3334,-1.78168 2.6667,0.88501 0,-1.78168 0,0z" Fill="#FF606060" HorizontalAlignment="Center" Margin="0" VerticalAlignment="Center"/>
                                                                </Border>
                                                            </Border>
                                                            <ControlTemplate.Triggers>
                                                                <MultiDataTrigger>
                                                                    <MultiDataTrigger.Conditions>
                                                                        <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="true"/>
                                                                        <Condition Binding="{Binding IsMouseOver, RelativeSource={RelativeSource Self}}" Value="false"/>
                                                                        <Condition Binding="{Binding IsPressed, RelativeSource={RelativeSource Self}}" Value="false"/>
                                                                        <Condition Binding="{Binding IsEnabled, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                                    </MultiDataTrigger.Conditions>
                                                                    <Setter Property="Background" TargetName="templateRoot" Value="White"/>
                                                                    <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FFABADB3"/>
                                                                    <Setter Property="Background" TargetName="splitBorder" Value="Transparent"/>
                                                                    <Setter Property="BorderBrush" TargetName="splitBorder" Value="Transparent"/>
                                                                </MultiDataTrigger>
                                                                <Trigger Property="IsMouseOver" Value="True">
                                                                    <Setter Property="Fill" TargetName="Arrow" Value="Black"/>
                                                                </Trigger>
                                                                <MultiDataTrigger>
                                                                    <MultiDataTrigger.Conditions>
                                                                        <Condition Binding="{Binding IsMouseOver, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                                        <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="false"/>
                                                                    </MultiDataTrigger.Conditions>
                                                                    <Setter Property="Background" TargetName="templateRoot">
                                                                        <Setter.Value>
                                                                            <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                                <GradientStop Color="#FFECF4FC" Offset="0"/>
                                                                                <GradientStop Color="#FFDCECFC" Offset="1"/>
                                                                            </LinearGradientBrush>
                                                                        </Setter.Value>
                                                                    </Setter>
                                                                    <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FF7EB4EA"/>
                                                                </MultiDataTrigger>
                                                                <MultiDataTrigger>
                                                                    <MultiDataTrigger.Conditions>
                                                                        <Condition Binding="{Binding IsMouseOver, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                                        <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="true"/>
                                                                    </MultiDataTrigger.Conditions>
                                                                    <Setter Property="Background" TargetName="templateRoot" Value="White"/>
                                                                    <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FF7EB4EA"/>
                                                                    <Setter Property="Background" TargetName="splitBorder">
                                                                        <Setter.Value>
                                                                            <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                                <GradientStop Color="#FFEBF4FC" Offset="0"/>
                                                                                <GradientStop Color="#FFDCECFC" Offset="1"/>
                                                                            </LinearGradientBrush>
                                                                        </Setter.Value>
                                                                    </Setter>
                                                                    <Setter Property="BorderBrush" TargetName="splitBorder" Value="#FF7EB4EA"/>
                                                                </MultiDataTrigger>
                                                                <Trigger Property="IsPressed" Value="True">
                                                                    <Setter Property="Fill" TargetName="Arrow" Value="Black"/>
                                                                </Trigger>
                                                                <MultiDataTrigger>
                                                                    <MultiDataTrigger.Conditions>
                                                                        <Condition Binding="{Binding IsPressed, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                                        <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="false"/>
                                                                    </MultiDataTrigger.Conditions>
                                                                    <Setter Property="Background" TargetName="templateRoot">
                                                                        <Setter.Value>
                                                                            <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                                <GradientStop Color="#FFDAECFC" Offset="0"/>
                                                                                <GradientStop Color="#FFC4E0FC" Offset="1"/>
                                                                            </LinearGradientBrush>
                                                                        </Setter.Value>
                                                                    </Setter>
                                                                    <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FF569DE5"/>
                                                                </MultiDataTrigger>
                                                                <MultiDataTrigger>
                                                                    <MultiDataTrigger.Conditions>
                                                                        <Condition Binding="{Binding IsPressed, RelativeSource={RelativeSource Self}}" Value="true"/>
                                                                        <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="true"/>
                                                                    </MultiDataTrigger.Conditions>
                                                                    <Setter Property="Background" TargetName="templateRoot" Value="White"/>
                                                                    <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FF569DE5"/>
                                                                    <Setter Property="Background" TargetName="splitBorder">
                                                                        <Setter.Value>
                                                                            <LinearGradientBrush EndPoint="0,1" StartPoint="0,0">
                                                                                <GradientStop Color="#FFDAEBFC" Offset="0"/>
                                                                                <GradientStop Color="#FFC4E0FC" Offset="1"/>
                                                                            </LinearGradientBrush>
                                                                        </Setter.Value>
                                                                    </Setter>
                                                                    <Setter Property="BorderBrush" TargetName="splitBorder" Value="#FF569DE5"/>
                                                                </MultiDataTrigger>
                                                                <Trigger Property="IsEnabled" Value="False">
                                                                    <Setter Property="Fill" TargetName="Arrow" Value="#FFBFBFBF"/>
                                                                </Trigger>
                                                                <MultiDataTrigger>
                                                                    <MultiDataTrigger.Conditions>
                                                                        <Condition Binding="{Binding IsEnabled, RelativeSource={RelativeSource Self}}" Value="false"/>
                                                                        <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="false"/>
                                                                    </MultiDataTrigger.Conditions>
                                                                    <Setter Property="Background" TargetName="templateRoot" Value="#FFF0F0F0"/>
                                                                    <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FFD9D9D9"/>
                                                                </MultiDataTrigger>
                                                                <MultiDataTrigger>
                                                                    <MultiDataTrigger.Conditions>
                                                                        <Condition Binding="{Binding IsEnabled, RelativeSource={RelativeSource Self}}" Value="false"/>
                                                                        <Condition Binding="{Binding IsEditable, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}" Value="true"/>
                                                                    </MultiDataTrigger.Conditions>
                                                                    <Setter Property="Background" TargetName="templateRoot" Value="White"/>
                                                                    <Setter Property="BorderBrush" TargetName="templateRoot" Value="#FFBFBFBF"/>
                                                                    <Setter Property="Background" TargetName="splitBorder" Value="Transparent"/>
                                                                    <Setter Property="BorderBrush" TargetName="splitBorder" Value="Transparent"/>
                                                                </MultiDataTrigger>
                                                            </ControlTemplate.Triggers>
                                                        </ControlTemplate>
                                                    </Setter.Value>
                                                </Setter>
                                            </Style>
                                        </ToggleButton.Style>
                                    </ToggleButton>
                                    <Border x:Name="Border" Background="White" Margin="{TemplateBinding BorderThickness}">
                                        <TextBox x:Name="PART_EditableTextBox" HorizontalContentAlignment="{TemplateBinding HorizontalContentAlignment}" IsReadOnly="{Binding IsReadOnly, RelativeSource={RelativeSource TemplatedParent}}" Margin="{TemplateBinding Padding}" VerticalContentAlignment="{TemplateBinding VerticalContentAlignment}">
                                            <TextBox.Style>
                                                <Style TargetType="{x:Type TextBox}">
                                                    <Setter Property="OverridesDefaultStyle" Value="True"/>
                                                    <Setter Property="AllowDrop" Value="True"/>
                                                    <Setter Property="MinWidth" Value="0"/>
                                                    <Setter Property="MinHeight" Value="0"/>
                                                    <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
                                                    <Setter Property="ScrollViewer.PanningMode" Value="VerticalFirst"/>
                                                    <Setter Property="Stylus.IsFlicksEnabled" Value="False"/>
                                                    <Setter Property="Template">
                                                        <Setter.Value>
                                                            <ControlTemplate TargetType="{x:Type TextBox}">
                                                                <ScrollViewer x:Name="PART_ContentHost" Background="Transparent" Focusable="False" HorizontalScrollBarVisibility="Hidden" VerticalScrollBarVisibility="Hidden"/>
                                                            </ControlTemplate>
                                                        </Setter.Value>
                                                    </Setter>
                                                    <Style.Triggers>
                                                        <DataTrigger Binding="{Binding (0)}" Value="false">
                                                            <Setter Property="AutomationProperties.Name" Value="{Binding (AutomationProperties.Name), Mode=OneWay, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}"/>
                                                            <Setter Property="AutomationProperties.LabeledBy" Value="{Binding (AutomationProperties.LabeledBy), Mode=OneWay, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}"/>
                                                            <Setter Property="AutomationProperties.HelpText" Value="{Binding (AutomationProperties.HelpText), Mode=OneWay, RelativeSource={RelativeSource FindAncestor, AncestorLevel=1, AncestorType={x:Type ComboBox}}}"/>
                                                        </DataTrigger>
                                                    </Style.Triggers>
                                                </Style>
                                            </TextBox.Style>
                                        </TextBox>
                                    </Border>
                                </Grid>
                                <ControlTemplate.Triggers>
                                    <Trigger Property="IsEnabled" Value="False">
                                        <Setter Property="Opacity" TargetName="Border" Value="0.56"/>
                                    </Trigger>
                                    <Trigger Property="IsKeyboardFocusWithin" Value="True">
                                        <Setter Property="Foreground" Value="Black"/>
                                    </Trigger>
                                    <Trigger Property="HasItems" Value="False">
                                        <Setter Property="Height" TargetName="DropDownBorder" Value="95"/>
                                    </Trigger>
                                    <MultiTrigger>
                                        <MultiTrigger.Conditions>
                                            <Condition Property="IsGrouping" Value="True"/>
                                            <Condition Property="VirtualizingPanel.IsVirtualizingWhenGrouping" Value="False"/>
                                        </MultiTrigger.Conditions>
                                        <Setter Property="ScrollViewer.CanContentScroll" Value="False"/>
                                    </MultiTrigger>
                                    <Trigger Property="CanContentScroll" SourceName="DropDownScrollViewer" Value="False">
                                        <Setter Property="Canvas.Top" TargetName="OpaqueRect" Value="{Binding VerticalOffset, ElementName=DropDownScrollViewer}"/>
                                        <Setter Property="Canvas.Left" TargetName="OpaqueRect" Value="{Binding HorizontalOffset, ElementName=DropDownScrollViewer}"/>
                                    </Trigger>
                                </ControlTemplate.Triggers>
                            </ControlTemplate>
                        </Setter.Value>
                    </Setter>
                </Trigger>
            </Style.Triggers>
        </Style>
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


$GUIWindow.ShowDialog() | out-null