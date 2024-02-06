$entities = vault read /identity/entity/name list=true -format=json | convertfrom-json
foreach($key in $entities.data.keys) { 
    #write-host $key
    $policies_from_groups = @()
    $output = "name`tid`taliases`tdirect assigned policies`tassigned groups`tinherited groups`tpolicies from all groups"
    $e = vault read /identity/entity/name/$key -format=json | convertfrom-json
    $output = $key + "`t" + $e.id
    $output = $key + "`t"

    $output = $output + "`taliases["
    $aliases = @()
    foreach($alias in $e.data.aliases){
        $a = $alias.mount_path + $alias.name
        $aliases += $a
    }
    $output = $output + ($aliases -join ',') + "]"
    $output = $output + "`tdirect_policies[" + ($e.data.policies -join ',') + "]"
    $output = $output + "`tgroup_ids["
    $groups = @()
    foreach($mg in $e.data.group_ids){
        $group = vault read /identity/group/id/$mg -format=json | convertfrom-json
        $groups += $group.data.name
        foreach($p in $group.data.policies) {
            If ($policies_from_groups -notcontains $p) { $policies_from_groups += $p }   
        }
    }
    $output = $output + ($groups -join ',') + "]"
    $output = $output + "`tdirect_group_ids["
    $groups = @()
    foreach($mg in $e.data.direct_group_ids){
        $group = vault read /identity/group/id/$mg -format=json | convertfrom-json
        $groups += $group.data.name
        foreach($p in $group.data.policies) {
            If ($policies_from_groups -notcontains $p) { $policies_from_groups += $p }   
        }
    }
    $output = $output + ($groups -join ',') + "]"
    $output = $output + "`tinherited_group_ids["
    $groups = @()
    foreach($mg in $e.data.inherited_group_ids){
        $group = vault read /identity/group/id/$mg -format=json | convertfrom-json
        $groups += $group.data.name
        foreach($p in $group.data.policies) {
            If ($policies_from_groups -notcontains $p) { $policies_from_groups += $p }   
        }
    }
    $output = $output + ($groups -join ',') + "]"
    $output = $output + "`tpolicies_from_groups[" + ($policies_from_groups -join ',') + "]"
    write-output $output
}
