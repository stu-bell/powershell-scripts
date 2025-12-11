# PowerShell Profile

Your PowerShell Profile is a .ps1 file that is executed on each shell session start. It's a bit like .bashrc file on Linux. 

It can be used for adding custom commands and aliases.

Because it is run each shell session start, it should be quick to run. 

See [Microsoft Learn | About Profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.5)

To edit a profile: [Microsoft Learn | Edit Profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.5#how-to-edit-a-profile)

The path to where PowerShell looks for your profile is $PROFILE - note, this file may not exist yet, in which case, you can create it: [Microsoft Learn | Create Profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.5#how-to-create-a-profile)

My profile file is in [profile](/profile), which is symlinked from my $PROFILE folder

