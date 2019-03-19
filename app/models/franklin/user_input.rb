module Franklin
	class UserInput < ApplicationRecord

		# stores a record of all user commands

		belongs_to 	:user 	#, optional: true?
		belongs_to 	:result_obj, polymorphic: true, optional: true # usually an observation.... but not always?

		MATCHERS = { 
					/ate/ 			=> 'log_food', 
					/is|=|was|were/ => 'metric_is_value' 
				}

		def metric_regex
			metrics = Metric.where( user_id: nil ).or( Metric.where( user_id: self.user_id ) ).pluck( :aliases ).flatten.join( '|' )
			/\s*(#{metrics})\s*/
		end

		def quantity_regex
			units = Unit.where( user_id: nil ).or( Unit.where( user_id: self.user_id ) ).pluck( :aliases ).flatten.join( '|' )
			/(\d+\.?\d*)\s*(#{units})*/
		end


		def parse!

			# for simplicity, just strip leading record or log
			@str = self.content.gsub( /\A(record|log|my|i)/, '' ).strip

			got_match = false

			MATCHERS.each do |pattern, name |
				if self.content.match( pattern )
					got_match = true
					eval name
				end
			end

			if not got_match
				# nothing matches -- it's just a note
				self.result_obj = Observation.create( user: self.user, notes: self.content )
				self.system_notes = "Created a note: <a href=''>#{self.result_obj}</a>"
				self.save
				return self
			end
		end




		private

			def metric_is_value
				# figure out the metric
				# => get the metric string
				# => look for user metrics
				# => look for system metrics

				# figure out the value
				# => get the unit user entered
				# => or use the metric default unit (imp correlate for imp users )
				# => convert to base

				# figure out the time
				# => recorded_at defaults to Time.now
				# => or xx minutes/hrs/days ago or yesterday

				# figure out notes?

				@metric_string = @str.split( /is|=|was|were/ )[0].strip
				@value_string = @str.split( /is|=|was|were/ )[1].strip
					
				@metric = Metric.fetch_by_alias_for_user( @metric_string, self.user ) #, create: true )

				@recorded_unit, @value = Unit.parse_string( @value_string )
				@recorded_unit = Unit.find_by_alias( @recorded_unit )
				@recorded_unit ||= @metric.try( :default_unit )

				@observation = Observation.new( user: self.user, observed: @metric, recorded_unit: @recorded_unit )
				@observation.value = ConversionService.convert_to_base( @observation, value: @value )

				die
			end

			def set_recorded_at( str )
				return Time.zone.now if str.nil? || str.blank?

				if str.scan( /ago/ ).present?
					str.gsub!( /ago/, '' ).strip
					value = str.slice!( /\d+\s+/ ).strip
					period = str

					return date = eval( "(Time.zone.now - #{value}.#{period})" )
				end

				if str.scan( 'yesterday' ).present? || str == 'last night'
					return Time.zone.now - 1.day
				end

				if str == 'last week'
					return Time.zone.now - 1.week
				end

				if str == 'last month'
					return Time.zone.now - 1.month
				end

				# default to now if we haven't caught anything
				return Time.zone.now
			end

	end
end