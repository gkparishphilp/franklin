module Franklin
	class NutrientAdminController < ApplicationAdminController
		before_action :set_nutrient, only: [:show, :edit, :update, :destroy]
		
		

		def create
			@nutrient = Nutrient.new( nutrient_params )

			metric = Franklin::Metric.find_by_alias( params[:nutrient][:metric_alias] )
			@nutrient.metric = metric

			@nutrient.amount = @nutrient.amount / @nutrient.food.serving_amount.to_f

			@nutrient.save
			redirect_to edit_food_admin_path(@nutrient.food )
		end

		def destroy
			@nutrient.destroy
			redirect_to edit_food_admin_path( @nutrient.food )
		end

		def update
			amount = params[:nutrient][:amount] / @nutrient.food.serving_amount.to_f
			@nutrient.update( name: params[:nutrient][:name], amount: amount )

			redirect_to :back
		end


		private
			def nutrient_params
				params.require( :nutrient ).permit( :food_id, :name, :amount )
			end

			def set_nutrient
				@nutrient = Nutrient.find( params[:id] )
			end
	end

end