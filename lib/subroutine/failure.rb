# frozen_string_literal: true

module Subroutine
  class Failure < StandardError

    attr_accessor :errors

    def initialize(record)
      errors = record.respond_to?(:errors) ? record.errors.full_messages.join(', ') : record
      super(errors)
    end
  end
end
