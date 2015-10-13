require 'gosu'

class ParticleWindow < Gosu::Window

	DEAFULT_GRAVITY = 0.05

	def initialize(width = 800, height = 600, fullscreen = true)
		super
		self.caption = "Particles"

		@width = width
		@height = height
		@intensity = 1
		@font = Gosu::Font.new(20)
		@particles = []
		@r = Random.new
	end

	def button_down(id)
		close if id == Gosu::KbEscape
		@particles.clear if id == Gosu::KbC
	end

	def update
		@intensity += 1 if Gosu.button_down?(Gosu::KbUp)
		@intensity -= 1 if Gosu.button_down?(Gosu::KbDown) && @intensity > 1
		if Gosu.button_down?(Gosu::MsLeft)
			particle_spawner(mouse_x, mouse_y, -8..8, 3..4, random_color(), @intensity)
		end
		@particles.each(&:update)
		@particles.delete_if { |particle| !particle.x.between?(0, @width) || !particle.y.between?(-@height, @height) }
	end

	def particle_spawner(x, y, xd_range, yd_range, c, particles_count)
		particles_count.times do
			@particles.push(Particle.new(x, y, @r.rand(xd_range), -@r.rand(yd_range), c, DEAFULT_GRAVITY))
		end
	end

	def random_color
		Gosu::Color.new(@r.rand(0..255), @r.rand(0..255), @r.rand(0..255))
	end

	def draw
		@font.draw("Particles: #{@particles.size}", 10, 10, 0)
		Gosu.draw_rect(mouse_x, mouse_y, 10, 10, Gosu::Color.new(255, 255, 255, 0))
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

ParticleWindow.new.show()
