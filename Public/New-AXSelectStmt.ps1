Function New-AXSelectStmt
{
    <#

    .SYNOPSIS

    Allow user to run query against AX by passing in table name(s) and the select statement (X++ syntax). By default this query return an array of PSObjects. Each object contains the first 10 fields (per table) it can find.
    It is possible to specify which fields to include in the PSObject by passing in a comma seperated string to FieldList parameter (per table).    

    .EXAMPLE

    New-AXSelectStmt CustTable -stmt "SELECT * FROM %1"
    
    Customer account : 9100
    Name             : Mike Miller
    Address          : 
    Telephone        : 
    Fax              : 
    Invoice account  : 
    Customer group   : 90
    Line discount    : 
    Terms of payment : N007
    Cash discount    : 

    Customer account : Contoso
    Name             : Contoso Standard Template
    Address          : 
    Telephone        : 
    Fax              : 
    Invoice account  : 
    Customer group   : 80
    Line discount    : 
    Terms of payment : N010
    Cash discount    : 
    
    ...
    
    .EXAMPLE
    
    New-AXSelectStmt CustTable -stmt "SELECT * FROM %1 WHERE %1.CustGroup == '10'"
    
    Customer account : 1304
    Name             : Otter Wholesales
    Address          : 123 Peach Road Federal Way, WA 98003 US
    Telephone        : 123-555-0170
    Fax              : 321-555-0159
    Invoice account  : 
    Customer group   : 10
    Line discount    : 
    Terms of payment : P007
    Cash discount    : 

    Customer account : 9024
    Name             : Dolphin Wholesales
    Address          : 
    Telephone        : 111-555-0114
    Fax              : 111-555-0115
    Invoice account  : 
    Customer group   : 10
    Line discount    : 
    Terms of payment : N060
    Cash discount    : 
    
    ...
    
    .EXAMPLE
    
    New-AXSelectStmt SalesTable,SalesLine -stmt "SELECT * FROM %1 JOIN %2 WHERE %1.SalesId == %2.SalesId" -top 10 -fieldlists "SalesId,SalesName,CustAccount","SalesId,ItemId,SalesPrice,SalesQty,LineAmount" -showLabel
    
    Sales order      : SO-100005
    Name             : Contoso Retail Seattle
    Customer account : 3002
    Sales order_1    : SO-100005
    Item number      : 1151
    Unit price       : 62.21
    Quantity         : 12
    Net amount       : 746.52

    Sales order      : SO-100005
    Name             : Contoso Retail Seattle
    Customer account : 3002
    Sales order_1    : SO-100005
    Item number      : 1153
    Unit price       : 61.81
    Quantity         : 2
    Net amount       : 123.62
    
    ...
    #>
    [cmdletBinding()]
    param
    (
        [parameter(Mandatory=$true)] 
        [string[]] $tables,
        [string] $stmt,
        
        [parameter(Mandatory=$false)] 
        [string[]] $fieldLists,
        [string] $separator = ",",
        [string] $top = 0,
        [string] $numOfFields = 10,        
        [string] $company = "",
        [string] $language = "",
        [string] $aos = "",
        [string] $config = "",
        [switch] $showLabel
    )

    Try
    {
        $ax = Get-AXObject -company $company -language $language -aos $aos -config $config
        
        $tableBuffers = {@()}.Invoke()
        $tableList = $tables.split(",")
        foreach ($t in $tableList)
        {
            $buffer = $ax.CreateAxaptaRecord($t)
            $tableBuffers.Add($buffer)
        }

        $ax.ExecuteStmt($stmt,$tableBuffers)
            
        $list = {@()}.Invoke()      
        $recCount = 0

        Do { 
            $obj = New-Object PSObject; 
            if ($fieldlists.Count -eq 0 -or $fieldLists -eq $null)
            {
                for ([int] $j=0; $j -lt $tablebuffers.Count; $j++)
                {
                    $i = 1
                    $fieldCounts = 0
                    Do
                    {
                        if ($tableBuffers[$j].get_fieldLabel($i) -eq "UNKNOWN")
                        {
                            $i++
                            continue;
                        }

                        if ($showLabel)
                        {
                            $fieldLabel = $tableBuffers[$j].get_FieldLabel($i)
                            if ($obj.$fieldLabel -ne $null)
                            {
                                $fieldLabel = ($fieldLabel+"_"+$j)
                            }
                        }
                        else
                        {                                                        
                            $dictField = $ax.CreateAxaptaObject("SysDictField",$tableBuffers[$j].get_field("tableId"),$i)
                            $fieldLabel = $dictField.Call("name")
                            if ($obj.$fieldLabel -ne $null)
                            {
                                $fieldLabel = ($fieldLabel+"_"+$j)
                            }
                        }
                                                                        
                        $obj | Add-Member -Name $fieldLabel -Value $tableBuffers[$j].get_Field($i) -MemberType NoteProperty                        

                        $fieldCounts++
                        $i++
                    } while ($fieldCounts -lt $numOfFields)                                           
                } 
            }
            else
            {
                for ([int] $j=0; $j -lt $tablebuffers.Count; $j++)
                {
                    $fields = $fieldLists[$j].Split($separator)
                    Foreach ($f in $fields)
                    {
                        if ($tableBuffers[$j].get_fieldLabel($f) -eq "UNKNOWN")
                        {
                            continue;
                        }

                        if ($showLabel)
                        {
                            $fieldLabel = $tableBuffers[$j].get_FieldLabel($f)
                            if ($obj.$fieldLabel -ne $null)
                            {
                                $fieldLabel = ($fieldLabel+"_"+$j)
                            }
                        }
                        else
                        {
                            $fieldLabel = $f
                            if ($obj.$fieldLabel -ne $null)
                            {
                                $fieldLabel = ($fieldLabel+"_"+$j)
                            }                      
                        }
                        $obj | Add-Member -Name $fieldLabel -Value $tableBuffers[$j].get_Field($f) -MemberType NoteProperty;
                    }
                }
            }
            $list.Add($obj) 
            $recCount++
            if (($top -ne 0) -AND ($recCount -eq $top))
            {
                break
            }
        } while ($tableBuffers[0].Next())
        

        $list
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
