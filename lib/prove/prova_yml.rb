require "pathname"
require 'yaml'
require 'ap'

a = ["|F|PROGRAMMAZIONE |YEAR|/ITALIA/Report/SOA Italia/File Zip/soa_vpp/mail/", "michele"]
dsasd= "soa_vpp"
c =  a.select{|x| x.match dsasd }
p c
CONF=File.join(File.dirname(__FILE__), "settings.yml")

test = {:MGP => ["ciao","come","ti","chiami"], :VPP => {:email=>"c:/ciao/michele", :path =>"D:/bo/che/ne/so"}}

File.open(CONF, "w") do |file|
   file.write (test).to_yaml
end


settings = YAML::load_file CONF
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

