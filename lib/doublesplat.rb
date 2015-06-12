require "doublesplat/version"
require "rainbow"

module Doublesplat
  class Chatter
    def say_hello
      puts Rainbow('This is doublesplat. Coming in loud and clear. Over.').blue
    end
  end
end
