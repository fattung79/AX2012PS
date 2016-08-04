Function Get-AXEnum
{
    <#

    .SYNOPSIS

    Create and returns an DictEnum object based on passed in Axapta object [initiated and connected] and the name of the Enum

    .EXAMPLE

    $ax = Get-AXObject
    $enumABC = Get-Enum $ax "ABC"
    
    $enumABC.Call("name2Value","A")
    1
    
    #>
    
    param(        
        [Parameter(Mandatory = $true)]
        [Microsoft.Dynamics.BusinessConnectorNet.Axapta] $ax,
        
        [Parameter(Mandatory = $true)]
        [String] $enumName
    )

    $EnumObjNum = $ax.CallStaticClassMethod("Global","Enumname2id",$enumName)
    $EnumObj = $ax.CreateAxaptaObject("DictEnum",$EnumObjNum)

    $EnumObj
}