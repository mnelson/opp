# frozen_string_literal: true

require "test_helper"
require "subroutine/fields"

module Subroutine
  class FieldsTest < TestCase

    class Whatever

      include Subroutine::Fields

      string :foo, default: "foo"
      integer :bar, default: -> { 3 }, group: :sekret
      date :baz, group: :the_bazzes

      string :protekted, mass_assignable: false
      string :protekted_group_input, group: :sekret

      def initialize(options = {})
        setup_fields(options)
      end

    end

    def test_fields_are_configured
      assert_equal 5, Whatever.fields.size
      assert_equal :string, Whatever.fields[:foo][:type]
      assert_equal :integer, Whatever.fields[:bar][:type]
      assert_equal :date, Whatever.fields[:baz][:type]
      assert_equal :string, Whatever.fields[:protekted][:type]
      assert_equal :string, Whatever.fields[:protekted_group_input][:type]
    end

    def test_field_defaults_are_handled
      instance = Whatever.new
      assert_equal "foo", instance.foo
      assert_equal 3, instance.bar
    end

    def test_fields_can_be_provided
      instance = Whatever.new(foo: "abc", bar: nil)
      assert_equal "abc", instance.foo
      assert_nil instance.bar
    end

    def test_field_provided
      instance = Whatever.new(foo: "abc")
      assert_equal true, instance.field_provided?(:foo)
      assert_equal false, instance.field_provided?(:bar)

      instance = DefaultsOp.new
      assert_equal false, instance.field_provided?(:foo)

      instance = DefaultsOp.new(foo: "foo")
      assert_equal true, instance.field_provided?(:foo)
    end

    def test_field_provided_include_manual_assigned_fields
      instance = Whatever.new
      instance.foo = "bar"

      assert_equal true, instance.field_provided?(:foo)
      assert_equal false, instance.field_provided?(:bar)
    end

    def test_invalid_typecast
      assert_raises "Error for field `baz`: invalid date" do
        Whatever.new(baz: "2015-13-01")
      end
    end

    def test_params_include_defaults
      instance = Whatever.new(foo: "abc")
      assert_equal({ "foo" => "abc", "bar" => 3 }, instance.params)
      assert_equal({ "foo" => "foo", "bar" => 3 }, instance.defaults)
    end

    def test_fields_can_opt_out_of_mass_assignment
      assert_raises "`protekted` is not mass assignable" do
        Whatever.new(foo: "abc", protekted: "foo")
      end
    end

    def test_non_mass_assignment_fields_can_be_individually_assigned
      instance = Whatever.new(foo: "abc")
      instance.protekted = "bar"

      assert_equal "bar", instance.protekted
      assert_equal true, instance.field_provided?(:protekted)
    end

    def test_get_field
      instance = Whatever.new

      assert_equal "foo", instance.get_field(:foo)
    end

    def test_set_field
      instance = Whatever.new
      instance.set_field(:foo, "bar")

      assert_equal "bar", instance.foo
    end

    def test_group_fields_are_accessible_at_the_class
      results = Whatever.fields_in_group(:sekret)
      assert_equal true, results.key?(:protekted_group_input)
      assert_equal true, results.key?(:bar)
      assert_equal false, results.key?(:protekted)
    end

    def test_groups_fields_are_accessible
      op = Whatever.new(foo: "bar", protekted_group_input: "pgi", bar: 8)
      assert_equal({ protekted_group_input: "pgi", bar: 8 }.with_indifferent_access, op.sekret_params)
      assert_equal({ foo: "bar", protekted_group_input: "pgi", bar: 8 }.with_indifferent_access, op.params)
    end

  end
end
