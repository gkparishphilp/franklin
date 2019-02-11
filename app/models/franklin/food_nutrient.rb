module Franklin
	class FoodNutrient < ApplicationRecord

		belongs_to :food
		belongs_to :metric
		belongs_to :unit

	end
end