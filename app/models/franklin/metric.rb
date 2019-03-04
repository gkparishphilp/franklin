
module Franklin
	class Metric < ApplicationRecord
		before_create 	:set_defaults
		before_save 	:clean_aliases
		validate 		:unique_aliases

		validates :title, presence: true

		enum availability: { 'just_me' => 0, 'trainer' => 10, 'team' => 30, 'community' => 50, 'anyone' => 100 }

		belongs_to :default_unit, class_name: 'Franklin::Unit', optional: true
		belongs_to :user, optional: true

		has_many 	:observations, as: :observed, dependent: :destroy
		has_many 	:targets, as: :parent_obj, dependent: :destroy

		attr_accessor :reassign_to_metric_id, :unit_alias

		include FriendlyId
		friendly_id :slugger, use: [ :slugged ]

		acts_as_taggable_array_on :aliases

		def self.find_by_alias( term )
			return false if term.blank?
			term = term.try( :strip ).try( :singularize ).try( :parameterize )
			where( ":term = ANY( aliases )", term: term ).first
		end

		def self.default_value_types
			{
				'avg_value' 		=> 'Average',
				'count' 			=> 'Frequency',
				'current_value' 	=> 'Stat',
				'max_value' 		=> 'All-Time High',
				'min_Value'			=> 'All-Time Low',
				'sum_value' 		=> 'Accumulated'
			}
		end

		def self.fetch_by_alias_for_user( str, user, opts={} )

			# fetches a user's metric based on passed in string (matching metric title or aliases )
			# creates a copy of asystem metric for the user if user hasn't used metric before
			# may also create custom metrics if optional create == true

			str = str.downcase

			metric = Metric.where( user: user ).find_by_alias( str )
			return metric if metric.present?

			# also check the user's existing assigned metrics based on unit that if exists...
			if opts[:unit].present? && Metric.where( user: user ).find_by_alias( opts[:unit] )
				return Metric.where( user: user ).find_by_alias( opts[:unit] )
			end


			system_metric = Metric.system.find_by_alias( str )
			if system_metric.present?
				metric = system_metric.dup
				metric.user = user
				metric.default_unit = metric.default_unit.imperial_correlate if user.use_imperial_units? && metric.default_unit.imperial_correlate.present?
				#metric.save
			elsif opts[:create]
				metric = Metric.new( user: user, title: str )
			end

			return metric
			
		end


		def self.system
			where( user_id: nil )
		end




		def active_target
			self.targets.active.last
		end

		def aliases_csv
			self.aliases.join( ', ' )
		end

		def aliases_csv=( aliases_csv )
			self.aliases = aliases_csv.split( /,\s*/ )
		end

		def base_unit
			unit = self.default_unit.try( :base_unit )
			unit ||= self.default_unit
			return unit
		end


		def default_value( args={} )
			# show current default state of the metric

			args[:convert] = true unless args[:convert] == false

			# default to all_time
			start_date = Time.zone.now - 10.years
			
			if not( self.default_period == 'all_time' )
				start_date = Time.zone.now - eval( "1.#{self.default_period}" )
			end
			range = start_date..Time.zone.now

			same_type_unit_ids = Unit.where( unit_type: Unit.unit_types[self.default_unit.unit_type] ).pluck( :id )

			if self.default_value_type == 'max_value'
				value = self.observations.nonsubs.where( default_unit_id: same_type_unit_ids ).where( recorded_at: range ).maximum( :value )
			elsif self.default_value_type == 'min_value'
				value = self.observations.nonsubs.where( default_unit_id: same_type_unit_ids ).where( recorded_at: range ).minimum( :value )
			elsif self.default_value_type == 'avg_value'
				value = self.observations.nonsubs.where( default_unit_id: same_type_unit_ids ).where( recorded_at: range ).average( :value )
			elsif self.default_value_type == 'current_value'
				value = self.observations.nonsubs.where( default_unit_id: same_type_unit_ids ).where( recorded_at: range ).order( recorded_at: :desc ).first.try( :value )
			elsif self.default_value_type == 'count'
				value = self.observations.nonsubs.where( recorded_at: range ).count
			else # sum_value -- aggregate
				value = self.observations.nonsubs.where( default_unit_id: same_type_unit_ids ).where( recorded_at: range ).sum( :value )
			end

			# special hack for blood pressure
			if self.aliases.include? 'blood-pressure'
				last_obs = self.observations.where( recorded_at: range ).order( recorded_at: :desc ).first
				value = last_obs.try( :value )
				sub_value = last_obs.sub.value 
				return "#{value}/#{sub_value} mmHg"
			end

			if args[:convert] && self.default_unit.present?
				return " TODO "
				#return self.unit.convert_from_base( value )
			else
				return value
			end

		end




		def slugger
			if self.user_id.present?
				"#{self.title}_#{self.user_id}"
			else
				self.title
			end
		end

		def to_s
			self.title
		end

		def total_for_day( day=Time.zone.now )
			self.observations.for_day( day ).sum( :value )
		end




		private
			def set_defaults
				self.aliases << self.title.parameterize unless self.aliases.include?( self.title.parameterize )
				#self.unit ||= Unit.nada.first
			end

			def clean_aliases
				self.aliases.each_with_index do |value, index|
					self.aliases[index] = value.parameterize
				end
				self.aliases = self.aliases.sort
			end

			def unique_aliases
				existing_aliases = Metric.where( user_id: self.user_id ).where.not( id: self.id ).pluck( :aliases ).flatten
				self.aliases = self.aliases.uniq - existing_aliases
			end



	end
end