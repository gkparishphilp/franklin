module Franklin
	class UserInputsController < ApplicationAdminController


		def create
			@input = UserInput.new( user_input_params )
			@input.user = current_user
			@input.source = "#{controller_name}##{action_name}"

			@input.parse!

			redirect_back fallback_location: user_inputs_path
		end

		def index
			@inputs = UserInput.where( user: current_user ).order( created_at: :desc )
		end


		private
			def user_input_params
				params.require( :user_input ).permit( :content )
			end




	end


	
end