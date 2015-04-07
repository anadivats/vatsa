<#
    .Synopsis
     This Script will Generate Report of Spidering from ZAP and will Get cookies from ZAP
    .Example
     .\Report-ZapScanWebSite
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param( 
    #Url on which ZAP operation will be performed(only http url)
    $URL =$(throw "Missing filepath value"),
    #ZAP Proxy URI    
    $proxy="http://localhost:8080"
)

&$PSScriptRoot\Get-CookieFromZap $URL $proxy |sv Reportscan
$Reportscan | export-clixml 'Cookies.clixml'
