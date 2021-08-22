# frozen_string_literal: true

require_relative "./kenma/version"
require_relative "./kenma/pre_processor.rb"
require_relative "./kenma/iteration.rb"

module Kenma
  def self.compile(body, context = {})
    PreProcessor.compile(body, context)
  end

  def self.compile_of(body, context = {})
    PreProcessor.compile_of(body, context)
  end
end
