module Franklin
	class ConversionService

		# converts values into base_units or from base_units to
		# a convertable unit

		def initialize( opts={} )
			# can pass in either an observation (which has unit & value)
			# => then: from_unit == obs.unt; to_unit == from_unit.base_unit

			# or a value and a unit for conversion (to/from base)
			# => then from_unit == unit_passed; to_unit == from_unit.base_unit

			# or a from_unit, to_unit, and value for arbitrary conversion
			# => then from_unit == from_unit; to_unit == to_unit

			@show_units = opts[:show_units] || opts[:display] || opts[:display_units]

			@time_format = opts[:time_format] || :long 
			@precision = opts[:precision] || 16

			observation = opts[:observation] || opts[:observed] || opts[:obs] || opts[:o]

			@value = opts[:amount] || opts[:value] || opts[:val] || opts[:v]

			if observation.present?
				# todo -- revisit this. Try to guess direction of conversion
				# if observation is passed with nil value, assume we're storing 
				# new and need to convert passed value to base.
				# Otherwise, assume we're converting out of base to the display unit
				# This won't  really work for update.....
				if observation.value.present?
					# note that the observation value trumps val_param
					@value = observation.value
					@from_unit = observation.unit.try( :base_unit )
					@to_unit = observation.unit 
				else
					@from_unit = observation.unit
					@to_unit = observation.unit.try( :base_unit )
				end
			end

			@from_unit ||= opts[:from_unit] || opts[:from]
			if @from_unit.is_a?( String )
				@from_unit = Unit.system.find_by_alias( @from_unit.singularize.downcase )
			end

			@to_unit ||= opts[:to_unit] || opts[:to]
			@to_unit ||= @from_unit.try( :base_unit )
			if @to_unit.is_a?( String )
				@to_unit = Unit.system.find_by_alias( @to_unit.singularize.downcase )
			end


			@conversion_factor = 0.01 if @to_unit.try( :percent? )
			@conversion_factor = 1 if @from_unit == @to_unit
			if @to_unit.try( :is_base? )
				@conversion_factor ||= @from_unit.try( :conversion_factor )
			elsif @from_unit.try( :is_base? )
				@conversion_factor ||= @to_unit.try( :conversion_factor )
			else
				@conversion_factor ||= @from_unit.try( :conversion_factor )
			end
			@conversion_factor ||= 1

			# if not( @from_unit.unit_type == @to_unit.unit_type )
			# 	raise "Can't convert incompatible units!"
			# end

		end


		def convert( opts={} )
			@show_units = opts[:show_units] if opts[:show_units]
			@precision = opts[:precision] if opts[:precision]
			@time_format = opts[:time_format] if opts[:time_format]

			return @value if @to_unit.nil?

			if @to_unit.is_base?
				if @to_unit.time?
					if not( @value.to_s.strip.match( /\D+/ ) )
						@value = "#{@value} #{@from_unit.name}"
					end
					output = ChronicDuration.parse( @value.to_s )
				else
					output = convert_to_base( @value, @to_unit, @conversion_factor )
				end
			elsif @from_unit.is_base?
				if @to_unit.time?
					output = ChronicDuration.output( @value, format: @time_format )
				else
					output = convert_from_base( @value, @to_unit, @conversion_factor )
				end
			else
				# go thru intermediary
				@base_unit = @from_unit.base_unit
				intermediary = convert_to_base( @value, @base_unit, @conversion_factor )
				output = convert_from_base( intermediary, @to_unit, @to_unit.conversion_factor )
			end


			if @show_units
				output = output * 1 / @conversion_factor if @to_unit.percent?
				if @to_unit.time?
					return output.to_s
				else
					return "#{output} #{@to_unit.abbrev}"
				end
			else
				return output.to_f
			end


		end


		def factor
			@conversion_factor
		end

		def from
			@from_unit
		end

		def to
			@to_unit
		end

		def show
			@show_units
		end



		private

			def convert_to_base( val, base_unit, factor=nil )
				if base_unit.temperature?
					output = ( val.to_f - 32.0 ) * factor
				elsif factor.present?
					output = val.to_f * factor
				else
					output = val.to_f
				end
				return output
			end

			def convert_from_base( val, dest_unit, factor=nil )
				factor = 1 / factor.to_f
				if dest_unit.temperature?
					output = ( val.to_f  * factor ).round( @precision ) + 32.0
				elsif factor.present?
					output = ( val.to_f * factor ).round( @precision )
				else
					output = val.to_f.round( @precision )
				end
				return output
			end


	end

end