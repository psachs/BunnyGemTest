require 'singleton'

class TestTracker
  include Singleton
  attr_accessor :work_started

  def initialize
    @work_started = 0
  end

  def inc
    @work_started+=1
  end

  def dec
    @work_started-=1
  end

  def reset
    @work_started=0
  end

  def done?
    @work_started<=0
  end
end