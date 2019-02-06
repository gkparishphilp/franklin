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

			source = File.join( Gem.loaded_specs["bunyan"].full_gem_path, "lib/tasks/install_files", filename )
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



	task load_data: :environment do
		puts "Loading Franklin Data"
		puts "Adding some Units"

		point = Unit.create name: 'Point', abbrev: 'pt', unit_type: 'score'
		round = Unit.create name: 'Round', abbrev: 'rd', unit_type: 'score'
		rep = Unit.create name: 'Rep', abbrev: 'rep', unit_type: 'score'

		bpm = Unit.create name: 'BPM', abbrev: 'bpm', aliases: ['heart rate'], unit_type: 'rate'

		percent = Unit.create name: 'Percent', abbrev: '%', unit_type: 'percent'

		mgdl = Unit.create name: 'Parts per Million', abbrev: 'ppm', unit_type: 'concentration'
		mgdl = Unit.create name: 'mg/dL', abbrev: 'mg/dL', aliases: ['mgdL'], unit_type: 'concentration'
		mmoll = Unit.create name: 'mmol/L', abbrev: 'mmol/L', aliases: ['mmolL'], unit_type: 'concentration', base_unit: mgdl, conversion_factor: 18

		bmi = Unit.create name: 'Bodymass Index', abbrev: 'bmi', unit_type: 'custom'
		block = Unit.create name: 'Block', abbrev: 'block', unit_type: 'custom'

		celcius = Unit.create name: 'Degrees Celcius', abbrev: 'celcius', aliases: ['c', 'cel'], unit_type: 'temperature', imperial: false
		f = Unit.create name: 'Degrees Farenheit', abbrev: 'degrees', aliases: ['f', 'degs'], unit_type: 'temperature', base_unit: celcius, conversion_factor: 5/9.to_f
		celcius.update( imperial_correlate_id: f.id )

		mmhg = Unit.create name: 'Millimeters Mercury', abbrev: 'mmHg', aliases: ['mmhg'], unit_type: 'pressure'
		psi = Unit.create name: 'Pounds Per Square Inch', abbrev: 'psi', unit_type: 'pressure'

		cal = Unit.create name: 'Calorie', abbrev: 'cal', aliases: ['kCal', 'calory'], unit_type: 'energy'
		jl = Unit.create name: 'Joule', abbrev: 'j', unit_type: 'energy', base_unit: cal, conversion_factor: 0.239006

		g = Unit.create name: 'Gram', abbrev: 'g', unit_type: 'weight', imperial: false
		kg = Unit.create name: 'Kilogram', abbrev: 'kg', aliases: ['kilo'], unit_type: 'weight', base_unit: g, conversion_factor: 1000, imperial: false
		lb = Unit.create name: 'Pound', abbrev: 'lb', aliases: ['#'], unit_type: 'weight', base_unit: g, conversion_factor: 453.592
		oz = Unit.create name: 'Ounce', abbrev: 'oz', aliases: ['oz'], unit_type: 'weight', base_unit: g, conversion_factor: 28.3495
		g.update( imperial_correlate_id: oz.id )
		kg.update( imperial_correlate_id: lb.id )

		m = Unit.create name: 'Meter', abbrev: 'm', unit_type: 'length', imperial: false
		cm = Unit.create name: 'Centimeter', abbrev: 'cm', unit_type: 'length', base_unit: m, conversion_factor: 0.01, imperial: false
		mm = Unit.create name: 'Millimeter', abbrev: 'mm', unit_type: 'length', base_unit: m, conversion_factor: 0.001, imperial: false
		km = Unit.create name: 'Kilometer', abbrev: 'km', aliases: [ 'k' ], unit_type: 'length', base_unit: m, conversion_factor: 1000, imperial: false
		inch = Unit.create name: 'Inch', abbrev: 'in', unit_type: 'length', aliases: ['"'], base_unit: m, conversion_factor: 0.0254
		ft = Unit.create name: 'Foot', abbrev: 'ft', unit_type: 'length', aliases: ["'"], base_unit: m, conversion_factor: 0.3048
		yd = Unit.create name: 'Yard', abbrev: 'yd', unit_type: 'length', base_unit: m, conversion_factor: 0.9144
		mi = Unit.create name: 'Mile', abbrev: 'mi', unit_type: 'length', base_unit: m, conversion_factor: 1609.34
		m.update( imperial_correlate_id: yd.id )
		cm.update( imperial_correlate_id: inch.id )
		mm.update( imperial_correlate_id: inch.id )
		km.update( imperial_correlate_id: mi.id )

		l = Unit.create name: 'Liter', abbrev: 'l', unit_type: 'volume', imperial: false
		ml = Unit.create name: 'Milliliter', abbrev: 'ml', unit_type: 'volume', base_unit: l, conversion_factor: 0.001, imperial: false
		cup = Unit.create name: 'Cup', abbrev: 'cup', unit_type: 'volume', base_unit: l, conversion_factor: 0.24
		gal = Unit.create name: 'Gallon', abbrev: 'gal', unit_type: 'volume', base_unit: l, conversion_factor: 3.78541
		qt = Unit.create name: 'Quart', abbrev: 'qt', unit_type: 'volume', base_unit: l, conversion_factor: 0.946352499983857
		pt = Unit.create name: 'Pint', abbrev: 'pt', unit_type: 'volume', base_unit: l, conversion_factor: 0.47317624999192847701
		floz = Unit.create name: 'Fluid Ounce', abbrev: 'fl oz', unit_type: 'volume', base_unit: l, conversion_factor: 0.0295735
		l.update( imperial_correlate_id: gal.id )
		ml.update( imperial_correlate_id: floz.id )

		sec = Unit.create name: 'Second', abbrev: 's', aliases: ['time'], unit_type: 'time'
		min = Unit.create name: 'Minute', abbrev: 'min', unit_type: 'time', base_unit: sec, conversion_factor: 60
		hr = Unit.create name: 'Hour', abbrev: 'hr', unit_type: 'time', base_unit: sec, conversion_factor: 3600
		day = Unit.create name: 'Day', abbrev: 'day', unit_type: 'time', base_unit: sec, conversion_factor: 86400

		

	end
end
