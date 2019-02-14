module Franklin
	class ObservationsController < ApplicationController

		def create
			@observation = Observation.new( user: current_user, content: params[:observation][:content] )

			system_metric = Metric.find_by_alias( params[:observation][:metric_alias] )
			if system_metric.present?
				metric = system_metric.dup
				metric.user = current_user
				metric.default_unit = metric.default_unit.imperial_correlate if current_user.use_imperial_units? && metric.default_unit.imperial_correlate.present?
				metric.save
			else
				metric = Metric.new( user: current_user, title: params[:observation][:metric_alias] )
			end

			if params[:observation][:value].match( /:|hour|minute|sec/ )
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
				@observation.value = Franklin::ConversionService.new( value: params[:observation][:value], from: @observation.recorded_unit, to: @observation.base_unit ).convert
			else
				@observation.value = params[:observation][:value].to_f
			end

			@observation.observed = metric

			@observation.save

			redirect_back fallback_location: new_observation_path
		end

		def new
			@observations = current_user.observations.order( created_at: :desc ).page( params[:page ])
		end



		private

			def observation_params
				params.require( :observation ).permit( :content, :value, :metric_alias, :unit_id, :unit_alias )
			end
	end
end