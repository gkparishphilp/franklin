
# Foods

module Franklin
	class Food < ApplicationRecord

		belongs_to 	:category, optional: true
		belongs_to 	:user, optional: true
		belongs_to 	:serving_unit, class_name: 'Franklin::Unit', optional: true

		has_many 	:nutrients

		include FriendlyId
		friendly_id :slugger, use: [ :slugged ]

		acts_as_taggable_array_on :aliases

		def self.find_by_alias( term )
			return false if term.blank?
			where( ":term = ANY( aliases )", term: term.parameterize ).first
		end



		def aliases_csv
			self.aliases.join( ', ' )
		end

		def aliases_csv=( aliases_csv )
			self.aliases = aliases_csv.split( /,\s*/ )
		end

		def slugger
			if self.user_id.present?
				"#{self.name}_#{self.user_id}"
			else
				self.name
			end
		end

		def to_s
			self.name
		end



	end
end