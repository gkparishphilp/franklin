module Franklin
	class ConversionService

		

		def self.display( observation, opts={} )
			
		end

		def self.store( opts={} )
			
		end



		def initialize( opts={} )

			@value = opts[:amount] || opts[:value] || opts[:val] || opts[:v]

			@from_unit ||= opts[:from_unit] || opts[:from]
			if @from_unit.is_a?( String )
				@from_unit = Unit.system.find_by_alias( @from_unit.singularize.downcase )
			end

			@to_unit ||= opts[:to_unit] || opts[:to]
			@to_unit ||= @from_unit.try( :base_unit )
			if @to_unit.is_a?( String )
				@to_unit = Unit.system.find_by_alias( @to_unit.singularize.downcase )
			end

		end


		def convert( opts={} )
			@from_unit = opts[:from] if opts[:from]
			@to_unit = opts[:to] if opts[:to]

			@show_units = opts[:show_units] if opts[:show_units]
			@precision = opts[:precision] if opts[:precision]
			@time_format = opts[:time_format] if opts[:time_format]


			return @value if @to_unit.nil?

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