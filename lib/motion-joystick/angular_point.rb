module Motion
  module Joystick

    class AngularPoint
      attr_accessor :heading, :radius

      def initialize(heading, radius)
        @heading = heading
        @radius  = radius
      end
    end

  end
end