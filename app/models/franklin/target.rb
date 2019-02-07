
#todo
module Franklin
	class Target < ApplicationRecord
		enum status: { 'archive' => 0, 'active' => 10, 'inactive' => 30 }

		before_create 	:set_defaults

		belongs_to :parent_obj, polymorphic: true
		belongs_to :unit
		belongs_to :user

		

		def self.directions
			{
				'at_most' => 'at Most',
				'at_least' => 'at Least',
				'exactly' => 'Exactly',
				'between' => 'Between'
			}
		end

		def self.periods
			{
				'hour' => 'per Hour',
				'day' => 'per Day',
				'week' => 'per Week',
				'month' => 'per Month',
				'year' => 'per Year',
				'all_time' => 'All Time'
			}
		end

		def self.target_types
			{
				'avg_value' 		=> 'Average Value',
				'count' 			=> 'Observation Frequency',
				'current_value' 	=> 'Current Value',
				'max_value' 		=> 'All-Time High',
				'min_value'			=> 'All-Time Low',
				'sum_value' 		=> 'Accumulated Value'
				#started_at		=> 'Start Time',
				# recorded_at	=> 'End Time'
			}
		end



		def display_value( opts={} )
			opts[:precision] ||= 2

			if self.target_type == 'count'
				return "#{self.value} observation"
			end

			if self.unit.nil?
				"#{self.value}"
			else
				self.unit.convert_from_base( self.value, opts )
			end
		end

		def to_s
			"#{Target.directions[self.direction]} #{self.display_value} #{Target.target_types[self.target_type]} #{Target.periods[self.period]}."
		end


		private
			def set_defaults
				self.target_type ||= self.parent_obj.try( :default_value_type )
				self.period ||= self.parent_obj.try( :default_period )
			end
	end
end