module Franklin
	class ObservationsController < ApplicationController

		def create
			@observation = Observation.new( user: current_user, observed_id: params[:observation][:observed_id], observed_type: params[:observation][:observed_type], content: params[:observation][:content] )

			unit = Unit.find_by_alias( params[:observation][:unit_alias].try( :singularize ) )
			@observation.unit = unit

			if @observation.observed.nil?
				system_metric = Metric.find_by_alias( params[:observation][:metric_alias] )
				if system_metric.present?
					metric = system_metric.dup
					metric.user = current_user
					metric.unit = metric.unit.imperial_correlate if current_user.use_imperial_units? && metric.unit.imperial_correlate.present?
					metric.save
				else
					metric = Metric.new( user: current_user, unit: unit, title: params[:observation][:metric_alias] )
				end
				@observation.observed = metric

			end

			@observation.unit ||= metric.unit
			if @observation.unit.present?
				@observation.value = Franklin::ConversionService.new( value: params[:observation][:value], obs: @observation ).convert
			else
				@observation.value = params[:observation][:value].to_f
			end

			@observation.save

			redirect_back fallback_location: new_observation_path
		end

		def new
			
		end



		private

			def observation_params
				params.require( :observation ).permit( :content, :value, :metric_alias, :unit_id, :unit_alias )
			end
	end
end