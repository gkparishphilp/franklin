class FranklinMigration < ActiveRecord::Migration[5.1]

	def change

		add_column 	:users, :use_imperial_units, :boolean, default: true


		create_table :franklin_foods do |t|
			t.references 		:user 
			t.references		:serving_unit
			t.references		:category
			t.float 			:serving_amount, default: 100
			t.string 			:name
			t.string   			:slug
			t.text 				:description
			t.text     			:aliases,		default: [],	 array: true
			t.hstore   			:properties,    default: {}
			
			t.timestamps
		end

		create_table :franklin_nutrients do |t|
			t.references 		:food
			t.references		:metric
			t.float 			:amount
			
			t.timestamps
		end

		create_table :franklin_metrics do |t|
			t.string			:title
			t.references 		:category
			t.references 		:default_unit
			t.references 		:user
			t.string   			:slug
			t.text     			:aliases,            default: [],         array: true
			t.text     			:description
			t.integer  			:availability,       default: 0
			t.string   			:default_period,     default: :all_time
			t.string   			:default_value_type
			
			t.timestamps
		end

		create_table :franklin_observations do |t|
			t.string   			:tmp_id
			t.references  		:observed, polymorphic: true
			t.references 		:recorded_unit
			t.references 		:user
			t.references 		:parent
			t.integer  			:lft
			t.integer  			:rgt
			t.string   			:title
			t.text  			:content
			t.float    			:value
			t.string   			:rx
			t.text     			:notes
			t.datetime 			:started_at
			t.datetime 			:ended_at
			t.datetime 			:recorded_at
			t.integer  			:status,        default: 1
			t.hstore   			:properties,    default: {}
			
			t.timestamps
		end

		create_table :franklin_targets do |t|
			t.references 		:parent_obj, polymorphic: true
			t.references  		:user
			t.references  		:unit
			t.string   			:target_type,     default: :value
			t.float    			:value
			t.float    			:min
			t.float    			:max
			t.string   			:direction,       default: :at_most
			t.string   			:period,          default: :all_time
			t.datetime 			:start_at
			t.datetime 			:end_at
			t.integer  			:status,          default: 1
			
			t.timestamps
    	end

    	create_table :franklin_units, force: :cascade do |t|
			t.references 		:convert_to_unit
			t.references 		:imperial_correlate
			t.references 		:user
			t.references 		:metric
			t.references		:custom_convert_to_unit
			t.float    			:conversion_factor,			default: 1.0
			t.float    			:custom_conversion_factor,	default: 1.0
			t.string   			:name
			t.string   			:slug
			t.string   			:abbrev
			t.integer  			:unit_type,                default: 0
			t.text     			:aliases,                  default: [],   array: true
			t.boolean  			:imperial,                 default: true

			t.timestamps
		end

		create_table :franklin_user_inputs do |t|
			t.references 		:user
			t.references 		:result_obj, polymorphic: true
			t.text     			:content
			t.string   			:source
			t.string   			:action,          default: :created
			t.string   			:result_status,   default: :success
			t.text     			:system_notes

			t.timestamps
		end



	end
end
