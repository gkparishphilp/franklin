
# required gems from gemspec
require 'acts-as-taggable-array-on'
require 'chronic_duration'


module Franklin

	class << self

		# engine configuration settings accessors
		mattr_accessor :courses_path

		# settings defaults
		self.courses_path = '/courses'

	end

	# this function maps the vars from your app into the engine
	def self.configure( &block )
		yield self
	end


	class Engine < ::Rails::Engine
		isolate_namespace Franklin
	end
end



