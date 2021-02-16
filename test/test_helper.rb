# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "active_date_range"
require "active_support"

require "minitest/autorun"

Time.zone = 'UTC'
