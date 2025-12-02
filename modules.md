# Prevent a script from running without the required module dependencies

Add the comment at the top of the script: 

```
#Requires -Modules <Module-Name>
```

Running the script without the required modules available will cause an error and prevent the script from running.

See [Microsoft Learn | About Requires](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about)requires?view=powershell-7.5&viewFallbackFrom=powershell-7.3_

