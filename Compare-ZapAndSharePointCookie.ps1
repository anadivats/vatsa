<#
    .Synopsis
        
    .Outputs
        
    .Example
        
    .Notes
        Author: Mrityunjaya Pathak
        Date : Feb 2015
        
#>
param(
    $SITEURL=$(throw "Missing SITEURL value"),
    $PROXY="http://localhost:8080",
    [switch]$updateCookieHistory,
    $inputClixmlFilepath='../Results/CookieHistory.Clixml',
    $outputClixmlFilepath='../Results/CookieHistory.Clixml',
    $ComplainceErrorCliXmlPath=('../Results/ComplainceErrors/CookieComplainceErrors_'+ (get-date -format yyyyMMdd_HHmmss) + '.clixml')
   
)
$ErrorActionPreference="stop"
$DebugPreference="continue"

$script:SharePointCookie=@()
$script:CookieHistory=@()
$script:Errors=@()

function New-Error($zapCookie,$url,$SPCookie,$message) {
    $script:errors+=new-object psobject -Property @{
        zapCookie=$zapCookie
        url=$url
        SPCookie=$SPCookie
        message=$message
    }
}

#write-error "blah"

#throw "blah"

function Get-SharePointCookieFromZapName($zapCookie) {
    # Like coming from stores#lang to <site>#lang
    if (!$script:SharePointCookie.Count) {
        $script:SharePointCookie=.\Get-CookiesFromSharepoint
        write-host "-----------------" # just for prettying the output at this point
    }
    $result=@($script:SharePointCookie | where {$zapCookie.Name -match $_.CookieNameAsRegex})
    if ($result.count -eq 0) {
        $message="Zap cookie '$zapCookie.Name' not found in SharePoint"
        new-error $zapCookie.Name "" $_.url $null $message
        write-warning $message
        throw $message

    }
    elseif ($result.count -gt 1) {
        $message="Zap cookie '$zapCookie.Name' matches multiple regex'es - $($result)"
        new-error $zapCooki.eName  $_.url $result $message
        write-warning $message
        throw "Zap cookie '$zapCookie.Name' matches multiple regex'es - $($result)"
    }
    elseif (!$result.title) {
        $message="SharePoint cookie $result.name title is empty for the zap cookie '$ZapCooki.eName'"
        new-error $zapCookie.Name $result $_.url $null $message
        write-warning $message
        throw "SharePoint cookie title is empty for the zap cookie '$ZapCookie.Name'"
    }
    if($result.httponly -ne  $zapCookie.httponly)
    {
        # Todo: I would specify both values in the messages  -done
        $msg="SharePoint cookie $result.name HttpOnly doesn't match with cookie '$zapCookie.name'"
        new-error $zapCookie.name $result $zapCookie.url $null $msg
        write-warning $msg
        throw "SharePoint cookie title is empty for the zap cookie '$zapCookie.name'"
    }
    if($result.secure -ne  $zapCookie.secure)
    {
        # Todo: I would specify both values in the messages  --done
        $msg="SharePoint cookie $result.name Secure field doesn't match with cookie '$zapCookie.name'"
        new-error $zapCookie.name $result $zapCookie.url $null $msg
        write-warning  $msg
        throw "SharePoint cookie title is empty for the zap cookie '$zapCookie.name'"
    }
    Write-Debug "Matched '$zapCookie.Name' with $result"
    $result.title

}

function Import-CookieHistory() {
    if(Test-Path $inputClixmlFilepath){
      $script:CookieHistory+=Import-Clixml $inputClixmlFilepath
    }
    else{
        write-warning "$inputClixmlFilepath not found."
    }
    
}

function Export-CookieHistory() {
     $script:CookieHistory | Export-Clixml $outputClixmlFilepath
     Write-Debug "File Export completed to '$outputClixmlFilepath'"
    # export script variable to file (use a 'safe' location, as this is a 'database' (appdata\local\...)
}
function Export-ErrorFile() {
# todo: how does the caller know about this file and where to find it? At least put the filename formula into params
    $script:Errors| Export-Clixml $ComplainceErrorCliXmlPath
    Write-Debug "Complaince Errors exported to '$ComplainceErrorCliXmlPath'"
}

Filter Update-CookieHistory([switch]$passthru) {
    # todo: This is add and add to the history. That is fine, as long as we want to save all instances. Originally, I only wanted to save the last occurrance - however, we can also pick the last-seen at reporting time.
    
    if($_)
    {
        $_.CookieKey= $_.CookieKey +'_'+ $_.Name
        #$_.lastseen=get-date # todo: Can you get this date from the log file? That would be more precise. Alternatively, from the log files lastwritetimeutc
        $script:CookieHistory+=$_
        if($passthru.isPresent){
            $_
        }
    }
}

# todo: as we do not really care about the old values, we really only need the old values just before re-exporting them. You could create a Update-CookieHistoryDatabase script that Import-Cookiehistory, appends objects from the pipeline and Export-CookieHistory afterwards.
Import-CookieHistory

#G#et-SharePointCookieFromZapName blah
# todo: Avoid .\ notations --done
$here=split-path $myinvocation.mycommand.definition
&$here\Get-CookieFromZap $SITEURL $PROXY | sv zapCookie
$Cookies=$zapCookie | sort -Unique  CookieKey,lastSeen,Url,name,value,path,domain,httponly,secure |
    select *,@{name="SPName";exp={Get-SharePointCookieFromZapName $_}}|Update-CookieHistory -passthru


$Cookies | where {!$_.spname} | foreach {
    new-error $_.name $_.url $null "Cookie not documented in SharePoint (or not matched)"
}




# todo: It is ok to have functions use script params. However, it is more flexible to transfer the filename in the call, as the function can be used multiple times on different files should the need arise. Do not changes anything, this is only a hint
Export-CookieHistory
Export-ErrorFile



