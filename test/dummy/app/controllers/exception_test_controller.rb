# frozen_string_literal: true

class ExceptionTestController < ApplicationController
  def index
    test = "Test"
    test_method
  end

  def xhr
    raise "asda" if request.xhr?
  end

  def test_method
    test2 = "Test2"
    params.fetch(:error_in_library_code)
  end
end
