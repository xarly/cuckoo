#!/usr/bin/env ruby

require 'rubygems'
require 'rb-inotify'
require 'find'

notifier = INotify::Notifier.new
notifier.watch("/opt/cuckoo/foodforcuckoo", :recursive, :create, :moved_to) do |event|
        puts "New file found: #{event.absolute_name}"
        IO.popen("/opt/cuckoo/utils/checker.sh #{event.absolute_name}")
        sleep(5)
end
notifier.run
