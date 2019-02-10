# desc "Explaining what the task does"
# task :franklin do
#   # Task goes here
# end
# desc "Explaining what the task does"
# task :bunyan do
#   # Task goes here
# end
# desc "Explaining what the task does"
namespace :franklin do
	task :install do
		puts "Installing Franklin."

		files = {
			'franklin.rb' => 'config/initializers'
		}

		files.each do |filename, path|
			puts "installing: #{path}/#{filename}"

			source = File.join( Gem.loaded_specs["franklin"].full_gem_path, "lib/tasks/install_files", filename )
    		if path == :root
    			target = File.join( Rails.root, filename )
    		else
    			target = File.join( Rails.root, path, filename )
    		end
    		FileUtils.cp_r source, target
		end

		# migrations
		migrations = [
			'franklin_migration.rb',
		]

		prefix = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i

		migrations.each do |filename|
			source = File.join( Gem.loaded_specs["franklin"].full_gem_path, "lib/tasks/install_files/migrations", filename )

    		target = File.join( Rails.root, 'db/migrate', "#{prefix}_#{filename}" )

    		FileUtils.cp_r source, target
    		prefix += 1
		end

	end



	task load_units: :environment do
		puts "Removing Old Units"
		Franklin::Unit.destroy_all
		Franklin::Observation.destroy_all
		Franklin::Metric.destroy_all

		puts "Adding some New Units"


		point = Franklin::Unit.create name: 'Point', abbrev: 'pt', unit_type: 'score'
		round = Franklin::Unit.create name: 'Round', abbrev: 'rd', unit_type: 'score'
		rep = Franklin::Unit.create name: 'Rep', abbrev: 'rep', unit_type: 'score'
		score = Franklin::Unit.create name: 'Score', unit_type: 'score'

		bpm = Franklin::Unit.create name: 'BPM', abbrev: 'bpm', aliases: ['heart rate'], unit_type: 'rate'

		percent = Franklin::Unit.create name: 'Percent', abbrev: '%', unit_type: 'percent'

		mgdl = Franklin::Unit.create name: 'Parts per Million', abbrev: 'ppm', unit_type: 'concentration'
		mgdl = Franklin::Unit.create name: 'mg/dL', abbrev: 'mg/dL', aliases: ['mgdL'], unit_type: 'concentration'
		mmoll = Franklin::Unit.create name: 'mmol/L', abbrev: 'mmol/L', aliases: ['mmolL'], unit_type: 'concentration', base_unit: mgdl, conversion_factor: 18

		bmi = Franklin::Unit.create name: 'Bodymass Index', abbrev: 'bmi', unit_type: 'custom'
		block = Franklin::Unit.create name: 'Block', abbrev: 'block', unit_type: 'custom'

		celcius = Franklin::Unit.create name: 'Degrees Celcius', abbrev: 'celcius', aliases: ['c', 'cel'], unit_type: 'temperature', imperial: false
		f = Franklin::Unit.create name: 'Degrees Farenheit', abbrev: 'degrees', aliases: ['f', 'degs'], unit_type: 'temperature', base_unit: celcius, conversion_factor: 5/9.to_f
		celcius.update( imperial_correlate_id: f.id )

		mmhg = Franklin::Unit.create name: 'Millimeters Mercury', abbrev: 'mmHg', aliases: ['mmhg'], unit_type: 'pressure'
		psi = Franklin::Unit.create name: 'Pounds Per Square Inch', abbrev: 'psi', unit_type: 'pressure'

		cal = Franklin::Unit.create name: 'Calorie', abbrev: 'cal', aliases: ['kCal', 'calory'], unit_type: 'energy'
		jl = Franklin::Unit.create name: 'Joule', abbrev: 'j', unit_type: 'energy', base_unit: cal, conversion_factor: 0.239006

		g = Franklin::Unit.create name: 'Gram', abbrev: 'g', unit_type: 'weight', imperial: false
		kg = Franklin::Unit.create name: 'Kilogram', abbrev: 'kg', aliases: ['kilo'], unit_type: 'weight', base_unit: g, conversion_factor: 1000, imperial: false
		lb = Franklin::Unit.create name: 'Pound', abbrev: 'lb', aliases: ['#'], unit_type: 'weight', base_unit: g, conversion_factor: 453.592
		oz = Franklin::Unit.create name: 'Ounce', abbrev: 'oz', aliases: ['oz'], unit_type: 'weight', base_unit: g, conversion_factor: 28.3495
		g.update( imperial_correlate_id: oz.id )
		kg.update( imperial_correlate_id: lb.id )

		m = Franklin::Unit.create name: 'Meter', abbrev: 'm', unit_type: 'distance', imperial: false
		cm = Franklin::Unit.create name: 'Centimeter', abbrev: 'cm', unit_type: 'distance', base_unit: m, conversion_factor: 0.01, imperial: false
		mm = Franklin::Unit.create name: 'Millimeter', abbrev: 'mm', unit_type: 'distance', base_unit: m, conversion_factor: 0.001, imperial: false
		km = Franklin::Unit.create name: 'Kilometer', abbrev: 'km', aliases: [ 'k' ], unit_type: 'distance', base_unit: m, conversion_factor: 1000, imperial: false
		inch = Franklin::Unit.create name: 'Inch', abbrev: 'in', unit_type: 'distance', aliases: ['"'], base_unit: m, conversion_factor: 0.0254
		ft = Franklin::Unit.create name: 'Foot', abbrev: 'ft', unit_type: 'distance', aliases: ["'"], base_unit: m, conversion_factor: 0.3048
		yd = Franklin::Unit.create name: 'Yard', abbrev: 'yd', unit_type: 'distance', base_unit: m, conversion_factor: 0.9144
		mi = Franklin::Unit.create name: 'Mile', abbrev: 'mi', unit_type: 'distance', base_unit: m, conversion_factor: 1609.344
		m.update( imperial_correlate_id: yd.id )
		cm.update( imperial_correlate_id: inch.id )
		mm.update( imperial_correlate_id: inch.id )
		km.update( imperial_correlate_id: mi.id )

		l = Franklin::Unit.create name: 'Liter', abbrev: 'l', unit_type: 'volume', imperial: false
		ml = Franklin::Unit.create name: 'Milliliter', abbrev: 'ml', unit_type: 'volume', base_unit: l, conversion_factor: 0.001, imperial: false
		cup = Franklin::Unit.create name: 'Cup', abbrev: 'cup', unit_type: 'volume', base_unit: l, conversion_factor: 0.24
		gal = Franklin::Unit.create name: 'Gallon', abbrev: 'gal', unit_type: 'volume', base_unit: l, conversion_factor: 3.78541
		qt = Franklin::Unit.create name: 'Quart', abbrev: 'qt', unit_type: 'volume', base_unit: l, conversion_factor: 0.946352499983857
		pt = Franklin::Unit.create name: 'Pint', abbrev: 'pt', unit_type: 'volume', base_unit: l, conversion_factor: 0.47317624999192847701
		floz = Franklin::Unit.create name: 'Fluid Ounce', abbrev: 'fl oz', unit_type: 'volume', base_unit: l, conversion_factor: 0.0295735
		l.update( imperial_correlate_id: gal.id )
		ml.update( imperial_correlate_id: floz.id )

		sec = Franklin::Unit.create name: 'Second', abbrev: 's', aliases: ['time', 'sec'], unit_type: 'time'
		min = Franklin::Unit.create name: 'Minute', abbrev: 'min', unit_type: 'time', base_unit: sec, conversion_factor: 60
		hr = Franklin::Unit.create name: 'Hour', abbrev: 'hr', unit_type: 'time', base_unit: sec, conversion_factor: 3600
		day = Franklin::Unit.create name: 'Day', abbrev: 'day', unit_type: 'time', base_unit: sec, conversion_factor: 86400

	end

	task load_metrics: :environment do
		puts "Clearing old metrics"
		Franklin::Metric.destroy_all

		puts "Adding Default Metrics"
		puts "Adding some Metrics"

		kg = Franklin::Unit.find_by_alias 'kg'
		cm = Franklin::Unit.find_by_alias 'cm'
		bpm = Franklin::Unit.find_by_alias 'bpm'
		mmhg = Franklin::Unit.find_by_alias 'mmhg'
		mgdl = Franklin::Unit.find_by_alias 'mgdl'
		per = Franklin::Unit.find_by_alias '%'
		bmi = Franklin::Unit.find_by_alias 'bmi'
		celcius = Franklin::Unit.find_by_alias 'celcius'
		cal = Franklin::Unit.find_by_alias 'cal'
		block = Franklin::Unit.find_by_alias 'block'
		g = Franklin::Unit.find_by_alias 'g'
		sec = Franklin::Unit.find_by_alias 'time'
		ml = Franklin::Unit.find_by_alias 'ml'
		rep = Franklin::Unit.find_by_alias 'rep'
		score = Franklin::Unit.find_by_alias 'score'

		wt = Franklin::Metric.create title: 'Weight', default_value_type: 'current_value', aliases: ['wt', 'weigh', 'weighed', 'wait'], unit: kg
		wt.targets.create target_type: :current_value, direction: :at_most, period: :all_time

		wst = Franklin::Metric.create title: 'Waist', default_value_type: 'current_value', aliases: ['wst'], unit: cm
		wst.targets.create target_type: :current_value, direction: :at_most, period: :all_time

		hps = Franklin::Metric.create title: 'Hips', default_value_type: 'current_value', aliases: ['hip'], unit: cm
		hps.targets.create target_type: :current_value, direction: :at_most, period: :all_time

		rhr = Franklin::Metric.create title: 'Resting Heart Rate', default_value_type: 'current_value', aliases: ['pulse', 'heart rate', 'rhr'], unit: bpm
		rhr.targets.create target_type: :current_value, direction: :at_most, period: :all_time

		
		systolic = Franklin::Metric.create title: 'Blood Pressure', default_value_type: 'current_value', aliases: ['sbp', 'systolic', 'blood pressure'], unit: mmhg # blood pressure is a compund with a sub. By default, systolic is first
		systolic.targets.create target_type: :current_value, direction: :at_most, period: :all_time

		diastolic = Franklin::Metric.create title: 'Diastolic Blood Pressure', default_value_type: 'current_value', aliases: ['dbp', 'diastolic'], unit: mmhg 
		diastolic.targets.create target_type: :current_value, direction: :at_most, period: :all_time


		
		bs = Franklin::Metric.create title: 'Blood Sugar', default_value_type: 'current_value', aliases: ['glucose level', 'blood glucose'], unit: mgdl
		
		pbf = Franklin::Metric.create title: 'Percent Body Fat', default_value_type: 'current_value', aliases: ['pbf', 'bodyfat', 'body fat', 'body fat percent'], unit: per
		pbf.targets.create target_type: :current_value, direction: :at_most, period: :all_time

		bmi = Franklin::Metric.create title: 'Body Mass Index', default_value_type: 'current_value', aliases: ['bmi'], unit: bmi
		bmi.targets.create target_type: :current_value, direction: :at_most, period: :all_time

		temp = Franklin::Metric.create title: 'Body Temperature', default_value_type: 'current_value', aliases: ['temp', 'temperature'], unit: celcius
		#bmi.targets.create target_type: :current_value, direction: :at_most, period: :all_time

		md = Franklin::Metric.create title: 'Mood', default_value_type: 'avg_value', aliases: [ 'feeling', 'happiness' ], unit: per, default_period: 'day'
		md.targets.create target_type: :avg_value, direction: :at_least, period: :day, value: 75
		md = Franklin::Metric.create title: 'Energy', default_value_type: 'avg_value', aliases: [ 'energy level' ], unit: per, default_period: 'day'
		md.targets.create target_type: :avg_value, direction: :at_least, period: :day, value: 75

		nutrition = Franklin::Metric.create title: 'Calories', default_value_type: 'sum_value', 	aliases: ['cal', 'cals', 'calory', 'calorie'], unit: cal, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_most, period: :day, value: 2000

		nutrition = Franklin::Metric.create title: 'Calories Burned', default_value_type: 'sum_value', 	aliases: ['cals burned', 'burned'], unit: cal, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 400


		nutrition = Franklin::Metric.create title: 'Blocks', default_value_type: 'sum_value', 	aliases: ['block'], unit: block, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_most, period: :day, value: 15

		nutrition = Franklin::Metric.create title: 'Protein', default_value_type: 'sum_value',	aliases: ['prot', 'grams protein', 'grams of protein' ], unit: g, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 80

		nutrition = Franklin::Metric.create title: 'Fat', default_value_type: 'sum_value', 	aliases: ['fat', 'grams fat', 'grams of fat' ], unit: g, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_most, period: :day, value: 20

		nutrition = Franklin::Metric.create title: 'Carb', default_value_type: 'sum_value', 		aliases: ['carb', 'carbs', 'carbohydrates', 'grams carb', 'grams of carb', 'net carbs' ], unit: g, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_most, period: :day, value: 40
		
		nutrition = Franklin::Metric.create title: 'Sugar', default_value_type: 'sum_value', 	aliases: ['sugars', 'grams sugar', 'grams of sugar' ], unit: g, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_most, period: :day, value: 20
		
		nutrition = Franklin::Metric.create title: 'Water', default_value_type: 'sum_value', 	aliases: ['of water' ], unit: ml, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_least, period: :day, period: :day, value: 1892.71

		nutrition = Franklin::Metric.create title: 'Juice', default_value_type: 'sum_value', 	aliases: ['of juice', 'fruit juice', 'orange juice', 'apple juice' ], unit: ml, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_least, period: :day, period: :week, value: 946.353

		nutrition = Franklin::Metric.create title: 'Soda', default_value_type: 'sum_value', 	aliases: [ 'of soda', 'coke', 'pepsi' ], unit: ml, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_most, period: :day, period: :week, value: 946.353

		nutrition = Franklin::Metric.create title: 'Alcohol', default_value_type: 'sum_value', 	aliases: [ 'liquor', 'of alcohol' ], unit: ml, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_most, period: :week, value: 120

		nutrition = Franklin::Metric.create title: 'Beer', default_value_type: 'sum_value', 	aliases: [ 'beers', 'of beer' ], unit: ml, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_most, period: :week, value: 120

		nutrition = Franklin::Metric.create title: 'Wine', default_value_type: 'sum_value', 	aliases: [ 'wines', 'of wine' ], unit: ml, default_period: 'day'
		nutrition.targets.create target_type: :sum_value, direction: :at_most, period: :week, value: 120


		act = Franklin::Metric.create title: 'Sleep', default_value_type: 'sum_value', 	aliases: ['slp', 'sleeping', 'slept', 'nap', 'napping', 'napped'], unit: sec, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 28800

		act = Franklin::Metric.create title: 'Meditation', default_value_type: 'sum_value', aliases: ['med', 'meditating', 'meditated'], unit: sec, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 1200

		act = Franklin::Metric.create title: 'Steps', default_value_type: 'sum_value', aliases: ['step', 'stp', 'stepped' ], unit: rep, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 10000

		act = Franklin::Metric.create title: 'Drive', default_value_type: 'sum_value', 	aliases: ['drv', 'driving', 'drove'], unit: sec, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_most, period: :week, value: 7200
		act = Franklin::Metric.create title: 'Cook', default_value_type: 'sum_value', 	aliases: ['cooking', 'cooked'], unit: sec, default_period: 'week'
		act.targets.create target_type: :sum_value, direction: :at_most, period: :week, value: 25200
		act = Franklin::Metric.create title: 'Clean', default_value_type: 'sum_value', 	aliases: ['cln', 'cleaning', 'cleaned'], unit: sec, default_period: 'week'
		act.targets.create target_type: :sum_value, direction: :at_most, period: :week, value: 7200

		act = Franklin::Metric.create title: 'Work', default_value_type: 'sum_value', 	aliases: ['wrk', 'working', 'worked'], unit: sec, default_period: 'week'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :week, value: 144000
		act = Franklin::Metric.create title: 'Walk', default_value_type: 'sum_value', 	aliases: ['wlk', 'walking', 'walked'], unit: sec, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :week, value: 7200
		act = Franklin::Metric.create title: 'Cycle', default_value_type: 'sum_value', aliases: ['cycling', 'cycled', 'bike', 'biked', 'biking', 'bicycling', 'bicycled', 'bicycle' ], unit: sec, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :week, value: 3600
		act = Franklin::Metric.create title: 'Swim', default_value_type: 'sum_value', aliases: ['swimming', 'swam'], unit: sec, default_period: 'week'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :week, value: 3600
		act = Franklin::Metric.create title: 'Run', default_value_type: 'sum_value', aliases: ['running', 'ran', 'jog', 'jogging', 'jogged'], unit: sec, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :week, value: 3600


		act = Franklin::Metric.create title: 'Plank Time', default_value_type: 'sum_value', aliases: ['plank', 'planked', 'planking'], unit: sec, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 20

		act = Franklin::Metric.create title: 'Push-ups', default_value_type: 'sum_value', aliases: ['pushup', 'push', 'pushshups'], unit: rep, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 20
		
		act = Franklin::Metric.create title: 'Pull-ups', default_value_type: 'sum_value', aliases: ['pullup', 'pull-up', 'pull', 'pullups'], unit: rep, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 10

		act = Franklin::Metric.create title: 'Burpees', default_value_type: 'sum_value', aliases: ['burpee'], unit: rep, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 10

		act = Franklin::Metric.create title: 'Squats', default_value_type: 'sum_value', aliases: ['squat'], unit: rep, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 25

		act = Franklin::Metric.create title: 'Sit-ups', default_value_type: 'sum_value', aliases: ['situp', 'sit-up', 'situps'], unit: rep, default_period: 'day'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :day, value: 10
		
		
		act = Franklin::Metric.create title: 'Watch TV', default_value_type: 'sum_value', aliases: ['tv', 'screen time', 'watch video', 'wathed tv', 'watched', 'watching', 'watched video', 'watching video', 'watching tv'], unit: sec, default_period: 'week'
		act.targets.create target_type: :sum_value, direction: :at_most, period: :week, value: 3600

		act = Franklin::Metric.create title: 'Video Game', default_value_type: 'sum_value', aliases: ['play video game', 'computer game', 'play xbox', 'xbox', 'play playstation', 'playstation', 'nintentndo', 'play nintendo', 'play on phone'], unit: sec, default_period: 'week'
		act.targets.create target_type: :sum_value, direction: :at_most, period: :week, value: 3600


		wkt = Franklin::Metric.create title: 'Workout', default_value_type: 'sum_value', aliases: ['wkout', 'worked out', 'exercise', 'exercised', 'work out', 'working out', 'exercising'], unit: sec, default_period: 'week'
		act.targets.create target_type: :sum_value, direction: :at_least, period: :week, value: 10800

		wod = Franklin::Metric.create title: 'WoD', default_value_type: 'count', aliases: ['workout of the day', 'crossfit', 'cross fit'], unit: sec, default_period: 'week'
		wod.targets.create target_type: :count, direction: :at_least, period: :week, value: 4
		# workouts must have time... record scores, reps, etc as sub observations.
		# bmi = Franklin::Metric.create title: 'AMRAP', default_value_type: 'activity', aliases: ['amrap'], unit: 'rep'



		act = Franklin::Metric.create title: 'Max Bench', default_value_type: 'max_value', aliases: ['bench', 'bench press'], unit: kg
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time
		
		act = Franklin::Metric.create title: 'Max Deadlift', default_value_type: 'max_value', aliases: ['deadlift', 'dl', 'dead lift'], unit: kg
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time

		act = Franklin::Metric.create title: 'Max Backsquat', default_value_type: 'max_value', aliases: ['squat', 'back squat', 'max squat'], unit: kg
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time
		
		act = Franklin::Metric.create title: 'Max Press', default_value_type: 'max_value', aliases: ['press'], unit: kg
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time
		
		act = Franklin::Metric.create title: 'Max Clean', default_value_type: 'max_value', aliases: ['clean', 'power clean'], unit: kg
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time
		
		act = Franklin::Metric.create title: 'Max Clean & Jerk', default_value_type: 'max_value', aliases: ['clean n jerk', 'clean and jerk', 'clean jerk'], unit: kg
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time
		
		act = Franklin::Metric.create title: 'Max Snatch', default_value_type: 'max_value', aliases: ['snatch'], unit: kg
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time
		
		act = Franklin::Metric.create title: 'Max Plank Time', default_value_type: 'max_value', aliases: ['max plank'], unit: sec
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time

		act = Franklin::Metric.create title: '100m Time', default_value_type: 'min_value', aliases: ['one hundred', 'hundred time', 'hundred meter time', 'hundred meter dash', '100 meter dash', '100 meter time'], unit: sec
		act.targets.create target_type: :min_value, direction: :at_most, period: :all_time
		
		act = Franklin::Metric.create title: '400m Time', default_value_type: 'min_value', aliases: ['four hundred', 'four hundred time', 'four hundred meter time', 'four hundred meter dash', '400 meter dash', '400 meter time'], unit: sec
		act.targets.create target_type: :min_value, direction: :at_most, period: :all_time
		
		act = Franklin::Metric.create title: 'Mile Time', default_value_type: 'min_value', aliases: ['mile', 'one mile', 'one mile run', '1 mile run', '1 mile'], unit: sec
		act.targets.create target_type: :min_value, direction: :at_most, period: :all_time

		act = Franklin::Metric.create title: 'Max Pushups', default_value_type: 'max_value', aliases: ['max pushup'], unit: rep
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time
		
		act = Franklin::Metric.create title: 'Max Pullups', default_value_type: 'max_value', aliases: ['max pullup'], unit: rep
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time
		
		act = Franklin::Metric.create title: 'Max Burpees', default_value_type: 'max_value', aliases: ['max burpee'], unit: rep
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time
		
		act = Franklin::Metric.create title: 'Max Situps', default_value_type: 'max_value', aliases: ['max situp'], unit: rep
		act.targets.create target_type: :max_value, direction: :at_least, period: :all_time

		act = Franklin::Metric.create title: 'Round of Golf', default_value_type: 'min_value', aliases: ['golf', 'golfing', 'golfed', 'golf score'], unit: score
		act.targets.create target_type: :min_value, direction: :at_most, period: :all_time, value: 80


	end



end
