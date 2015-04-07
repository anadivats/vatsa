<#
    .Synopsis    
     This Script will Generate Report of Active Scan from ZAP and will contain url,attack,alert,risk,reliablity.
    .Example
     .\Report-ZapAttackWebSite
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(
    #Url on which ZAP operation will be performed(only http url)
    $URL =$(throw "Missing filepath value"),
    #ZAP Proxy URI    
    $proxy="http://localhost:8080",
    $start="",
    $count=""
)
$AlertCount= &$PSScriptRoot\Get-AlertCount $url
&$PSScriptRoot\Get-AlertFromZap $URL $PROXY $AlertCount  | sv Alert
$Alert|select-object url,attack,alert,risk,reliablity,@{name="Cross-Site";e={$_.param}}|where{$_.alert -eq 'Cross-domain JavaScript source file inclusion'}|sv ReportAlert 
$ReportAlert|Export-Clixml 'CrossSiteScript.Clixml'

