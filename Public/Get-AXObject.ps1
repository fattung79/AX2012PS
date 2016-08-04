Function Get-AXObject
{
    <#

    .SYNOPSIS

    Create a Microsoft.Dynamics.BusinessConnector.Axapta object, login to AX and returns the object. A client configuration file (.axc) named AX2009.axc should be put available the module's folder.
    The Microsoft.Dynamics.BusinessConnectorNet.dll should also be put in the folder 

    .EXAMPLE

    $ax = Get-AXObject | Get-Member    
    
       TypeName: Microsoft.Dynamics.BusinessConnectorNet.Axapta

    Name                         MemberType Definition                                                                                                                                                                     
    ----                         ---------- ----------                                                                                                                                                                     
    CallJob                      Method     System.Void CallJob(string jobName, Microsoft.Dynamics.BusinessConnectorNet.AxaptaObject argsObject), System.Void CallJob(string jobName)                                      
    CallStaticClassMethod        Method     System.Object CallStaticClassMethod(string className, string methodName, System.Object param1, System.Object param2, System.Object param3), System.Object CallStaticClassMet...
    CallStaticRecordMethod       Method     System.Object CallStaticRecordMethod(string recordName, string methodName, System.Object param1, System.Object param2, System.Object param3), System.Object CallStaticRecord...
    CreateAxaptaBuffer           Method     Microsoft.Dynamics.BusinessConnectorNet.AxaptaBuffer CreateAxaptaBuffer()                                                                                                      
    CreateAxaptaContainer        Method     Microsoft.Dynamics.BusinessConnectorNet.AxaptaContainer CreateAxaptaContainer()                                                                                                
    CreateAxaptaObject           Method     Microsoft.Dynamics.BusinessConnectorNet.AxaptaObject CreateAxaptaObject(string className, System.Object param1, System.Object param2, System.Object param3), Microsoft.Dynam...
    CreateAxaptaRecord           Method     Microsoft.Dynamics.BusinessConnectorNet.AxaptaRecord CreateAxaptaRecord(string recordName), Microsoft.Dynamics.BusinessConnectorNet.AxaptaRecord CreateAxaptaRecord(int reco...
    Dispose                      Method     System.Void Dispose()                                                                                                                                                          
    Equals                       Method     bool Equals(System.Object obj)                                                                                                                                                 
    ExecuteStmt                  Method     System.Void ExecuteStmt(string statement, Microsoft.Dynamics.BusinessConnectorNet.AxaptaRecord param1, Microsoft.Dynamics.BusinessConnectorNet.AxaptaRecord param2, Microsof...
    GetBufferCount               Method     int GetBufferCount()                                                                                                                                                           
    GetContainerCount            Method     int GetContainerCount()                                                                                                                                                        
    GetHashCode                  Method     int GetHashCode()                                                                                                                                                              
    GetLoggedOnAxaptaObjectCount Method     int GetLoggedOnAxaptaObjectCount()                                                                                                                                             
    GetObject                    Method     Microsoft.Dynamics.BusinessConnectorNet.AxaptaObject GetObject(string objectName)                                                                                              
    GetObjectCount               Method     int GetObjectCount()                                                                                                                                                           
    GetRecordCount               Method     int GetRecordCount()                                                                                                                                                           
    GetType                      Method     type GetType()                                                                                                                                                                 
    Logoff                       Method     bool Logoff()                                                                                                                                                                  
    Logon                        Method     System.Void Logon(string company, string language, string objectServer, string configuration)                                                                                  
    LogonAs                      Method     System.Void LogonAs(string user, string domain, System.Net.NetworkCredential bcProxyCredentials, string company, string language, string objectServer, string configuration)   
    LogonAsGuest                 Method     System.Void LogonAsGuest(System.Net.NetworkCredential bcProxyCredentials, string company, string language, string objectServer, string configuration)                          
    Refresh                      Method     System.Void Refresh()                                                                                                                                                          
    Session                      Method     int Session()                                                                                                                                                                  
    ToString                     Method     string ToString()                                                                                                                                                              
    TTSAbort                     Method     System.Void TTSAbort()                                                                                                                                                         
    TTSBegin                     Method     System.Void TTSBegin()                                                                                                                                                         
    TTSCommit                    Method     System.Void TTSCommit()                                                                                                                                                        
    HttpContextAccessible        Property   System.Boolean HttpContextAccessible {get;}    
    #>
    
    [cmdletBinding()]
    param
    (        
        [parameter(Mandatory=$false)] [string] $company = $defaultCompany,
        [parameter(Mandatory=$false)] [string] $language = "",
        [parameter(Mandatory=$false)] [string] $aos = "",
        [parameter(Mandatory=$false)] [string] $config = ""      
    )
    
    if ([Environment]::Is64BitProcess)
    {
        Throw "Powershell must be running as 32bit process to access AX."
    }

    #region Setup DLL
    #$tempPath = "C:\temp"

    $wmi = Get-WmiObject -Class win32_computersystem -ComputerName localhost
    $hostname = $wmi.DNSHostName
    #$axcName = "\USR_AX2012_PROD.axc"
    #$dllName = "\Microsoft.Dynamics.BusinessConnectorNet.dll"
    $modPath = (Get-Module AX2009PS).ModuleBase
    $fullPath = $modPath + $dllName    
    $targetPath = $tempPath + $dllName

    if (-Not (Test-Path($targetPath)))
    {
        Copy-Item $fullPath $tempPath | Out-Null
    }    

    $axcPath = $modPath + $axcName
    $axcTargetPath = $tempPath + $axcName
    if (-Not (Test-Path($axcTargetPath)))
    {
        Copy-Item $axcPath $tempPath | Out-Null
    }

    [reflection.Assembly]::Loadfile($targetPath) | Out-Null
    #endregion    

    $ax = new-object Microsoft.Dynamics.BusinessConnectorNet.Axapta
    if ($config -eq "")
    {
        $config = $axcTargetPath
    }
    $ax.logon($company,$language,$aos,$config)

    return $ax
}