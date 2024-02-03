$entities = vault read /identity/group/name list=true -format=json | convertfrom-json
foreach($key in $entities.data.keys) { 
    $g = vault read /identity/group/name/$key -format=json | convertfrom-json
    $output = $key + "`t" + $g.data.id + "\tpolicies[" + ($g.data.policies -join ',') + "]"

    $output = $output + "`tmember_entities["
    $groups = @()
    foreach($m in $g.data.member_entity_ids){
        $e = vault read /identity/entity/id/$m -format=json | convertfrom-json
        $groups += $e.data.name
    }
    $output = $output + ($groups -join ',') + "]"

    $output = $output + "`tmember_groups["
    $groups = @()
    foreach($mg in $g.data.member_group_ids){
        $group = vault read /identity/group/id/$mg -format=json | convertfrom-json
        $groups += $group.data.name
    }
    $output = $output + ($groups -join ',') + "]"
    write-output $output
}