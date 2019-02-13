module Franklin
	class UserInput < ApplicationRecord

		# stores a record of all user commands

		belongs_to 	:user 	#, optional: true?
		belongs_to 	:result_obj, polymorphic: true, optional: true # usually an observation.... but not always?




		def process!

			# for simplicity, just strip leading record or log
			str = self.content.gsub( /\A(record|log|my|i)/, '' ).strip

			if captures = str.match( /\Aate/i )
			elsif str.match( /\Aate/i )
				# ate something.... send it to the nutrition service
				die
			end 



			# nothing matches -- it's just a note
			self.result_obj = Observation.create( user: self.user, notes: self.content )
			self.system_notes = "Created a note: <a href=''>#{self.result_obj}</a>"
			self.save
			return self.result_obj
		end

	end
end