<#
    .Synopsis
    This script will give alerts from ZAP 
    .Example
    .\Get-AlertfromZap        
    .Notes
     Author: Mrityunjaya Pathak
     Date : Feb 2015
        
#>
param(
 #Url on which ZAP operation will be performed(only http url)
 $URL=$(throw "Missing filepath value"),
 #ZAP Proxy URI
 $PROXY="http://localhost:8080",
 $AlertCount=99
)

$count=0
$TotalAlerts=@()

while($count -lt $AlertCount)
{
    $ZapURL="http://zap/JSON/core/view/alerts/?zapapiformat=JSON&baseurl="+$URL+"&start="+$count+"&count=5"
    &$PSScriptRoot\Invoke-ZapApirequest $ZapURL -Proxy $PROXY | select -expand content |Convertfrom-json|sv alerts
    $count+=5
    $TotalAlerts+=$alerts
    $status=[math]::round(($count/$AlertCount)*100,2)
     write-progress -activity "Getting report from zap scan " -status "$status% Complete:" -percentcomplete $status;
}
$TotalAlerts.Alerts