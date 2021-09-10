require "kenma"

using Kenma::Refine::Source

module MultiUsingMacro
  using Kenma::Macroable
  using Kenma::Refine::NodeToArray

  def using(*args)
    args.compact.inject(ast { {} }) { |result, name|
      ast { $result; using $name }
    }
  end
  macro_function :using
end


body = proc {
  use_macro! MultiUsingMacro

  using Hoge, Foo, Bar
}

result = Kenma.compile_of(body)
puts result.source
# => begin begin begin {}; using(Hoge); end; using(Foo); end; using(Bar); end;
