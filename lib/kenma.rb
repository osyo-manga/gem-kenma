# frozen_string_literal: true

require_relative "./kenma/version"
require_relative "./kenma/macro/core.rb"

module Kenma
  def self.of(body)
    Macro::Core.convert_of(body)
  end

  def self.pre_compile(body)
    Macro::Core.convert_of(body)
  end

  def self.compile(body)
    Macro::Core.convert_of(body)
  end
end
