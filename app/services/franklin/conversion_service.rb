module Franklin
	class ConversionService

		

		def self.output_observation( observation, opts={} )
			show_units = opts[:show_units] || opts[:display] || opts[:display_units] || opts[:with_units]
			show_units = true unless show_units == false

			time_format = opts[:time_format] || :long 
			precision = opts[:precision] || 2

			if observation.recorded_unit.time?
				return ChronicDuration.output( val, format: time_format )
			elsif observation.recorded_unit.percent?
				if show_units
					return "#{( observation.val * 100.to_f ).round( precision )}%"
				else
					return "#{( observation.val * 100.to_f ).round( precision )}"
				end
			else
				if observation.recorded_unit.temperature? && observation.convert_to_unit.present?
					value = ( observation.value.to_f / observation.recorded_unit.conversion_factor ).round( precision ) + 32.0
				elsif observation.convert_to_unit.present?
					value = ( observation.value / observation.recorded_unit.conversion_factor.to_f ).round( precision )
				else
					value = observation.value
				end

				if show_units
					return "#{value} #{observation.recorded_unit.abbrev}"
				else
					return value
				end

			end
			
		end



		def self.store_observation( observation, opts={} )
			
		end

		

		def self.convert( val, opts={} )
			from_unit ||= opts[:from_unit] || opts[:from]
			if from_unit.is_a?( String )
				from_unit = Unit.system.find_by_alias( from_unit.singularize.downcase )
			end

			to_unit ||= opts[:to_unit] || opts[:to]
			# to_unit ||= from_unit.try( :convert_to_unit )
			if to_unit.is_a?( String )
				to_unit = Unit.system.find_by_alias( @o_unit.singularize.downcase )
			end

			if to_unit.try( :is_base? )
				conversion_factor ||= from_unit.try( :conversion_factor )
			elsif from_unit.try( :is_base? )
				conversion_factor ||= to_unit.try( :conversion_factor )
			else
				conversion_factor ||= from_unit.try( :conversion_factor )
			end
			conversion_factor ||= 1

		end


		private

			


	end

end