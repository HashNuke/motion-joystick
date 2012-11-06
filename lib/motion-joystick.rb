unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Project::App.setup do |app|
  Dir.glob("cc_node.rb")
  Dir.glob(File.join(File.dirname(__FILE__), 'motion-joystick/*.rb')).each do |file|
    app.files.unshift(file)
  end
end
module Motion
  module Joystick
    # Your code goes here...
  end
end
