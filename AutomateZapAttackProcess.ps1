
<#
    .Synopsis
     This script will be the parent script all ZAP scripts will be called form This scripts    
    .Example
     .\AutomateZapAttackProcess
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(
    #Url on which ZAP operation will be performed(only http url)
    $url="",
    #Zap.jar folder location 
    $path = "C:\Program Files (x86)\OWASP\Zed Attack Proxy",
    #ZAP Proxy URI
    $proxy='http://localhost:8080',
    $sleep=1,
    #Maximum wait time for ZAP
    $MaxWaitTime=100
)
$ErrorActionPreference="stop"
&$PSScriptRoot\Invoke-ZapScanWebSite -url $url
&$PSScriptRoot\Report-ZapScanWebSite $url
&$PSScriptRoot\Invoke-ZapAttackWebsite $url
&$PSScriptRoot\Report-ZapAttackWebSite $url

