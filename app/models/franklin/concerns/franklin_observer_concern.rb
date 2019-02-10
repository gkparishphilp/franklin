
# Injections to user model so that it can be used with Franklin

module Franklin
	module Concerns

		module ObserverConcern
			extend ActiveSupport::Concern

			included do				

				has_many :metrics
				has_many :observations
				has_many :targets
				has_many :units # custom units entered by the user: e.g. water bottle
				has_many :user_inputs

				after_create 	:set_custom_units

			end


			####################################################
			# Class Methods

			module ClassMethods

			end


			####################################################
			# Instance Methods


			private

				def set_custom_units
					#Unit.create( user_id: self.id, name: 'Steps', abbrev: 'step', unit_type: 'length', base_unit_id: Unit.system.find_by_alias( 'meter' ).id, conversion_factor: 0.7112, custom_base_unit_id: Unit.system.find_by_alias( 'inch' ).id, custom_conversion_factor: 28 )
				end

					

		end

	end
end