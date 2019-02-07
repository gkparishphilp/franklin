module Franklin

	class MetricAdminController < ApplicationAdminController
		before_action :set_metric, only: [:show, :edit, :update, :destroy]
		
		def create
			@metric = Metric.new( metric_params )
			@metric.save
			redirect_to edit_metric_admin_path( @metric )
		end

		def destroy
			@metric.destroy
			redirect_to metric_admin_index_path
		end

		def index
			by = params[:by] || 'title'
			dir = params[:dir] || 'asc'
			@metrics = Metric.order( "#{by} #{dir}" )
			if params[:src] == 'user'
				@metrics =  @metrics.where.not( user_id: nil )
			end

			if params[:q]
				match = params[:q].downcase.singularize.gsub( /\s+/, '' )
				@metrics =  @metrics.where( "title like :q", q: "%#{match}%" )   # @metrics.where( "lower(REGEXP_REPLACE(title, '\s', '' )) = :m", m: match )
				@metrics << Metric.find_by_alias( match )
			end

			@metrics = @metrics.page( params[:page] )

		end

		def update
			@metric.update( metric_params )

			redirect_to :back
		end


		private
			def metric_params
				params.require( :metric ).permit( :title, :description, :unit, :display_unit, :aliases_csv, :metric_type )
			end

			def set_metric
				@metric = Metric.friendly.find( params[:id] )
			end
	end

end