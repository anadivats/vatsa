<#
    .Synopsis
    This script will give messages from ZAP 
    .Example
    .\Get-MessagefromZap        
    .Notes
     Author: Mrityunjaya Pathak
     Date : Feb 2015
        
#>
param(
 #Url on which ZAP operation will be performed(only http url)
 $URL=$(throw "Missing filepath value"),
 #ZAP Proxy URI
 $PROXY="http://localhost:8080",
 $MessageCount=99
)

$count=0
$TotalMessages=@()

while($count -lt $MessageCount)
{
    invoke-webrequest -Uri ('http://zap/JSON/core/view/messages?url='+ $SITEURL +'&start='+$count+'&count=5') -Proxy $PROXY | select -expand content |Convertfrom-json|sv messages
    $count+=5
    $TotalMessages+=$messages
    $status=($count/$MessageCount)*100
     write-progress -activity "Getting report from zap scan " -status "$status% Complete:" -percentcomplete $status;
}
$TotalMessages.messages