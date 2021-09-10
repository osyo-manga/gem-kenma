require "kenma"

using Kenma::Refine::Source

module ShorthandHashLiteralMacro
  using Kenma::Macroable

  def shorthand_hash_literal(node, args:)
    args.children.compact.inject(ast { {} }) { |result, name|
      ast { $result.merge({ symbolify!($name) => $name }) }
    }
  end
  macro_pattern pat { ![*$args] }, :shorthand_hash_literal
end

body = proc {
  use_macro! ShorthandHashLiteralMacro

  ![a, b, c]
}

result = Kenma.compile_of(body)
puts result.source
# => {}.merge({ a: a }).merge({ b: b }).merge({ c: c });
