# debug! 1 + 2
# ↓
# puts "1 + 2 # => #{1 + 2}"
require "kenma"

using Kenma::Refine::Source

module DebugMacro
  using Kenma::Macroable

  def debug!(expr)
    ast { puts "#{stringify! $expr} # => #{$expr}" }
  end
  macro_function :debug!
end

body = proc {
  use_macro! DebugMacro

  debug! 1 + 2 + 3
  debug! [1, 2, 3].map { _1 + _1 }
}
puts Kenma.compile_of(body).source
# => begin puts("#{"((1 + 2) + 3)"} # => #{((1 + 2) + 3)}"); puts("#{"[1, 2, 3].map() { (_1 + _1) }"} # => #{[1, 2, 3].map() { (_1 + _1) }}"); end
