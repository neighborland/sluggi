# frozen_string_literal: true

require "test_helper"

class ValidatePresenceTest < MiniTest::Spec
  class Cat < ActiveRecord::Base
    include Sluggi::ValidatePresence
  end

  it "validates presence of slug" do
    refute Cat.new(slug: "").valid?
    assert Cat.new(slug: "foo").valid?
  end
end
