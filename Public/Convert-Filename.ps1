Function Convert-FileName
{
    <#

    .SYNOPSIS

    Add date time suffix to filename

    .EXAMPLE

    Convert-Filename "proceess.log"
    
        \process_20151025_0423.log
    #>
    [cmdletBinding()]
    param
    (
        [parameter(Mandatory=$true)] [string] $fileLoc
    )

    $filePath = Split-Path $fileLoc
    $dateStr = Get-Date -Format "yyyyMMdd_hhmm"
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($fileLoc) + "_" + $dateStr
    $fileExt = [System.IO.Path]::GetExtension($fileLoc)
    $fileLoc = $filePath + "\" + $fileName + $fileExt

    $fileLoc
}