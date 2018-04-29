# frozen_string_literal: true

require "test_helper"

module WebConsole
  class InjectorTest < ActiveSupport::TestCase
    test "closes body if closable" do
      closed = false

      body = [ "foo" ]
      body.define_singleton_method(:close) { closed = true }

      assert_equal [ [ "foobar" ], {} ], Injector.new(body, {}).inject("bar")
      assert closed
    end

    test "support fancy bodies like Rack::BodyProxy" do
      closed = false
      body = Rack::BodyProxy.new([ "foo" ]) { closed = true }

      assert_equal [ [ "foobar" ], {} ], Injector.new(body, {}).inject("bar")
      assert closed
    end

    test "support fancy bodies like ActionDispatch::Response::RackBody" do
      body = ActionDispatch::Response.create(200, {}, [ "foo" ]).to_a.last

      assert_equal [ [ "foobar" ], {} ], Injector.new(body, {}).inject("bar")
    end

    test "deletes the Content-Length header" do
      body = [ "foo" ]
      headers = { "Content-Length" => 3 }

      assert_equal [ [ "foobar" ], {} ], Injector.new(body, headers).inject("bar")
    end
  end
end
