<#
    .Synopsis
        
    .Outputs
        
    .Example
        
    .Notes
        Author: Mrityunjaya Pathak
        Date : Feb 2015
        
#>

param(
    $filePath=$(throw "Missing filepath value"),
    $outputCsv=$($env:temp + '\Get-CookieFromZapLog.csv'),
    $outputClixml=$($env:temp + '\Get-CookieFromZapLog.clixml'),
    [switch]$exportToCsv,
    $totalCount=[int64]::maxvalue,
    [switch]$exportToCliXMl
)
$lastWritten= [datetime](Get-ItemProperty -Path $filePath -Name LastWriteTime).lastwritetime
type $filePath -TotalCount $totalCount |
     foreach { 
        #write-host $_
        if ($_ -match 'insert into history values\((\d+,){6}''(?<verb>\w+)'',''(?<site>[^'']+)'',''(?<requestHeader>[^'']+)'',''(?<requestBody>[^'']*)'',''(?<responseHeader>[^'']+)'',''(?<responseBody>[^'']*)''') { 
        new-object psobject -prop @{ verb=$matches.verb; site=$matches.site; requestHeader=$matches.requestHeader; requestBody=$matches.requestBody;responseHeader=$matches.responseHeader;responseBody=$matches.responseBody; } } 
     }| 
     foreach {
         $reg=New-Object System.Text.RegularExpressions.Regex('\\u000d\\u000a',[System.Text.RegularExpressions.RegexOptions]::None)
         $url=$_.site
         
        $SetCookieObject= ($reg.Split($_.responseHeader)| where{$_ -match 'Set-Cookie:'}) -replace '^Set-Cookie: '
        $outputCookiesObject=@()
        $SetCookieObject| foreach {
            $line=$_ 
            $elements=$line -split ";" -replace '^ +' 
            $properties=@{} 
            $here=split-path $myinvocation.mycommand.definition
            $properties.CookieKey=  $url| &$here\ConvertTo-LEGOSiteName 
            $properties.lastSeen=$lastWritten
            $properties.URL=$url
            $elements | 
           
                #debug-pipeline -showvalue | 
                foreach {$c=0} { 
       
                    $name,$value=$_ -split "=",2 #| 
                        #debug-pipeline -showvalue 
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
            new-object psobject -Property $properties |sv p
            $outputCookiesObject+=$p
        } 
     }
     $cookies=$outputCookiesObject |select CookieKey,lastSeen,URL,name,value,expires,path,domain,httponly,secure|Sort-Object name #|get-unique name 
    if($exportToCsv.IsPresent){
        $cookies| export-csv  $outputCsv
    }
    elseif($exportToCliXMl.IsPresent){
        $cookies|Export-Clixml $outputClixml
    }
    else{
        $cookies
    }