# Logger

Usage:

```Powershell
. ".\Logger.ps1"

$Logger = New-Object Logger(".\","testrun", [LogLevel]::Debug)

$Logger.Log("Test 7", [LogLevel]::Debug)
```

A variation of the code from https://www.powershellgallery.com/packages/PoshBot/0.1.3/Content/Classes%5CLogger.ps1