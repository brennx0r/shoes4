class Shoes
  module Common
    module Hover
      attr_reader :hover_blk, :leave_blk

      def self.included(base)
        clazz = Class.new {}
        name = base.name.split("::").last
        Shoes.const_set("#{name}Hover", clazz)
      end

      def hover(&blk)
        @hover_blk = blk
        add_mouse_hover_control
      end

      def leave(&blk)
        @leave_blk = blk
        add_mouse_hover_control
      end

      def hovered?
        @hovered
      end

      def eval_in_parent?
        false
      end

      def hover_class
        return @hover_class if @hover_class

        name = self.class.name.split("::").last
        @hover_class = Shoes.const_get("#{name}Hover")
      end

      def mouse_hovered
        return if @hovered

        @hovered = true

        apply_style_from_hover_class
        target.eval_hover_block(@hover_blk)
      end

      def mouse_left
        return unless @hovered

        @hovered = false

        apply_style_from_pre_hover
        target.eval_hover_block(@leave_blk)
      end

      def add_mouse_hover_control
        app.add_mouse_hover_control(self)
      end

      def target
        target = self
        target = parent if eval_in_parent?
        target
      end

      def eval_hover_block(blk)
        blk.call(self) if blk
      end

      def apply_style_from_hover_class
        hover_style = @app.element_styles[self.hover_class]
        return unless hover_style

        @pre_hover_style = hover_style.inject({}) do |memo, (key, _)|
          memo[key] = self.style[key]
          memo
        end

        self.style(hover_style)
      end

      def apply_style_from_pre_hover
        self.style(@pre_hover_style) if @pre_hover_style
        @pre_hover_style = nil
      end
    end
  end
end
