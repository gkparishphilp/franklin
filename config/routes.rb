Franklin::Engine.routes.draw do

	resources 	:metric_admin
	resources 	:observation_admin
	resources 	:unit_admin
	resources 	:user_input_admin

	resources 	:observations
	resources 	:user_inputs

end
