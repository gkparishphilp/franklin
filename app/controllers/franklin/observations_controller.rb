module Franklin
	class ObservationsController < ApplicationAdminController

		def create
			@observation = Observation.new( user: current_user, notes: params[:observation][:notes] )

			metric = Metric.fetch_by_alias_for_user( params[:observation][:metric_alias], current_user )

			if params[:observation][:value].match( /:|hour|minute|sec/ )
				# if metric.default_unit == hour && only one :, add a second colon cause chronic assumes 7:43 is minutes
				@observation.recorded_unit ||= Unit.time.first
			elsif params[:observation][:value].match( /%/ )
				@observation.recorded_unit ||= Unit.percent.first
			elsif capture = params[:observation][:value].match( /\D+/ )
				@observation.recorded_unit = Unit.find_by_alias( capture[0] )
			end

			@observation.recorded_unit ||= metric.default_unit

			if not( metric.persisted? )
				metric.default_unit ||= @observation.recorded_unit
				metric.save
			end

			if @observation.recorded_unit.present?
				@observation.value = Franklin::ConversionService.convert_to_base( @observation, value: params[:observation][:value] )
			else
				@observation.value = params[:observation][:value].to_f
			end

			@observation.observed = metric

			@observation.save

			redirect_back fallback_location: new_observation_path
		end

		def new
			@observations = Observation.where( user_id: current_user.id ).order( created_at: :desc ).page( params[:page ])
		end



		private

			def observation_params
				params.require( :observation ).permit( :notes, :value, :metric_alias, :unit_id, :unit_alias )
			end
	end
end