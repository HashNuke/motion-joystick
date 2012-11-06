module Motion
  module Joystick
    class Control < CCLayerColor
      include ::Motion::Joystick::Math

      attr_accessor :thumb_node, :background_node, :tracking, :player, :jumping
      attr_accessor :velocity, :angular_velocity

      def jumping?
        @jumping
      end

      def onEnter
        self.isTouchEnabled = true
        registerWithTouchDispatcher
      end

      def anchorPointInPoints
        calcCompMult(calcFromSize(self.contentSize), self.anchorPoint)
      end

      def initWithPlayer(player, thumb_node: thumb_node, background_node: background_node)
        @jumping = false
        @tracking = false
        @velocity = CGPointZero
        @angular_velocity = AngularPoint.new 0, 0
        @player = player
        @thumb_node = thumb_node
        @background_node = background_node

        @thumb_node.setPosition self.anchorPointInPoints
        @background_node.setPosition self.anchorPointInPoints

        self.addChild(@background_node)
        self.addChild(@thumb_node)
        self
      end

      def registerWithTouchDispatcher
        # Using -128 in place of KCCMenuTouchPriority
        CCTouchDispatcher.
          sharedDispatcher.
          addTargetedDelegate(self, priority: -128, swallowsTouches: true)
        reset_velocity
      end

      def onExit
        CCTouchDispatcher.sharedDispatcher.removeDelegate(self)
        super
      end

      def tracking?
        @tracking
      end

      def track_velocity(nodeTouchPoint)
        anchor_point   = self.anchorPointInPoints
        relative_point = calcSub(nodeTouchPoint, anchor_point)

        if relative_point.kind_of?(Array)
          relative_point = CGPointMake(relative_point[0], relative_point[1])
        end

        if @travel_limit.kind_of?(Array)
          @travel_limit = CGPointMake(@travel_limit[0], @travel_limit[1])
        end

        raw_velocity = CGPointMake(relative_point.x / @travel_limit.x,
                        relative_point.y / @travel_limit.y)

        @velocity    = velocity_from_raw_velocity raw_velocity

        angle = 90.0 - radians_to_degrees(calcToAngle(@velocity))
        angle = angle - 360.0 if angle > 180.0

        puts "angle #{angle}"

        @angular_velocity.radius = calcLength(@velocity)
        @angular_velocity.heading = angle

        @thumb_node.setPosition calcAdd(calcCompMult(@velocity, @travel_limit), anchor_point)
      end

      def reset_velocity
        @tracking = false
        @velocity = CGPointZero
        @angular_velocity = AngularPoint.new 0,0

        # move_action    = CCMoveTo.actionWithDuration(1.0, position: self.anchorPointInPoints)
        # easeout_action = CCEaseElasticOut.actionWithAction(move_action)
        #@thumb_node.runAction easeout_action
        @thumb_node.setPosition self.anchorPointInPoints
      end

      def velocity_from_raw_velocity(raw_velocity)
        raw_velocity_length = calcLength raw_velocity
        if raw_velocity_length <= 1.0
          raw_velocity
        else
          calcMult(raw_velocity, 1.0/raw_velocity_length)
        end
      end

      def ccTouchBegan(touch, withEvent: event)
        unless tracking?
          cs = self.contentSize
          nodeBounds = CGRectMake(0, 0, cs.width, cs.height)
          nodeTouchPoint = self.convertTouchToNodeSpace(touch)
          if CGRectContainsPoint(nodeBounds, nodeTouchPoint)
            @tracking = true
            @thumb_node.stopAllActions()
            track_velocity nodeTouchPoint
            CCScheduler.sharedScheduler.scheduleSelector('move_player', forTarget:self, interval:0.20, paused:false)
            return true
          end
        end
        false
      end

      def direction_for_angle(av)
        angle = av.heading
        return :top_left     if (-70..-35).include?(angle)
        return :top_right    if (35..70).include?(angle)
        return :bottom_left  if (-150..-110).include?(angle)
        return :bottom_right if (110..150).include?(angle)
        return :top          if (-35..35).include?(angle)
        return :bottom       if (-180..-150).include?(angle) || (150..180).include?(angle)
        return :left         if (-150..-70).include?(angle)
        return :right        if (70..150).include?(angle)
      end

      def move_player
        direction = direction_for_angle(@angular_velocity)
        basic_offset = 60
        return true if jumping?
        if [:top, :top_right, :top_left].include?(direction)
          delta_position = [0, 0]              if direction == :top
          delta_position = [basic_offset, 0]   if direction == :top_right
          delta_position = [-basic_offset, 0]  if direction == :top_left
          player_action = CCJumpBy.actionWithDuration(0.20,
            position: delta_position,
            height:   @player.contentSize.height*2,
            jumps: 1)
        else
          delta_position = [basic_offset, 0]  if direction == :right
          delta_position = [-basic_offset, 0] if direction == :left
          delta_position = [0, -basic_offset] if direction == :bottom

          delta_position = [basic_offset, -basic_offset]  if direction == :bottom_right
          delta_position = [-basic_offset, -basic_offset] if direction == :bottom_left
          player_action = CCMoveBy.actionWithDuration(0.20, position: delta_position)
        end
        @player.runAction player_action
      end

      def ccTouchEnded(touch, withEvent: event)
        CCScheduler.sharedScheduler.unscheduleSelector('move_player', forTarget: self)
        reset_velocity
      end

      def ccTouchCancelled(touch, withEvent: event)
        reset_velocity
      end

      def ccTouchMoved(touch, withEvent: event)
        track_velocity(self.convertTouchToNodeSpace touch)
      end

      def dealloc
        @thumb_node = nil
        super
      end

      def setContentSize(newSize)
        super(newSize)
        if @thumb_node
          @travel_limit = calcMult(
            calcSub(
              calcFromSize(self.contentSize),
              calcFromSize(@thumb_node.scaledSize)
            ),
            0.5
          )
        end
      end
    end
  end
end