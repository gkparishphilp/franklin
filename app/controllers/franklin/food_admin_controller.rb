module Franklin
	class FoodAdminController < ApplicationAdminController
		before_action :set_food, only: [:show, :edit, :update, :destroy]
		
		

		def create
			@food = Food.new( food_params )
			@food.save
			redirect_to edit_food_admin_path( @food )
		end

		def destroy
			@food.destroy
			redirect_to food_admin_index_path
		end

		def index
			by = params[:by] || 'created_at'
			dir = params[:dir] || 'desc'

			@foods = Food.order( "#{by} #{dir}" )
			
			if params[:user].present?
				@foods =  @foods.where.( user_id: params[:user] )
			end

			@foods = @foods.page( params[:page] )

		end

		def update
			@food.update( food_params )

			redirect_to :back
		end


		private
			def food_params
				params.require( :food ).permit( :name, :category_id, :aliases_csv, :serving_unit, :serving_amount )
			end

			def set_food
				@food = Food.friendly.find( params[:id] )
			end
	end

end