```powershell
#load assembly type
Add-Type -AssemblyName presentationframework

#define tool details in xml
[xml] $mybox = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="Profile Reset Tool" Name="Window"  Height="351.243" Width="446.643" Background="#C9D6DF" ResizeMode="NoResize">
        
        <Grid Margin="0,0,2,18">
        <Label Name="ComputerNamelbl" Content="ComputerName:" HorizontalAlignment="Left" Margin="41,58,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold"/>
        <TextBox Name="compnametxtbx" HorizontalAlignment="Left" Height="22" Margin="178,64,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="189" FontSize="16"/>
        <!--<Label Name="Profilepathlbl" Content="User UPM Path:" HorizontalAlignment="Left" Margin="41,99,0,0" VerticalAlignment="Top" FontSize="16" FontWeight="Bold"/>-->
        <!--<TextBox x:Name="profilepathtxtbx" HorizontalAlignment="Left" Height="22" Margin="178,101,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="189" FontSize="16"/>-->
        <Button Name="Resetprofbutton" Content="Reset User Profile" HorizontalAlignment="Left" Margin="61,230,0,0" VerticalAlignment="Top" Width="134" Height="31" FontSize="16" RenderTransformOrigin="0.53,1.643"/>
        <Button Name="CancelButton" Content="Exit" HorizontalAlignment="Left" Margin="226,230,0,0" VerticalAlignment="Top" Width="114" Height="31" FontSize="16"/>
        <!--<TextBox Name="Outputbx" HorizontalAlignment="Left" Height="76" Margin="41,147,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="357" IsReadOnly="True"/>-->
        <CheckBox x:Name="CompNameCheckBox"  HorizontalAlignment="Left" Margin="374,64,0,0" VerticalAlignment="Top" FontSize="16"/>
        <!--<CheckBox x:Name="Useridcheckbox"  HorizontalAlignment="Left" Margin="374,103,0,0" VerticalAlignment="Top" FontSize="16" RenderTransformOrigin="1.125,5.667"/>-->
        <Label x:Name="Question" Content="Use Check box for deleting profile in VDI or UPM or both." HorizontalAlignment="Left" Margin="21,10,0,0" VerticalAlignment="Top" Width="436" FontWeight="Bold" FontSize="14"/>
        <Label x:Name="UserID" Content="User Id:" HorizontalAlignment="Left" Margin="41,93,0,0" VerticalAlignment="Top" Width="117" FontWeight="Bold" FontSize="16"/>
        <TextBox x:Name="useridtxtbx" HorizontalAlignment="Left" Height="22" Margin="178,99,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="189" FontSize="16"/>
        <Label Name="StaticVDIProfile" Content="Reset Static VDI Profile ? " HorizontalAlignment="Left" Margin="41,129,0,0" VerticalAlignment="Top" Width="232" FontWeight="Bold" FontSize="16"/>
        <Label x:Name="DynamicVDIProfile" Content="Reset Dynamic VDI Profile ? " HorizontalAlignment="Left" Margin="41,167,0,0" VerticalAlignment="Top" Width="232" FontSize="16" FontWeight="Bold"/>
        <CheckBox x:Name="StaticVDIProfileresetchkbox" Content="" HorizontalAlignment="Left" Margin="278,140,0,0" VerticalAlignment="Top"/>
        <CheckBox x:Name="DynamicVDIProfileresetchkbox" Content="" HorizontalAlignment="Left" Margin="278,177,0,0" VerticalAlignment="Top"/>
    </Grid>
</Window>
"@

$object = (New-Object System.Xml.XmlNodeReader $mybox)
$loadgui = [Windows.Markup.XamlReader]::Load( $object )

#cancel button
$cancelbutton = $loadgui.FindName("CancelButton")
$cancelbutton.Add_Click({ $loadgui.Close()})

#reset profile button
$Resetprofbutton = $loadgui.FindName("Resetprofbutton")
$Resetprofbutton.Add_Click({

#Get variables
$compnametxtbox = $loadgui.FindName("compnametxtbx")
$hostname = $compnametxtbox.Text
$userid = $loadgui.FindName("useridtxtbx")
$useridtext = $userid.Text

#remove registry entry and rename user profile folder in VDI.
$CompNameCheckBox = $loadgui.FindName("CompNameCheckBox")
if ($CompNameCheckBox.IsChecked -eq "True") {

$profremoteregistry = invoke-command -ComputerName $hostname -ScriptBlock { param ($useridtext )
    $value = Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList'
    foreach ($val in $value){ 
        if ($val.GetValue('profileimagepath') -like "C:\users\$useridtext") {Return $val}
    } 
} -ArgumentList $useridtext

reg delete \\$hostname\$profremoteregistry /f
Move-Item \\$hostname\c$\users\$useridtext  \\$hostname\c$\users\$useridtext.backup
[System.Windows.MessageBox]::Show('Resetting user profile on ' + $hostname + ' completed..')
}


#Assuming static profile folder name as win10-Static
#Assuming dynamic profile folder name as win10-dyn
#sample profile paths: \\Server\share\citrixprofiles\path\User1.UPM\win10-Static and \\Server\share\citrixprofiles\path\User1.UPM\win10-dyn
# Based on your profile folder structure, You can also use: if (Test-Path \\Server\share\citrixprofiles\path\$useridtext.UPM\win10-Static){ in below loop.

#reset static VDI profile
$StaticVDIProfileresetchkbox = $loadgui.FindName("StaticVDIProfileresetchkbox")

if ($StaticVDIProfileresetchkbox.IsChecked -eq "True") {

if (Test-Path \\Server\share\citrixprofiles\path\$useridtext\win10-Static){
    Rename-Item \\Server\share\citrixprofiles\path\$useridtext\win10-Static -NewName \\Server\share\citrixprofiles\path\$useridtext\old_win10-Static
    [System.Windows.MessageBox]::Show('Resetting Static VDI profile completed.')
    }
    else {
        [System.Windows.MessageBox]::Show('Static VDI profile folder not found.')
    }
}

#reset dynamic VDI profile
$DynamicVDIProfileresetchkbox = $loadgui.FindName("DynamicVDIProfileresetchkbox")

if ($DynamicVDIProfileresetchkbox.IsChecked -eq "True") {
if (Test-Path \\Server\share\citrixprofiles\path\$useridtext\win10-dyn){
    Rename-Item \\Server\share\citrixprofiles\path\$useridtext\win10-dyn -NewName \\Server\share\citrixprofiles\path\$useridtext\win10-dyn\old_win10-dyn
    [System.Windows.MessageBox]::Show('Profile Reset completed successfully.')
    }
    else {
        [System.Windows.MessageBox]::Show('Dynamic VDI profile not found.')
    }
}

})

#Hide powershell console.
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

$loadgui.showdialog() | Out-Null
```
