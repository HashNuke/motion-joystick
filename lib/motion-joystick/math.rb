module Motion
  module Joystick
    class Math

      def radians_to_degrees(angle)
        angle * 57.29577951
      end

      def calcCompMult(a, b)
        a = CGPointMake(a[0], a[1]) if a.is_a?(Array)
        b = CGPointMake(b[0], b[1]) if b.is_a?(Array)
        CGPointMake(a.x * b.x, a.y * b.y)
      end

      def calcDot(v1, v2)
        v1 = CGPointMake(v1[0], v2[1]) if v1.is_a?(Array)
        v2 = CGPointMake(v2[0], v1[1]) if v2.is_a?(Array)
        (v1.x * v2.x) + (v1.y * v2.y)
      end

      def calcLengthSQ(v)
        v = CGPointMake(v[0], v[1]) if v.is_a?(Array)
        calcDot(v, v)
      end

      def calcLength(v)
        v = CGPointMake(v[0], v[1]) if v.is_a?(Array)
        ::Math.sqrt calcLengthSQ(v)
      end

      def calcToAngle(v)
        v = CGPointMake(v[0], v[1]) if v.is_a?(Array)
        return 0 if v.x.abs < 0.6 && v.y.abs < 0.6
        ::Math.atan2(v.y, v.x)
      end

      def calcAdd(v1, v2)
        v1 = CGPointMake(v1[0], v2[1]) if v1.is_a?(Array)
        v2 = CGPointMake(v2[0], v1[1]) if v2.is_a?(Array)
        [v1.x + v2.x, v1.y + v2.y]
      end

      def calcSub(v1, v2)
        v1 = CGPointMake(v1[0], v2[1]) if v1.is_a?(Array)
        v2 = CGPointMake(v2[0], v1[1]) if v2.is_a?(Array)
        [v1.x - v2.x, v1.y - v2.y]
      end

      def calcMult(v, s)
        v = CGPointMake(v[0], v[1]) if v.is_a?(Array)
        [v.x*s, v.y*s]
      end

      def calcFromSize(s)
        CGPointMake(s.width, s.height)
      end

    end
  end
end