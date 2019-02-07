module Franklin
	class ObservationAdminController < ApplicationAdminController
		before_action :set_observation, only: [:show, :edit, :update, :destroy]
		
		def create
			@observation = Observation.new( observation_params )
			@observation.save
			redirect_to edit_observation_admin_path( @observation )
		end

		def destroy
			@observation.destroy
			redirect_to observation_admin_index_path
		end

		def index
			by = params[:by] || 'title'
			dir = params[:dir] || 'asc'
			@observations = Observation.order( "#{by} #{dir}" )
			
			if params[:user].present?
				@observations =  @observations.where.( user_id: params[:user] )
			end

			@observations = @observations.page( params[:page] )

		end

		def update
			@observation.update( observation_params )

			redirect_to :back
		end


		private
			def observation_params
				params.require( :observation ).permit( :parent_obj_id, :parent_obj_type, :value, :unit )
			end

			def set_observation
				@observation = Observation.friendly.find( params[:id] )
			end
	end
end