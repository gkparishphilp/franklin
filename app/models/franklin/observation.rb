module Franklin
	class Observation < ApplicationRecord

		before_create 	:set_defaults
		validate 		:gotta_have_value_or_notes

		belongs_to 	:observed, polymorphic: true, touch: true, optional: true
		belongs_to 	:parent, class_name: 'Observation', optional: true
		has_many 	:subs, foreign_key: :parent_id, class_name: 'Observation'
		belongs_to 	:user
		belongs_to 	:unit, optional: true # ?

		attr_accessor :metric_alias, :metric_id, :unit_alias


		def self.dated_between( start_date=1.month.ago, end_date=Time.zone.now )
			start_date = start_date.to_datetime.beginning_of_day
			end_date = end_date.to_datetime.end_of_day

			where( recorded_at: start_date..end_date )
		end

		def self.for( observed )
			where( observed_id: observed.id, observed_type: observed.class.name )
		end
		class << self
			alias_method :of, :for
		end

		def self.for_day( day=Time.zone.now )
			self.dated_between( day.beginning_of_day, day.end_of_day )
		end

		def self.journal_entry
			self.where( observed: nil ).where.not( notes: nil )
		end


		def self.nonsubs
			where( parent_id: nil )
		end

		def self.subs
			where.not( parent_id: nil )
		end



		def base_unit
			self.unit.try( :base_unit )
		end

		def display_value( opts={} )
			opts[:precision] ||= 2
			opts[:show_units] = true

			if self.unit.nil?
				"#{self.value}"
			#elsif self.sub.present?
			#	"#{ConversionService.new( obs: self ).convert( opts )} and #{ConversionService.new( obs: self.self ).convert( opts )}"
			else
				ConversionService.new( obs: self ).convert( opts )
			end
		end

		def stop!
			self.ended_at = Time.zone.now
			self.recorded_at = Time.zone.now
			self.value = self.ended_at.to_f - self.started_at.to_f
			self.save
		end

		def sub
			Observation.where( user_id: self.user_id, parent_id: self.id ).first
		end

		def to_s( user=nil )
			str = ""
			if user = self.user
				str = 'You '
			else
				str = "#{self.user} "
			end

			if self.value.present? && self.observed.present?
				str += "recorded #{self.display_value} for #{self.observed.try( :title )} "
			elsif self.value.present? && self.observed.nil?
				str += "recorded #{self.display_value} "
			elsif self.started_at.present? && self.ended_at.nil?
				str += "started #{self.observed.try( :title )} "
			else
				str += "said "
			end

			str += " #{self.notes}" if self.notes.present?

			return str.strip

		end




		private

			def gotta_have_value_or_notes
				if self.value.blank? && self.notes.blank? && self.started_at.blank?
					self.errors.add( :value, "Empty Observation" )
					return false
				end
			end

			def set_defaults
				self.recorded_at ||= Time.zone.now
				#self.started_at ||= Time.zone.now

				self.unit ||= self.observed.try( :unit )
			end



	end
end