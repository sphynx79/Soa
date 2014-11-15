require File.join(File.dirname(__FILE__), 'utility.rb')

class Soa < Avvio
   attr_accessor :nome_controllo, :data, :zip, :file, :errore
   def initialize(nome, data)
      @nome_controllo  = nome 
      @data            = iniziallizza_data(data)
      @zip             = nil 
      @file            = Array.new
      @errore          = Hash.new
   end

   def iniziallizza_data(data)
      return {:data   => data, :year => data.strftime("%Y"), :month => data.strftime("%m"), :day => data.strftime("%d"), :mesetext => NumeroToMese(data.strftime("%m"))}
   end

   def inizializza_path
      path_file_zip 
      lista_file
   end


   def trova_email_autorizzazione
      #TODO: inserire il controllo di inizzio validita e fine validita
      file = Array.new
      case nome_controllo
      when /Autorizzazioni/ then
         file =  Pathname.glob("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/Verbali/*.msg")
         if file.size > 3
            errore["Autorizzazioni"] = "Attenzione sono stati trovati più di tre verbali autorizzativi"
         elsif file.size < 3
            errore["Autorizzazioni"] = "Attenzione non sono stati trovati tutti i verbali"
         end
      when /Estero/ then
         file =  Pathname.glob("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/Verbali/Verbale autorizzativo borse elettriche estere *.msg")
         if file.size > 1
            errore["Autorizzazione Estero"] = "Attenzione è stato trovato piu di un verbale autorizzativo Estero"
         elsif file.size == 0
            errore["Autorizzazione Estero"] = "Attenzione non è stato trovato nessun verbale autorizzativo Estero"
         end
      when /MGP/ then
         file =  Pathname.glob("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/Verbali/Verbale autorizzativo MGP-PCE *.msg")
         if file.size > 1
            errore["Autorizzazione MGP-PCE"] = "Attenzione è stato trovato piu di un verbale autorizzativo MGP-PCE"
         elsif file.size == 0
            errore["Autorizzazione MGP-PCE"] = "Attenzione non è stato trovato nessun verbale autorizzativo MGP-PCE"
         end
      when /MI/ then
         file =  Pathname.glob("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/Verbali/Verbale autorizzativo MI1-MI2-MI3-MI4 *.msg")
         if file.size > 1
            errore["Autorizzazione MI1-MI2-MI3-MI4"] = "Attenzione è stato trovato piu di un verbale autorizzativo MI1-MI2-MI3-MI4"
         elsif file.size == 0
            errore["Autorizzazione MI1-MI2-MI3-MI4"] = "Attenzione non è stato trovato nessun verbale autorizzativo MI1-MI2-MI3-MI4"
         end
      end
      return file
   end

   def path_file_zip 
      case nome_controllo
      when "Autorizzazioni"    then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_0.zip")
      when "MGP_Validate"      then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_1.zip")
      when "MGP_Esitate"       then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_2.zip")
      when "MI_Form"           then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_3.zip")
      when "MI_Form_D"         then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_10.zip")
      when "MI_Validate"       then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_4.zip")
      when "MI_Validate_D"     then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_11.zip")
      when "MI_Esitate"        then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_5.zip")
      when "MI_Esitate_D"      then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_12.zip")
      when "Vpp"               then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/File Zip/VPP_#{data[:day]}#{data[:month]}#{data[:year].to_s[-2..-1]}_week_#{(data.data).cweek}.zip")
      when "Estero_Validate"   then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/FRANCIA/SOA FRANCIA/03 File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_6.zip")
      when "Estero_Esitate"    then @zip = Pathname.new("#{$F}PROGRAMMAZIONE #{data[:year]}/FRANCIA/SOA FRANCIA/03 File Zip/#{data[:day]} #{data[:mesetext]} #{data[:year]}_7.zip")
      else @zip = nil
      end
   end


   def lista_file
      case nome_controllo
      when "Autorizzazioni"                  then
         trova_email_autorizzazione  "tutte"
      when "MGP_Validate"                    then
         files = ["#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/SOA Italia/Validate/Validate_Eni_#{data[:day]}#{data[:month]}#{data[:year]}.xls",
                  "#{$G}MEOR/PROGRAMMAZIONE #{data[:year]}/Controllo Prezzi MGP/Prezzi_Offerte_#{$ControlloMGP}_#{data[:day]}#{data[:month]}#{data[:year]}.xls",
                  "#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/Giornaliero/Programmazione Fisica PCE/#{data[:month]} #{data[:mesetext]} #{data[:year]}/Validati/ProgrFisica_ENIIMMISSIONE_#{data[:year].to_s[2..3]}#{data[:month]}#{data[:day]}.xls",
                  "#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/Giornaliero/Programmazione Fisica PCE/#{data[:month]} #{data[:mesetext]} #{data[:year]}/Validati/ProgrFisica_ENIPOWER MANTOVA_#{data[:year].to_s[2..3]}#{data[:month]}#{data[:day]}.xls",
                  "#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/Giornaliero/Programmazione Fisica PCE/#{data[:month]} #{data[:mesetext]} #{data[:year]}/Validati/ProgrFisica_ENIPOWER_#{data[:year].to_s[2..3]}#{data[:month]}#{data[:day]}.xls",
                  "#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/Giornaliero/Programmazione Fisica PCE/#{data[:month]} #{data[:mesetext]} #{data[:year]}/Validati/ProgrFisica_SEF_#{data[:year].to_s[2..3]}#{data[:month]}#{data[:day]}.xls",
                  "#{$F}PROGRAMMAZIONE #{data[:year]}/ITALIA/Report/Giornaliero/Programmazione Fisica PCE/#{data[:month]} #{data[:mesetext]} #{data[:year]}/Validati/ProgrFisica_ENIPRELIEVO_#{data[:year].to_s[2..3]}#{data[:month]}#{data[:day]}.xls"
         ]
      when "MGP_Esitate"                     then

      when "Estero_Validate"                 then

      when "Estero_Esitate"                  then

      when "MI_Form_D"                       then

      when "MI_Esitate"                      then

      when "MI_Validate"                     then

      when "MI_Validate_D"                   then

      when "MI_Esitate_D"                    then

      when "Vpp"                             then

      end
      trova_file(files)
      
      
   end


   def trova_file(files)
         files.each do |file|
            if result = controRev(file)
               @file << result
            else
               dir, base = File.split(Pathname.new(file))
               errore[base.to_s] = "Non è stato trovato il file #{base.to_s} nella directory #{dir.to_s}"
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



end




