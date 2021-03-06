<#
    .Synopsis
        
    .Outputs
        
    .Example
        
    .Notes
        Author: Mrityunjaya Pathak
        Date : Feb 2015
        
#>
param(
    $Uri = 'http://collaboration-web.corp.lego.com/sites/OnlineComm/FA/SA/_vti_bin/lists.asmx?wsdl',
    $listNameOrGuid="Programs",
    $viewGuid=$null,
    $properties="*", #=@("ows_title","ows_description","ows_Perforce_x0020_Dept_x0020_Path"),
    [switch]$fixColumnNames
)
#$listNameOrGuid="{D5826CD7-48E1-417E-A9D9-56AAED180859}"
#$ViewGuid="{B3332EAD-DBD8-4D2E-B5E3-1$118D0AD0547}"
#$viewguid=$null
$count=0
while ($count -lt 5) { # overcome temporary out-of-service
    try {
        $SiteWS = New-WebServiceProxy -Uri $Uri -UseDefaultCredential #-Credential $Credential
        $list = $SiteWS.GetListItems($listNameOrGuid,$ViewGuid,$null,$null,$null,$null,$null)
        break
    }
    catch {
        write-warning "$_"
    }
    sleep 60
    $count++
}

$list.data.row | select $properties | foreach {
    if ($fixColumnNames.IsPresent) {
        $org=$_
        $obj=new-object psobject
        $_ | Get-Member -MemberType NoteProperty -Name ows_* | foreach {
            $name=$_.name -replace '^ows_+' -replace '_x0020_','_' -replace '_x002d_','_'
            Add-Member -InputObject $obj -MemberType NoteProperty -name $name -Value $org.$($_.name)
        }
        $obj
    }
    else {
        $_
    }
}
# use $list.data.row | get-member to see properties

# unplug plugin for perl/ps html at home page