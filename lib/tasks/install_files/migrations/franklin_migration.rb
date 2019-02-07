class FranklinMigration < ActiveRecord::Migration[5.1]

	def change

		create_table :franklin_metrics do |t|
			t.string			:title
			t.integer  			:category_id
			t.integer  			:unit_id
			t.integer  			:user_id
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
			t.integer  			:unit_id
			t.integer  			:user_id
			t.integer  			:parent_id
			t.integer  			:lft
			t.integer  			:rgt
			t.integer  			:observed_id
			t.string   			:observed_type
			t.string   			:title
			t.string   			:content
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
			t.integer  			:parent_obj_id
			t.string   			:parent_obj_type
			t.integer  			:user_id
			t.integer  			:unit_id
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
			t.integer  			:base_unit_id
			t.integer  			:imperial_correlate_id
			t.integer  			:user_id
			t.integer  			:metric_id
			t.float    			:conversion_factor,        default: 1.0
			t.integer  			:custom_base_unit_id
			t.float    			:custom_conversion_factor
			t.string   			:name
			t.string   			:slug
			t.string   			:abbrev
			t.integer  			:unit_type,                default: 0
			t.text     			:aliases,                  default: [],   array: true
			t.boolean  			:imperial,                 default: true

			t.timestamps
		end

		create_table :franklin_user_inputs do |t|
			t.integer  			:user_id
			t.integer  			:result_obj_id
			t.string   			:result_obj_type
			t.text     			:content
			t.string   			:source
			t.string   			:action,          default: :created
			t.string   			:result_status,   default: :success
			t.text     			:system_notes

			t.timestamps
		end



	end
end
