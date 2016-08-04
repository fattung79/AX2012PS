Function Get-AXInfo
{    
    <#

    .SYNOPSIS

    Get information about the AOS connected to

    .EXAMPLE

    Get-AXInfo
    
    AOS     : AX5-W8-01
    Build No: 1500.2985
    Instance: 01
    Port    : 2712
    
    #>
    [cmdletBinding()]
    param
    (        
        [parameter(Mandatory=$false)] [string] $company = "",
        [parameter(Mandatory=$false)] [string] $language = "",
        [parameter(Mandatory=$false)] [string] $aos = "",
        [parameter(Mandatory=$false)] [string] $config = ""        
    )

    Try {    
        $ax = Get-AXObject -company $company -language $language -aos $aos -config $config

        $xSession = $ax.CreateAxaptaObject("XSession")
        "AOS     : " + $xSession.call("AOSName")     
    
        $xApplication = $ax.CreateAxaptaObject("XApplication")   
        "Build No: " + $xApplication.call("buildNo")           
        "Instance: " + $ax.CallStaticClassMethod("Session", "getAOSInstance")     
        "Port    : " + $ax.CallStaticClassMethod("Session", "getAOSPort") 
    } 
    Catch [System.Exception]
    {
        "Caught an Exception"
        $_.Exception|format-list -force
    } 
    Finally 
    {
        if($ax -ne $null -and (-not $ax.Logoff()))
        {
            $Global:logOffAXFailed
        }
    }
}