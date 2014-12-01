#!/usr/local/bin/ruby
# coding: utf-8
#$prima=Time.now
#require 'K:\Ruby193_fast\lib\ruby\gems\1.9.1\gems\faster_require-0.9.2\lib\faster_require.rb'
require 'date'
require 'roo'
require 'docx'
require File.join(File.dirname(__FILE__), 'lib/Gui.rb')
require File.join(File.dirname(__FILE__), 'lib/soa.rb')
require File.join(File.dirname(__FILE__), 'lib/avvio.rb')

$F             = 'F:/'
$G             = 'G:/'
$controllomgp  = "MGP_1.1"
$settings      = Hash.new
$data          = nil
$year          = nil
$year_short    = nil
$month         = nil
$monthtext     = nil
$day           = nil
$week          = nil
window = GuiSoa.new
Gtk.main


