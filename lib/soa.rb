require File.join(File.dirname(__FILE__), 'utility.rb')

class Soa 
   attr_accessor :nome_controllo, :data, :zip, :file, :errore
   def initialize(nome)
      @nome_controllo  = nome 
      @zip             = nil 
      @file            = Array.new
      @errore          = Hash.new
   end

   def inizializza_path
      path_file_zip 
      lista_file
   end

   def trova_email_autorizzazione
      #TODO: inserire il controllo di inizzio validita e fine validita
      email = Array.new
      case nome_controllo
      when /Autorizzazioni/ then
         email =  Pathname.glob("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/Verbali/*.msg")
         if email.size > 3
            errore["Autorizzazioni"] = "Attenzione sono stati trovati più di tre verbali autorizzativi"
         elsif email.size < 3
            errore["Autorizzazioni"] = "Attenzione non sono stati trovati tutti i verbali"
         end
      when /Estero/ then
         email =  Pathname.glob("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/Verbali/Verbale autorizzativo borse elettriche estere *.msg")
         if email.size > 1
            errore["Autorizzazione Estero"] = "Attenzione è stato trovato piu di un verbale autorizzativo Estero"
         elsif email.size == 0
            errore["Autorizzazione Estero"] = "Attenzione non è stato trovato nessun verbale autorizzativo Estero"
         end
      when /MGP/ then
         email =  Pathname.glob("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/Verbali/Verbale autorizzativo MGP-PCE *.msg")
         if email.size > 1
            errore["Autorizzazione MGP-PCE"] = "Attenzione è stato trovato piu di un verbale autorizzativo MGP-PCE"
         elsif email.size == 0
            errore["Autorizzazione MGP-PCE"] = "Attenzione non è stato trovato nessun verbale autorizzativo MGP-PCE"
         end
      when /MI/ then
         email =  Pathname.glob("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/Verbali/Verbale autorizzativo MI1-MI2-MI3-MI4 *.msg")
         if email.size > 1
            errore["Autorizzazione MI1-MI2-MI3-MI4"] = "Attenzione è stato trovato piu di un verbale autorizzativo MI1-MI2-MI3-MI4"
         elsif email.size == 0
            errore["Autorizzazione MI1-MI2-MI3-MI4"] = "Attenzione non è stato trovato nessun verbale autorizzativo MI1-MI2-MI3-MI4"
         end
      end
      return email
   end

   def path_file_zip 
      case nome_controllo
      when "Autorizzazioni"    then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/#{$day} #{$monthtext} #{$year}_0.zip")
      when "MGP_Validate"      then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/#{$day} #{$monthtext} #{$year}_1.zip")
      when "MGP_Esitate"       then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/#{$day} #{$monthtext} #{$year}_2.zip")
      when "MI_Form"           then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/#{$day} #{$monthtext} #{$year}_3.zip")
      when "MI_Form_D"         then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/#{$day} #{$monthtext} #{$year}_10.zip")
      when "MI_Validate"       then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/#{$day} #{$monthtext} #{$year}_4.zip")
      when "MI_Validate_D"     then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/#{$day} #{$monthtext} #{$year}_11.zip")
      when "MI_Esitate"        then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/#{$day} #{$monthtext} #{$year}_5.zip")
      when "MI_Esitate_D"      then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/#{$day} #{$monthtext} #{$year}_12.zip")
      when "Estero_Validate"   then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/FRANCIA/SOA FRANCIA/03 File Zip/#{$day} #{$monthtext} #{$year}_6.zip")
      when "Estero_Esitate"    then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/FRANCIA/SOA FRANCIA/03 File Zip/#{$day} #{$monthtext} #{$year}_7.zip")
      when "Vpp"               then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/VPP_#{$day}#{$monthtext}#{$year_short}_week_#{$week}.zip")
      else @zip = nil
      end
   end

   def lista_file
      files = case nome_controllo
              when "Autorizzazioni"      then nil 
              when "MGP_Validate"        then $settings["MGP_Validate_File"]
              when "MGP_Esitate"         then $settings["MGP_Esitate_File"]
              when "Estero_Validate"     then $settings["Estero_Validate_File"]
              when "Estero_Esitate"      then $settings["Estero_Esitate_File"]
              when "MI_Form"           then $settings["MI_Form_File"]
              when "MI_Validate"         then $settings["MI_Validate_File"]
              when "MI_Esitate"          then $settings["MI_Esitate_File"]
              when "MI_Form_D"           then $settings["MI_Form_File"]
              when "MI_Validate_D"       then nil
              when "MI_Esitate_D"        then nil
              when "Vpp"                 then nil
              end
      ap files
      trova_file(files)
   end

   def trova_file(files)
      if files != nil
         files.each do |file|
            if result = controRev(file)
               @file << result
            else
               dir, base = File.split(Pathname.new(file))
               errore[base.to_s] = "Non è stato trovato il file #{base.to_s} nella directory #{dir.to_s}"
            end
         end
      end
      email = trova_email_autorizzazione
      email.each{|f| @file << f} unless email.empty?      
   end

   def controRev(file)
      pathname = Pathname.new(file)
      if (pathname.sub(".xls","_rev2.xls")).exist?
         return (pathname.sub(".xls","_rev2.xls"))
      elsif (pathname.sub(".xls","_rev1.xls")).exist?
         return (pathname.sub(".xls","_rev1.xls"))
      elsif pathname.exist?
         return pathname
      else
         return false
      end
   end

   def crea_zip
      @zip.delete if @zip.exist?
      Zip::File.open(@zip, Zip::File::CREATE) do |zf|
         @file.each do |f|
            if f.fnmatch?("*/ProgrFisica_*")
               if f.fnmatch?("*/Validati/*")
                  zf.mkdir("validate_pce") if zf.find_entry("validate_pce") == nil
                  zf.add("validate_pce"+"/"+(f.basename).to_s, f)
               else
                  zf.mkdir("esitate_pce") if zf.find_entry("esitate_pce") == nil
                  zf.add("esitate_pce"+"/"+(f.basename).to_s, f)
               end
            else
               zf.add(f.basename, f)
            end
         end
      end
   end


end




