<#
    .Synopsis
        
    .Outputs
        
    .Example
        
    .Notes
        Author: Mrityunjaya Pathak
        Date : Feb 2015
        
#>
param(
    $verifyEveryDays=300,
    $defaultAddress="mrityunjaya.pathak@lego.com",
    $fromAddress="ICM_Solution_Architecture-DL-4931@internal.lego.com",
    $overrideToAddress,
    [switch] $whatif,
    $outputClixml=$($env:temp + '\' + (split-path $MyInvocation.mycommand.definition) +  '.clixml'),
    [switch] $exportToCliXMl

)

$ErrorActionPreference="stop"
$VerbosePreference="continue"

trap {
  #  send-mailmessage -to "mrityunjaya.pathak@lego.com" -from "noreply-sa-sharepoint@lego.com" -SmtpServer smtp1.corp.lego.com -subject "$($MyInvocation.ScriptName): Check log file - ($_ | Out-String)"
  #  write-host "Script error: $($_ | Out-String)"
}

$here=split-path $myinvocation.mycommand.definition
$env:path+=";$here"

#$every=New-TimeSpan -Days $verifyEveryDays

$listid='{D5826CD7-48E1-417E-A9D9-56AAED180859}'
$listname='Shared%20Cookies'
$siteroot='http://collaboration-web.corp.lego.com'
$site="$siteroot/sites/OnlineComm/FA/SA"
$wsdl="$site/_vti_bin/lists.asmx?wsdl"

$viewguid='{B4AF7528-7230-4F74-945F-58072F161135}'


$items=Get-SharepointListItem $wsdl $listid -prop @('ows_title',"ows_id","ows_last_x0020_verified_x0020_at","ows_last_x0020_verified_x0020_by","ows_modified_x0020_by","ows_comments","ows_contains","ows_lifecycle_x0020_status","ows_CookieNameAsRegex") -fixColumnNames -viewguid $viewguid

filter BusinessRules{
    if (!$_.last_verified_by) {"Missing value in last verified by field"}
    if (!$_.last_verified_at) {"Missing value in last verified at field"}
    if ($_.last_verified_at -and [datetime]$_.last_verified_at -gt ((Get-Date).AddDays(2))) {"Last Verified at '$($_.last_verified_at)' is in the future. Please fix."}
    if (!$_.comments) {"Missing value in comments field"}
    if (!$_.contains) {"Missing value in contains field"}
    if ([datetime]$_.Last_Verified_at + $every -lt (get-date)) {
        "Verify documentation of cookie ($verifyEveryDays days rule). Reassign if needed"
    }

}

$items = $items | foreach {
    if ($_.CookieNameAsRegex) {
        $_
    }
    else {
        write-warning "Cookie $($_.title) is missing the regex value. Item discarded"
    }
} | select title,CookieNameAsRegex,@{name="Url";expression={"$site/lists/$listname/dispform.aspx?ID=$($_.id)"}}

if ($exportToCliXMl.IsPresent) {
    $items | export-clixml $outputClixml
}
else {
    $items
}

