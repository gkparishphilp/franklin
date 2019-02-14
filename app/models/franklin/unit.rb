module Franklin
	class Unit < ApplicationRecord
		before_create	:set_aliases
		enum unit_type: { 'custom' => 0, 'volume' => 10, 'weight' => 20, 'distance' => 30, 'time' => 40, 'percent' => 50, 'pressure' => 60, 'energy' => 70, 'temperature' => 80, 'rate' => 90, 'concentration' => 100, 'score' => 110 }
		
		belongs_to :base_unit, class_name: 'Unit', optional: true

		# the imperial correlate maps metric units to their imperial counter-parts.
		# e.g. kg correlates to lb (not oz), cm correlates to in, etc....
		belongs_to :imperial_correlate, class_name: 'Unit', optional: true

		include FriendlyId
		friendly_id :name, use: :slugged

		acts_as_taggable_array_on :aliases

		attr_accessor :custom_base_unit_name

		def self.base
			where( base_unit_id: nil )
		end

		def self.find_by_alias( term )
			term = term.strip.singularize
			term = term.parameterize if term.present? && term.length > 1
			where( ":term = ANY( aliases )", term: term ).first
		end

		def self.system
			where( user_id: nil )
		end



		def aliases_csv
			self.aliases.join( ', ' )
		end

		def aliases_csv=( aliases_csv )
			self.aliases = aliases_csv.split( /,\s*/ )
		end

		def is_base?
			self.base_unit_id.nil?
		end

		def is_sytem?
			self.user_id.nil?
		end


		# def convert_to_base( val, opts={} )
		# 	if self.time?
		# 		if not( val.strip.match( /\D+/ ) )
		# 			val = "#{val} #{self.name}"
		# 		end
		# 		return ChronicDuration.parse( val )
		# 	elsif self.percent?
		# 		return val.to_f / 100
		# 	elsif self.temperature? && self.base_unit.present?
		# 		return (val.to_f - 32.0) * self.conversion_factor
		# 	elsif self.base_unit.present?
		# 		return val.to_f * self.conversion_factor
		# 	else
		# 		return val.to_f
		# 	end
		# end


		# def convert_from_base( val, opts={} )
		# 	# by default, return a formatted string
		# 	# show_units: false should just return a float
		# 	opts[:show_units] = true unless opts[:show_units] == false
		# 	opts[:precision] ||= 2

		# 	val = val.to_f

		# 	if self.time?
		# 		if opts[:show_units]
		# 			return ChronicDuration.output( val, format: :long )
		# 		else
		# 			return ChronicDuration.output( val, format: :chrono )
		# 		end
		# 	elsif self.percent?
		# 		if opts[:show_units]
		# 			return "#{( val * 100.to_f ).round( opts[:precision] )}%"
		# 		else
		# 			return "#{( val * 100.to_f ).round( opts[:precision] )}"
		# 		end
		# 	else
		# 		if self.temperature? && self.base_unit.present?
		# 			value = ( val.to_f / self.conversion_factor ).round( opts[:precision] ) + 32.0
		# 		elsif self.base_unit.present?
		# 			value = ( val / self.conversion_factor.to_f ).round( opts[:precision] )
		# 		else
		# 			value = val
		# 		end
				
		# 		if opts[:show_units]
		# 			return "#{value} #{self.abbrev}"
		# 		else
		# 			return value
		# 		end
		# 	end

		# end


		def to_s
			self.name || self.abbrev
		end





		private
			def set_aliases
				return false if self.name.blank? && self.abbrev.blank?
				self.aliases << self.name.parameterize unless self.aliases.include?( self.name.parameterize ) 
				self.aliases << self.abbrev unless ( self.aliases.include?( self.abbrev ) || self.abbrev.blank? )
				self.aliases.each_with_index do |value, index|
					self.aliases[index] = value.parameterize if value.length > 1 unless value.blank?
				end
				self.aliases = self.aliases.sort.reject{ |a| a.blank? }
			end




	end
end