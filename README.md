# Citrix VDI Profile Reset Tool

Simple Tool to reset citrix profiles.

## Description

This tool allows you to reset user's profile on VDI, and/or on UPM profile.

### Prerequisites

PowerShell Remoting to be enabled on user's VDI.

### Installing

No installation required. This is standalone Tool. 

### Usage

* Modify UPM profile path in the script [Profile Reset Tool.ps1](https://github.com/TechScripts/Citrix-VDI-Profile-Reset-Tool/blob/master/Profile%20Reset%20Tool.ps1)
* Using ps2exe (link given in Built with section in this page) convert it to exe and double click it.
* Enter computer name and user id. Check the checkbox for static VDI profile or dynamic VDI profile or both and click reset user profile button.

### How does this tool work

* when computer name checkbox is checked, it connects to the VDI and identifies user profile path and :
    * Removes registry entry for the user id given.
    * Renames user profile folder in c:\users folder to c:\users\username.backup.
* When Static VDI Profile checkbox is checked, it renames user's profile in the UPM path given in the script.
* When dynamic VDI profile checkbox is checked, it renames user's profile in the UPM path given in the script.

### Image

![Alt Text](https://github.com/TechScripts/Citrix-VDI-Profile-Reset-Tool/blob/master/Profile-Reset-Tool-Image.png)

### Who can use

Primary target is for helpdesk and desktop support admins for resetting profiles on citrix VDIs. Can be used directly or published via citrix.

### Built With

* [PowerShell](https://en.wikipedia.org/wiki/PowerShell) - Powershell
* [XML](https://en.wikipedia.org/wiki/XML) - Used to generate GUI
* [PS2EXE-GUI](https://gallery.technet.microsoft.com/scriptcenter/PS2EXE-GUI-Convert-e7cb69d5) - Used to convert script to exe

### Authors

* **Chay** - [ChayScripts](https://github.com/ChayScripts)

### Contributing

Please follow [github flow](https://guides.github.com/introduction/flow/index.html) for contributing.

### License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
