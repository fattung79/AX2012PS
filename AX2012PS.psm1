$Global:logOffAXFailed = "-- Failed to log off AX Session --"
#$Global:defaultCompany = "usmf"
$Global:tempPath = "C:\Temp"
$Global:axcName = "\USR_AX2012_PROD.axc"
$Global:dllName = "\Microsoft.Dynamics.BusinessConnectorNet.dll"

# Setup script path
$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

#region Load Public Functions
Try {
    Get-ChildItem "$ScriptPath\Public" -Filter *.ps1 -Recurse | Select -Expand FullName | ForEach {
        $Function = Split-Path $_ -Leaf
        . $_
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}
#endregion Load Public Functions
