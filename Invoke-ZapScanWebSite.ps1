<#
    .Synopsis
    This script will call Start-Zap script to start active session of ZAP and will start spidering on given url
    .Example
    .\Invoke-ZapAttackWebsite [ZAP Folder path] [Url to attack]
    This will start the session of ZAP and will attack given http url.
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(
    #Zap.jar folder location 
    $path = "C:\Program Files (x86)\OWASP\Zed Attack Proxy",
    #Url on which ZAP operation will be performed(only http url)
    $URL =$(throw "Missing filepath value"),
    #use inScopeOnly=true if you have declared one or more contexts
    $scope="",
    #use recurse=true to scan the subtree
    $recurse="",
    #ZAP Proxy URI
    $proxy="http://localhost:8080",
    $sleep=1
)
&$PSScriptRoot\start-zap $path $proxy $sleep
[Reflection.Assembly]::LoadFile( `
    'C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.Web.dll')`
  | out-null    
$ZAPURL ="http://zap/JSON/spider/action/scan/?zapapiformat=JSON&url="+[System.Web.HttpUtility]::UrlEncode($URL) 
&$PSScriptRoot\Invoke-ZapApiRequest $ZAPURL $proxy| out-null
$status=0
$ZapResponseFlag=$true
while($status -ne '100' -and $ZapResponseFlag ){
    Start-Sleep -s $sleep
    $count +=1
    $Result=&$PSScriptRoot\Invoke-ZapApiRequest 'http://zap/JSON/spider/view/status/?zapapiformat=JSON' $proxy | ConvertFrom-Json
    $status=$Result.status
    if(!$status){
        $ZapResponseFlag=$false
    }
    else{
        write-progress -activity "Spidering in Progress" -status "$status% Complete:" -percentcomplete $status;
     }
}
if($status -ne 100 ){
    Write-host 'Spidering on ' $url ' aborted because ZAP API stopped responding.'
}
else{
    Write-Host 'Spidering on ' $url ' completed'
}
