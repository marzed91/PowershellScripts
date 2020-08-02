enum LogLevel {
    Normal
    Debug
}

class Logger
{
    [string]$LogDir
    [string]$LogName
    [LogLevel]$LogLevel
    [int]$MaxFileSizeMB = 5
    [int]$FilesToKeep = 5

    hidden [string]$LogFile

    Logger([string]$LogDir, [string]$LogName, [LogLevel]$LogLevel){
        $this.LogDir = $LogDir
        $this.LogName = $LogName
        $this.LogLevel = $LogLevel
        $this.LogFile = Join-Path -Path $LogDir -ChildPath "$($LogName).txt"
        $this.CreateLogFile()
    }

    hidden [void]CreateLogFile(){
        if(Test-Path -Path $this.LogFile) {
            $this.RollLog()
        } else {
            Write-Debug -Message "[Logger:Logger] Creating log file [$($this.LogFile)]"
            New-Item -Path $this.LogFile -ItemType File -Force
        }
    }

    hidden [void]RollLog(){
        if(Test-Path -Path $this.LogFile){
            if(($file = Get-Item -Path $this.LogFile) -and ($file.Length/1mb) -gt $this.MaxFileSizeMB){
                # Current LogFile has exceeded max file size ...
                $LastLogFile = "$($this.LogFile.Substring(0,$this.LogFile.Length - 4))_$($this.FilesToKeep).txt"
                if(Test-Path -Path $LastLogFile){
                    # Max number of log files reached, delete oldest one
                    Remove-Item -Path $LastLogFile
                }

                foreach($i in $($this.FilesToKeep)..1){
                    $IthLogFile = "$($this.LogFile.Substring(0,$this.LogFile.Length - 4))_$($i).txt"
                    $IthPrevLogFile = "$($this.LogFile.Substring(0,$this.LogFile.Length - 4))_$($i-1).txt"
                    if(Test-Path -Path $IthPrevLogFile){
                        Move-Item -Path $IthPrevLogFile -Destination $IthLogFile
                    }
                }
                Write-Debug "[Logger:Logger] Renaming current Logfile '$this.LogFile' to '$($this.LogFile.Substring(0,$this.LogFile.Length - 4))_$($i).txt)'"
                Move-Item -Path $this.LogFile -Destination "$($this.LogFile.Substring(0,$this.LogFile.Length - 4))_$($i).txt"
                $null = New-Item -Path $this.LogFile -Type File -Force | Out-Null
            }
        }
    }

    [void]Log([string]$Message, [LogLevel]$LogLevel){
        if($LogLevel.value__ -le $this.LogLevel.value__){
            $Date = (Get-Date).toString("dd/MM/yyyy HH:mm:ss")
            "[$($Date)]: $($Message)" | Add-Content -Path $this.LogFile
        }
    }
}