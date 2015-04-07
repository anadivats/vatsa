<#
    .Synopsis
      This Script will get ZAP messages and will filter out cookies from messages  
    .Example
      .\Get-CookiesFromZap  
    .Notes
        Author: Mrityunjaya Pathak
        Date : Feb 2015
        
#>
param(
 #Url on which ZAP operation will be performed(only http url)
 $URL=$(throw "Missing filepath value"),
 #ZAP Proxy URI
 $PROXY="http://localhost:8080"
)
 $lastWritten= get-date 
 $here=split-path $myinvocation.mycommand.definition
 $MessageCount =&$here\Get-MessageCount $SITEURL $PROXY
 $TotalMessages=&$here\Get-MessageFromZap $SITEURL $PROXY $MessageCount
 $TotalMessages | foreach{
        $url=($_.requestHeader -split "`n" -replace "`r" |where {$_ -match '^GET '}) -replace '^GET ' -replace '\shttp/\d\.\d$'
        $SetCookieObject=($_.responseHeader -split "`n" -replace "`r"| where{$_ -match 'Set-Cookie:'}) -replace '^Set-Cookie: '
        $SetCookieObject| foreach {
            $line=$_ 
            $elements=$line -split ";" -replace '^ +' 
            $properties=@{} 
            $here=split-path $myinvocation.mycommand.definition
            $properties.CookieKey=  $url| &$here\ConvertTo-LEGOSiteName 
            $properties.lastSeen=$lastWritten
            $properties.URL=$url
            $elements | 
                foreach {$c=0} { 
       
                    $name,$value=$_ -split "=",2 
                    if ($c -eq 0) { 
                        $properties.name=$name 
                        $properties.value=$value 
                    } 
                    elseif ($name -eq "expires") { 
                        $properties.$name=[datetime]$value 
                    } 
                    else { 
                        $properties.$name=$value 
                    } 
                    $c++ 
                } 
            new-object psobject -Property $properties 
        } 
} |select CookieKey,lastSeen,URL,name,value,expires,path,domain,httponly,secure|Sort-Object name |sv cookies
$cookies