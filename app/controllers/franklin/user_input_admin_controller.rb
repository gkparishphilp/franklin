module Franklin
	class UserInputAdminController < ApplicationAdminController
		before_action :set_input, only: [:show, :edit, :update, :destroy]
		
		def destroy
			@input.destroy
			redirect_to user_input_admin_index_path
		end

		def index
			by = params[:by] || 'created_at'
			dir = params[:dir] || 'desc'
			@inputs = UserInput.order( "#{by} #{dir}" )
			
			if params[:user].present?
				@inputs =  @inputs.where.( user_id: params[:user] )
			end

			@inputs = @inputs.page( params[:page] )

		end

		def update
			@input.update( input_params )

			redirect_to :back
		end


		private
			def input_params
				params.require( :input ).permit( )
			end

			def set_input
				@input = input.friendly.find( params[:id] )
			end
	end

end