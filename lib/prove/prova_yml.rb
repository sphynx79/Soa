require "pathname"
require 'yaml'
require 'ap'

class Array
   def parse_path()
      each{|k| yield(k)}
   end
end


year = "2014"
year_short = "14"
month = "11"
day   = "17"
mesetext = "Novembre"
disco_f = "F:/"
disco_g = "G:/"
vers_cont_mgp = "MGP_1.1"


CONF=File.join(File.dirname(__FILE__), "settings.yml")
settings = YAML::load_file CONF

settings.each{|k,v|
   v.collect!{|x|
   x.gsub!("|YEAR|", year)
   x.gsub!("|YEAR_SHORT|", year_short)
   x.gsub!("|MONTH|", month)
   x.gsub!("|DAY|", day)
   x.gsub!("|MESETEXT|", mesetext)
   x.gsub!("|F|", disco_f)
   x.gsub!("|G|", disco_g)
   x.gsub!("|V_CONTROOLLO_MGP|", vers_cont_mgp)
   x
}
}
ap settings



# settings["MGP_Validate"].parse_path{|x|
#    x.gsub!("|YEAR|", year)
#    x.gsub!("|YEAR_SHORT|", year_short)
#    x.gsub!("|MONTH|", month)
#    x.gsub!("|DAY|", day)
#    x.gsub!("|MESETEXT|", mesetext)
#    x.gsub!("|F|", disco_f)
#    x.gsub!("|G|", disco_g)
#    x.gsub!("|V_CONTROOLLO_MGP|", vers_cont_mgp)
# }




#substitution_hash = {:fourth_member => 'Joan',
#                     :time => Time.new.strftime("%m/%d/%y")}
#hash.each_pair do |key, value|
#  value = substitution_hash[value] if value.class == Symbol
#  puts "Value for key \"#{key}\" is: \"#{value}\""
#end

