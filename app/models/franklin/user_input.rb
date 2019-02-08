module Franklin
	class UserInput < ApplicationRecord

		# stores a record of all user commands

		belongs_to 	:user 	#, optional: true?
		belongs_to 	:result_obj, polymorphic: true, optional: true # usually an observation.... but not always?


	end
end