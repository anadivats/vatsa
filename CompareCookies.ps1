<#
    .Synopsis
        
    .Outputs
        
    .Example
        
    .Notes
        Author: Mrityunjaya Pathak
        Date : Feb 2015
        
#>


param($filePath=$(throw "Missing filepath value"))
$here=split-path $myinvocation.mycommand.definition
&$here\cookies $filePath -exportToCliXMl
