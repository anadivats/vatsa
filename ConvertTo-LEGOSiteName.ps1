<#
    .Synopsis
        
    .Outputs
        
    .Example
        
    .Notes
        Author: Mrityunjaya Pathak
        Date : Feb 2015
        
#>
begin {
    if($args.Count){
        throw "Arguments not allowed"    
    }
    $subsInWWW=&{$args} products,news
}
process {

    if ($_ -match 'https?://(?<domain>[^/]+)/(?<locale>\w\w-\w\w)/(?<sub>\w+)') {
        if ($subsInWWW -contains $matches.sub) {
            $matches.domain
        }
        else {
            $matches.domain + "/" + $matches.sub
        }
    }
    elseif ($_ -match 'https?://(?<domain>[^/]+)/(?<locale>\w\w-\w\w)/?$') {
        $matches.domain
    }
    else {
        "nomatch- $_"
    }

}
