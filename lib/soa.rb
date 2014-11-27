require File.join(File.dirname(__FILE__), 'utility.rb')
require_relative 'mapi/msg'
TMP_FOLDER =  File.dirname(__FILE__)+"/tmp/"

class Soa 
   attr_accessor :nome_controllo, :data, :zip, :file, :errore
   def initialize(nome)
      @nome_controllo  = nome 
      @zip             = nil 
      @file            = Array.new
      @errore          = Array.new
   end

   #
   # Inizializzo i path dove mettere il file zip, e dove sono
   # tutti i file da inserire dentro lo zip
   #
   def inizializza_path
      path_file_zip 
      lista_file
      check_file
   end

   # Cerco l'e-mail delle autorizzazioni, se non le trova inserisco l'errore nella variabile d'istanza [Array] @errore
   #
   # @return [Array<Pathname>] contenente i path delle mie autorizzazioni
   #
   def trova_email_autorizzazione
      #TODO: inserire il controllo di inizzio validita e fine validita
      email = Array.new
      case nome_controllo
      when /Autorizzazioni/ then
         email =  Pathname.glob("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/Verbali/*.msg")
         if email.size > 3
            errore << "Attenzione sono stati trovati più di tre verbali autorizzativi"
         elsif email.size < 3
            errore << "Attenzione non sono stati trovati tutti i verbali"
         end
      when /Estero/ then
         email =  Pathname.glob("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/Verbali/Verbale autorizzativo borse elettriche estere *.msg")
         if email.size > 1
            errore << "Attenzione è stato trovato piu di un verbale autorizzativo Estero"
         elsif email.size == 0
            errore << "Attenzione non è stato trovato nessun verbale autorizzativo Estero"
         end
      when /MGP/ then
         email =  Pathname.glob("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/Verbali/Verbale autorizzativo MGP-PCE *.msg")
         if email.size > 1
            errore << "Attenzione è stato trovato piu di un verbale autorizzativo MGP-PCE"
         elsif email.size == 0
            errore << "Attenzione non è stato trovato nessun verbale autorizzativo MGP-PCE"
         end
      when /MI/ then
         email =  Pathname.glob("#{$F}PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/Verbali/Verbale autorizzativo MI1-MI2-MI3-MI4 *.msg")
         if email.size > 1
            errore << "Attenzione è stato trovato piu di un verbale autorizzativo MI1-MI2-MI3-MI4"
         elsif email.size == 0
            errore << "Attenzione non è stato trovato nessun verbale autorizzativo MI1-MI2-MI3-MI4"
         end
      end
      return email
   end

   #
   # Inizializzo il path dove mettere il file zip
   #
   # @todo inserire i path degli zip dentro il file setting.yml
   #
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

   #
   # Prendo dalla variabile globale $settings i path dove si trovano i file
   # e attravero la chiamata a {#trova_file} cerco tutti i file che mi servono
   #
   def lista_file
      files = case nome_controllo
              when "Autorizzazioni"      then nil 
              when "MGP_Validate"        then $settings[:MGP_Validate_File]
              when "MGP_Esitate"         then $settings[:MGP_Esitate_File]
              when "Estero_Validate"     then $settings[:Estero_Validate_File]
              when "Estero_Esitate"      then $settings[:Estero_Esitate_File]
              when "MI_Form"             then $settings[:MI_Form_File]
              when "MI_Validate"         then $settings[:MI_Validate_File]
              when "MI_Esitate"          then $settings[:MI_Esitate_File]
              when "MI_Form_D"           then $settings[:MI_D_Form_File]
              when "MI_Validate_D"       then $settings[:MI_D_Validate_File]
              when "MI_Esitate_D"        then $settings[:MI_D_Esitate_File]
              when "Vpp"                 then nil
              end
      trova_file(files)
   end

   #
   # Inserisco dentro la variabile d'istanza @file l'ultima versione dei file che mi servono
   # 1. Scorro la lista dei file da inserire 
   # 2. Cerco l'ultima versione del file disponibile
   # 3. Se lo trova lo inserisce nella variabile d'istanza [Array] @file,
   #    altrimente scrive l'errore nella variabile d'istanza [Array] @errore 
   # 4. Cerca l'e-mail delle autorizzazioni e le inserisce dentro @file
   #
   # @example
   #     @file   = ["[#<Pathname:C:/PROGRAMMAZIONE 2014/ITALIA/Report/SOA Italia/Validate/Validate_Eni_09112014.xls>,#<Pathname:C:/MEOR/PROGRAMMAZIONE 2014/Controllo Prezzi MGP/Prezzi_Offerte_MGP_1.1_09112014.xls>]
   #     @errore = ["01_AutorizzazioneEpexCH_ENI_20141109.xls" => "File non trovato nella directory ....."]
   #
   # @param [Array] files Lista file da inserire nello zip
   # 
   def trova_file(files)
      if files != nil
         files.each do |file|
            if result = controRev(file)
               @file << result
            else
               dir, base = File.split(Pathname.new(file))
               errore << "Non è stato trovato il file #{base.to_s} nella directory #{dir.to_s}"
            end
         end
      end
      email = trova_email_autorizzazione
      email.each{|f| @file << f} unless email.empty?      
   end

   #
   # Cerco l'ultima versione del file disponibile
   # @param [String] file path del file da cercare 
   # 
   # @return [Pathname] se trova il file che mi server
   # @return [false] se non trova il file che mi interessa
   #
   def controRev(file)
      pathname = Pathname.new(file)
      ext = "xls"
      if file.match("csv")
         ext = "csv"
      end

      if (pathname.sub(".xls","_rev2.#{ext}")).exist?
         return (pathname.sub(".xls","_rev2.#{ext}"))
      elsif (pathname.sub(".xls","_rev1.#{ext}")).exist?
         return (pathname.sub(".xls","_rev1.#{ext}"))
      elsif pathname.exist?
         return pathname
      else
         return false
      end
   end

   #
   # Mi cre il file zip e ci mette tutti i file che ha trovato
   # 1. Cancello il file zip se già presente
   # 2. Creo lo zip
   # 3. Controllo se il nome del file contiene ProgrFisica_
   # 4. Se si, controllo se sono validate o esitate e creo la cartella dntro lo zip se non presente
   # 5. Altrimenti inserisco il file nello zip
   #
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

   #
   # Esegue i controlli dei file da inserire negli zip
   # 1. Scorro i file da inserire nello zip
   # 2. Controllo il tipo di file, e lancio il relativo controllo
   #
   def check_file
      @file.each do |file|
         case 
         when file.fnmatch("*Verbale autorizzativo*")     then check_verbale(estrai_allegato(file))
         when file.fnmatch("*Prezzi_Offerte*")            then check_controllo_offerte(file)
         when file.fnmatch("*Validate_Eni*")              then check_offerte(file)
         when file.fnmatch("*Esitate_Eni*")               then check_offerte(file)
         #when file.fnmatch("*ProgrFisica*")               then check_offerte(file)
         else

         end
      end
   end

   #
   # Controllo le date dei verbali
   #
   # @param [String] allegato path del file excel del verbale
   # 
   def check_verbale(allegato)
      sheet = Roo::Excelx.new(allegato).sheet(0)
      unless $data.between? (sheet.row(9)[1]),(sheet.row(10)[1])
         errore << "Il giorno selezionato non rietra tra le date presenti nel verbale #{Pathname.new(allegato).basename}"
      end
      File.delete(allegato) if File.exist?(allegato)
   end

   #
   # Estra gli allegati dalle e-mail
   #
   # @param [String] email del verbale da voce estrarre l'allegato
   # @return [sting] path del file excel estratto
   #
   def estrai_allegato(email)
      msg = Mapi::Msg.open(email.to_s)
      allegato = msg.attachments.find { |h| (h.filename).match("xlsx")}
      tmp_file = open(TMP_FOLDER+ "/"+ File.basename(allegato.filename), 'wb') 
      allegato.save tmp_file
      tmp_file.close
      return TMP_FOLDER+ "/"+ File.basename(allegato.filename)
   end

   #
   # Controllo se nella tabella del check offerte data e che i controlli siano tutti OK
   # lo fa sia per il controllo MGP sia per il controllo MI
   #
   # # 1. Apro il mio file
   # 2. Selezioni il primo foglio
   # 3. Metto in un array bidimensionale la mia tabellina dei check
   # 4. Scorro la prima colonna della mia tabellina check
   # 5. Se presente flusso controllo la data
   # 6. Altrimenti controllo che il check sia OK
   #
   def check_controllo_offerte(file_controlo)
      s                 = Roo::Excel.new(file_controlo.to_s)
      sheet             = s.sheet(0)
      tabella_controlli = [sheet.column(2),sheet.column(3)]
      tabella_controlli[0].each_with_index do |x,y|
         if x == "FLUSSO"
            unless tabella_controlli[1][0] == $data
               errore << "Nel file #{file_controlo.basename} c'è una data diversa da quella selezionata"
            end
         else
            unless tabella_controlli[1][y] == "OK"
               errore << "Nel file #{file_controlo.basename} il \"#{tabella_controlli[0][y]}\" non è OK"
            end
         end
      end
   end

   #
   # Controllo se le offerte MGP|MI scaricate hanno all'interno del file la data selezionata e
   # le offerte presenti all'interno del file corrispondono al mercato presente nel nome del file
   #
   # # 1. Apro il mio file
   # 2. Selezioni il primo foglio
   # 3. Controllo se la data di inizio e di fine corrisponde alla data selezionata 
   # 4. Controllo se il mercato presente all'interno del file corrisponde con quello del nome del file
   #
   def check_offerte(offerte)
      s                 = Roo::Excel.new(offerte.to_s)
      sheet             = s.sheet(0)
      if  (sheet.cell("k",5) != "#{$day}/#{$month}/#{$year}") || (sheet.cell("k",7) != "#{$day}/#{$month}/#{$year}")
         errore << "Data presente nel file #{offerte.basename} non corrisponde con la data selezionata"
      end
      mercato = ((offerte.basename.to_s).split("_").last).sub(".xls","")

      if mercato.match("MI")
         unless (sheet.cell("G",9)) == mercato
            errore << "Nel file #{offerte.basename} non ci sono le offerte #{mercato}"
         end
      else
         unless (sheet.cell("G",9)) == "MGP" 
            errore << "Nel file #{offerte.basename} non ci sono le offerte MGP"
         end

      end
   end
   
   def controllo_offerte_pce(offerte)
   



   end

end




