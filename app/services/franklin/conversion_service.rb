module Franklin
	class ConversionService

		

		def self.convert_from_base( observation, opts={} )
			show_units = opts[:show_units] || opts[:display] || opts[:display_units] || opts[:with_units]
			show_units = true unless show_units == false

			time_format = opts[:time_format] || :long 
			precision = opts[:precision] || 2

			return observation.value if observation.recorded_unit.nil?

			if observation.recorded_unit.time?
				return ChronicDuration.output( observation.value, format: time_format )
			elsif observation.recorded_unit.percent?
				if show_units
					return "#{( observation.value * 100.to_f ).round( precision )}%"
				else
					return "#{( observation.value * 100.to_f ).round( precision )}"
				end
			else
				if observation.recorded_unit.temperature? && observation.base_unit.present?
					value = ( observation.value.to_f / observation.recorded_unit.conversion_factor ).round( precision ) + 32.0
				elsif observation.base_unit.present?
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



		def self.convert_to_base( observation, opts={} )
			value = observation.value || opts[:value] || opts[:amount] || opts[:val] || opts[:v]


			if observation.recorded_unit.time?
				if not( value.strip.match( /\D+/ ) )
					value = "#{value} #{observation.recorded_unit.name}"
				end
				return ChronicDuration.parse( value )
			elsif observation.recorded_unit.percent?
				return value.to_f / 100
			elsif observation.recorded_unit.temperature? && observation.base_unit.present?
				return (value.to_f - 32.0) * observation.recorded_unit.conversion_factor
			elsif observation.base_unit.present?
				return value.to_f * observation.recorded_unit.conversion_factor
			else
				return value.to_f
			end
		end

		

		def self.convert( val, opts={} )

			from_unit ||= opts[:from_unit] || opts[:from]
			if from_unit.is_a?( String )
				from_unit = Unit.system.find_by_alias( from_unit.singularize.downcase )
			end

			to_unit ||= opts[:to_unit] || opts[:to]
			# to_unit ||= from_unit.try( :base_unit )
			if to_unit.is_a?( String )
				to_unit = Unit.system.find_by_alias( @o_unit.singularize.downcase )
			end

			if from_unit.nil? || to_unit.nil?
				raise "Can't convert to/from nil units"
			end

			if not( from_unit.unit_type == to_unit.unit_type )
				raise "Can't convert between incompatible unit types"
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