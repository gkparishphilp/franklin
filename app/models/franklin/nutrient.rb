
# Joins Foods to amounts of nutritional content
# amounts are stored as percentages (e.g. per 1 gram)

module Franklin
	class Nutrient < ApplicationRecord

		belongs_to :food
		belongs_to :metric
		belongs_to :unit

		attr_accessor 	:metric_alias

	end
end