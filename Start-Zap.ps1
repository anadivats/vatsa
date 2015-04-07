<#
    .Synopsis
    This script will start the  session of ZAP
    .Example
    .\Start-Zap [ZAP Folder path] [Url to attack]
    This will start the session of ZAP and will attack given http url.
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(
    #Zap.jar folder location 
    $path = "C:\Program Files (x86)\OWASP\Zed Attack Proxy",
    #ZAP Proxy URI
    $proxy='http://localhost:8080',
    $sleep=1,
    #Maximum Wait Time for ZAP
    $MaxWaitTime=100
)
$ErrorActionPreference="stop"
&$PSScriptRoot\stop-zap $proxy $sleep
start-sleep -s $sleep
Push-Location $path
.\zap.jar 
Pop-Location 
$count=0
$status=0
while(!($status.StatusCode -eq 200) -and ($count -le $MaxWaitTime)){
   
    $count +=1
    $status=&$PSScriptRoot\Invoke-ZapApiRequest 'http://zap/' $proxy
    Write-Host 'o'
    Start-Sleep -s $sleep
}

if($count -eq $MaxWaitTime){
    Write-Error "Zap unable to start"
}
else{
    &$PSScriptRoot\Invoke-ZapApiRequest 'http://zap/JSON/core/action/newSession/?zapapiformat=JSON&name=&overwrite=' $proxy |Out-Null
}
start-sleep -s $sleep