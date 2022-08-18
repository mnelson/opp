# frozen_string_literal: true

module Subroutine
  class Failure < StandardError

    attr_accessor :record, :errors

    def initialize(record)
      # a StandardError takes a string, but we want to be able to also keep
      # track of a more advanced error state
      # https://api.rubyonrails.org/v5.2/classes/ActiveModel/Errors.html
      #
      if record.respond_to?(:errors) && record.errors.is_a?(ActiveModel::Errors)
        @record = record
        @errors = @record.errors.full_messages.join(', ')
      else
        raise ArgumentError.new "subroutine failure - record is #{record}"
        # @record = ActiveModel::Errors.new

        # generate a new errors class....
        #
      end

      super(errors)
    end
  end
end
