require 'gosu'
require 'json'

class ParticleWindow < Gosu::Window

	$DEFAULT_GRAVITY = 0.05

	def initialize(width = 800, height = 600, fullscreen = true)
		super
		self.caption = "Particles"

		$width = width
		$height = height
		@font = Gosu::Font.new(10)
		@particles = []
		$r = Random.new
		@controller = Parser.new.parse_file("./SimpleDemo.json")
		# puts @controller
		@frame = 1
	end

	def button_down(id)
		close if id == Gosu::KbEscape
		@particles.clear if id == Gosu::KbC
		@frame = 0 if id == Gosu::KbS
	end

	def update
		@controller.update(@particles, @frame)
		@particles.each(&:update)
		@frame += 1
		@particles.delete_if { |particle| !particle.x.between?(0, $width) || !particle.y.between?(-$height, $height) }
	end

	def draw
		@font.draw("Particles: #{@particles.size}, Frame: #{@frame}, Fps: #{Gosu.fps}", 10, $height - 10, 0)
		@particles.each(&:draw)
	end
end

class Particle
	attr_reader :x, :y

	def initialize(x, y, xd, yd, c, gravity)
		@x = x
		@y = y
		@xd = xd
		@yd = yd
		@c = c
		@gravity = gravity
	end

	def update
		@x += @xd
		@y += @yd
		@yd += @gravity
	end

	def draw
		Gosu.draw_rect(@x, @y, 10, 10, @c)
	end
end

class Parser
	def parse_file(filename)
		parse(File.read(filename))
	end

	def parse(input)
		parsed = JSON.parse(input)
		items = []
		parsed["timeline"].each do |timeline_item|
			item_data = {}
			timeline_item.each do |k, v|
		 		if v.is_a? String
					v = v.gsub("h", $height.to_s).gsub("w", $width.to_s)
		  		if (k == "x" || k == "y" || k == "xd" || k == "yd" || k == "r" || k == "g" || k == "b") && v.include?("~")
						item_data[k] = parse_range(v)
					else
						item_data[k] = v.to_i
					end
				else
					item_data[k] = v
				end
			end
			items.push item_data
		end
		Controller.new(items, parsed["duration"])
	end

	def parse_range(input)
		splits = input.split("~")
		splits.first.to_f..splits.last.to_f
	end
end

class Controller
		def initialize(data, duration)
			@data = data
			@duration = duration
		end

		def update(particles, frame)
			@data.each do |item|
				next if !(item["at"]..(item["at"] + item["d"] - 1)).include?(frame)
				item["n"].times { particles.push(Particle.new(get_value(item["x"]), get_value(item["y"]), get_value(item["xd"]), get_value(item["yd"]), Gosu::Color.new(get_value(item["r"]), get_value(item["g"]), get_value(item["b"])), $DEFAULT_GRAVITY)) }
			end
		end

		def get_value(property)
			property.is_a?(Range) ? $r.rand(property) : property
		end

		def to_s
			"Data: #{@data}"
		end
end

ParticleWindow.new.show()
