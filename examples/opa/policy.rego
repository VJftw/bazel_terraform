package terraform

import input as tfplan

deny[msg] {
	# deny when created resource is `null_resource.i_am_a_bad_resource`
	created_addresses := {address |
		resource := resources_per_action("create")[_]
		address := resource.address
	}

	some address
	created_addresses[address]

    address == "null_resource.i_am_a_bad_resource"

	msg := sprintf("'%s' is planned for create but is bad for some reason", [address])
}

# utils

resources_per_action(action) = resources {
	resources := [resource |
		resource := tfplan.resource_changes[_]

		# conditions
		resource.change.actions[_] == action
	]
}
