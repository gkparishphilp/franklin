module Franklin
	class UserInputsController < ApplicationController


		def create
			@input = UserInput.new( user_input_params )
			@input.user = current_user

			@input.save

			@input.parse!

			redirect_back fallback_location: user_inputs_path
		end

		def index
			@inputs = current_user.user_inputs
		end


		private
			def user_input_params
				params.require( :user_input ).permit( :content )
			end




	end


	
end