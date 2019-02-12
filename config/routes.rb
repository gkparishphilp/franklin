Franklin::Engine.routes.draw do

	resources 	:food_admin
	resources 	:metric_admin
	resources 	:nutrient_admin
	resources 	:observation_admin
	resources 	:unit_admin
	resources 	:user_input_admin

	resources 	:observations
	resources 	:user_inputs

end
