<#
    .Synopsis
        This script will give alert count from Zap. 
    .Outputs
        Script will give number of alert count from zap
    .Example
        .\Get-AlertCount
    .Notes
        Author: Mrityunjaya Pathak
        Date : Mar 2015
        
#>

param(
 $SITEURL=$(throw "Missing filepath value"),
 $PROXY="http://localhost:8080"
)
$ZapURL="http://zap/JSON/core/view/numberOfAlerts/?zapapiformat=JSON&baseurl=" + $url
&$PSScriptRoot\Invoke-ZapApiRequest $ZapURL $PROXY | select -expand content | ConvertFrom-Json |sv AlertCount
$AlertCount.numberOfAlerts