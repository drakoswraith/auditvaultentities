$entities = vault read /identity/entity/name list=true -format=json | convertfrom-json
foreach($key in $entities.data.keys) { 
    #write-host $key
    $policies_from_groups = @()

    $e = vault read /identity/entity/name/$key -format=json | convertfrom-json
    $output = $key + ", " + $e.id
    $output = $output + "direct_policies[" + ($e.data.policies -join ',') + "]"

    $output = $output + ",group_ids["
    $groups = @()
    foreach($mg in $e.data.group_ids){
        $group = vault read /identity/group/id/$mg -format=json | convertfrom-json
        $groups += $group.data.name
        foreach($p in $group.data.policies) {
            If ($policies_from_groups -notcontains $p) { $policies_from_groups += $p }   
        }
    }
    $output = $output + ($groups -join ',') + "]"
    $output = $output + ",direct_group_ids["
    $groups = @()
    foreach($mg in $e.data.direct_group_ids){
        $group = vault read /identity/group/id/$mg -format=json | convertfrom-json
        $groups += $group.data.name
        foreach($p in $group.data.policies) {
            If ($policies_from_groups -notcontains $p) { $policies_from_groups += $p }   
        }
    }
    $output = $output + ($groups -join ',') + "]"
    $output = $output + ",inherited_group_ids["
    $groups = @()
    foreach($mg in $e.data.inherited_group_ids){
        $group = vault read /identity/group/id/$mg -format=json | convertfrom-json
        $groups += $group.data.name
        foreach($p in $group.data.policies) {
            If ($policies_from_groups -notcontains $p) { $policies_from_groups += $p }   
        }
    }
    $output = $output + ($groups -join ',') + "]"
    $output = $output + ",policies_from_groups[" + ($policies_from_groups -join ',') + "]"
    write-host $output
}
