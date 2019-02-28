module Franklin
	class UnitAdminController < ApplicationAdminController

		before_action :get_unit, only: [:show, :edit, :update, :destroy]

		def create
			@unit = Unit.new( unit_params )
			@unit.save
			redirect_to edit_unit_admin_path( @unit )
		end

		def destroy
			@unit.destroy
			redirect_to unit_admin_index_path
		end


		def index
			by = params[:by] || 'name'
			dir = params[:dir] || 'asc'

			@units = Unit.order( "#{by} #{dir}" )
			if params[:src] == 'user'
				@units =  @units.where.not( user_id: nil )
			end

			if params[:q]
				match = params[:q].downcase.singularize.gsub( /\s+/, '' )
				@units =  @units.where( "name like :q", q: "%#{match}%" )   # @units.where( "lower(REGEXP_REPLACE(title, '\s', '' )) = :m", m: match )
				@units << unit.find_by_alias( match )
			end

			@units = @units.page( params[:page] )
		end

		def update
			@unit.update( unit_params )

			redirect_to :back
		end

		private

			def get_unit
				@unit = Unit.friendly.find( params[:id] )
			end

			def unit_params
				params.require( :unit ).permit( :name, :user_id, :abbrev, :convert_to_unit_id, :conversion_factor, :imperial_correlate_id, :aliases_csv, :imperial )
			end

	end

end