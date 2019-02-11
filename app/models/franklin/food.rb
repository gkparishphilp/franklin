module Franklin
	class Food < ApplicationRecord
		has_many :food_nutrients

		include FriendlyId
		friendly_id :slugger, use: [ :slugged ]

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