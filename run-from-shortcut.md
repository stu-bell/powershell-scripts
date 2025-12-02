# Run Powershell scripts from a shortcut

These instructions detail how to create a Windows Explorer shortcut to launch Powershell scripts. 

> ALWAYS REVIEW SCRIPTS WRITTEN BY OTHERS BEFORE RUNNING THEM ON YOUR SYSTEM. 

1. Save your script as a file and ensure the file name ends with file extension .ps1
If you can't see the file extension for file names, view them by following [these instructions](https://support.microsoft.com/en-gb/windows/common-file-name-extensions-in-windows-da4a4430-8e76-89c5-59f7-1cdbbc75cb01).

2. Right click the powershell ps1 file in Windows Explorer > Create Shortcut (or Right click > Show More Options > Create Shortcut).

3. Right click the shortcut you just created > Properties > Target. The target is the file path to your script. Paste the following text BEFORE the path to your script file:

```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit -File 
```

So you should end up with something like:

```
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -NoExit -File C:\Users\yourusername\path\to\script.ps1
```

> Note that there should be a space between -File and the start of your file path

<img src="./imgs/ShortcutProperties.png" width="500">

4. Clicking the shortcut you've just created will execute the script. Clicking the original script file will allow you to modify the script text. 

The icon of the shortcut may change to something like: 

<img src="./imgs/ShortcutIcon.png" width="500">

> If you move the script file to a new folder after creating the shortcut, you'll need to recreate the shortcut so it points to the file's new location. 

## Passing arguments to your script

If the script you're creating a shortcut for requires certain arguments, paste them after the file path.

## -NoExit

The `-NoExit` flag in the shorcut command tells Powershell to keep the terminal open after the script has finished. This might be useful in case there are error messages, or you'd like to check the script output before it closes. However, if you have a script that you know runs well and just want the terminal window to close automatically after the script completes, remove the -NoExit flag from the shortcut target.

