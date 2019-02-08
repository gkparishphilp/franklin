module Franklin
	class UserInputsController < ApplicationController

		def create
			@input = UserInput.new( user_input_params )
			@input.user = current_user

			@input.save

			redirect_back fallback_location: new_user_input_path
		end


		private
			def user_input_params
				params.require( :user_input ).permit( :content )
			end




	end


	
end