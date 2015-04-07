<#
    .Synopsis
     This script will remove false positives so that the scan result has only vluable information.
    .DESCRIPTION
     Generated  alerts will be matched with the list of safe URL's and untrusted URL's will be marked
    .Example
     .\Remove-FalseZapPositive
    .Notes
    Author: Mrityunjaya Pathak
    Date : March 2015
#>
param(
    # List of safe URL's in sharepoint 
    $SharepointSafeList=""
)

invoke-webrequest -Uri ('http://zap/JSON/core/view/alerts/?zapapiformat=JSON&baseurl='+$URL+'&start=&count=') -Proxy $PROXY | select -expand content |Convertfrom-json|sv Alert
    
$Alert.alerts|select-object url,attack,alert,risk,reliablity|where{$_.alert -eq 'Cross-domain JavaScript source file inclusion'}| ft -AutoSize |sv HighAlert

Compare-Object -ReferenceObject $sharepointSafeList -DifferenceObject $HighAlert  -Property url |where {$_.SideIndicator -eq "=>"}| sv OtherUrl