require "spec_helper"
require_relative "../lib/modtest.rb"

describe "Thing" do
  it "has a version number" do
    expect(Modtest::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
