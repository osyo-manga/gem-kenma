# a < b < c
# ↓
# a < b && b < c
require "kenma"

using Kenma::Refine::Source

module ChainingComparisonOperatorsMacro
  using Kenma::Macroable
  using Kenma::Refine::NodeToArray

  def chaining_comparison_operators(node, parent)
    case node.to_a
    in [:OPCALL, [[:OPCALL, [left, op1, [:LIST, [middle, nil]]]], op2, [:LIST, [right, nil]]]]
      ast { $left.send(eval!(op1), $middle) && $middle.send(eval!(op2), $right) }
    else
      node
    end
  end
  macro_node :OPCALL, :chaining_comparison_operators
end

body = proc {
  use_macro! ChainingComparisonOperatorsMacro

  0 <= value < 10
}

result = Kenma.compile_of(body)
puts result.source

body = proc {
  use_macro! ChainingComparisonOperatorsMacro

  def check(value)
    # to 0 <= input && input < 10
    if 0 <= value < 10
      "OK"
    else
      "NG"
    end
  end
  check(10)

  puts check(5)   # => "OK"
  puts check(20)  # => "NG"
}
result = Kenma.compile_of(body)
puts result.source
# => begin def check(value)
#      (if (0.send(:<=, value) && value.send(:<, 10))
#      "OK"
#    else
#      "NG"
#    end)
#    end; check(10); puts(check(5)); puts(check(20)); end
