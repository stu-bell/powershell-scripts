# Powershell Execution Policy

The first time you try to run a Powershell script on your machine, you may be presented with an error preventing you from running scripts due to the execution poilcy set on your machine. PowerShell's execution policy is a safety feature that helps prevent the accidental execution of malicious scripts.

```

File cannot be loaded because running scripts is disabled
on this system. For more information, see about_Execution_Policies at https:/go.microsoft.com/fwlink/?LinkID=135170
```

To run scripts, you'll need to change the execution policy.

> RUNNING SCRIPTS CARRIES RISK. ALWAYS REVIEW SCRIPTS BEFORE RUNNING THEM ON YOUR SYSTEM.
> IF IN DOUBT, COPY AND PASTE THE SCRIPT INTO A SERVICE LIKE CHATGPT AND ASK IF IT COULD BE HARMFUL.

See [Microsoft Learn | About Execution Policies](https:/go.microsoft.com/fwlink/?LinkID=135170) for the official documentation on execution policies.

Example to set the execution policy to RemoteSigned for the current user: 

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

```

