#!/usr/local/bin/ruby
# coding: utf-8
require File.join(File.dirname(__FILE__), 'utility.rb')
require File.join(File.dirname(__FILE__), 'vpp.rb')
require_relative 'mapi/msg'
TMP_FOLDER =  File.dirname(__FILE__)+"/tmp/"


class Soa 
   attr_accessor :nome_controllo, :data, :zip, :files, :errore
   def initialize(nome)
      @nome_controllo  = nome 
      @zip             = nil 
      @files           = Array.new
      @errore          = Array.new
   end



   #
   # Inizializzo il path dove mettere il file zip
   #
   # @todo inserire i path degli zip dentro il file setting.yml
   #
   def inizializza_zip_path
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
         @files.each do |f|
            if f.fnmatch?("*/ProgrFisica_*")
               if f.fnmatch?("*/Validati/*")
                  zf.mkdir("validate_pce") if zf.find_entry("validate_pce") == nil
                  zf.add("validate_pce"+"/"+(f.basename).to_s, f)
               else
                  zf.mkdir("esitate_pce") if zf.find_entry("esitate_pce") == nil
                  zf.add("esitate_pce"+"/"+(f.basename).to_s, f)
               end
            else

               zf.add(f.basename.sub("\u00E0","a"), f)
            end
         end
      end
   end


end


class SoaVpp < Soa 

   attr_accessor :autorizzazione, :start_day , :end_day, :profilo_distra, :profilo_gdf 
   def initialize(nome)
      super(nome)
      @start_day        = $data-4
      @end_day          = $data+2
      @profilo_distra   = Array.new
      @profilo_gdf      = Array.new
      @check_disptrad   = 0 
   end

   def inizializza_file_path
      lista_file
      check_file

   end

   def lista_file
      set_path_autorizzazione
      set_path_file_email
      set_path_disp_trad
      @files.uniq! 
   end

   def set_path_autorizzazione
      @autorizzazione = Pathname.new("F:/PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/soa_vpp/Autorizzazioni/Conferma VPP #{($data-4).strftime('%d%m%y')}-#{($data+2).strftime('%d%m%y')}.doc")
      @files << @autorizzazione
   end

   def set_path_file_email
      # scorro i giorni e cerco l'e-mail dei vpp e gli inserisco nel file zip
      0.upto(6) { |i|
         d    = @start_day+i
         file = Dir[ "F:/PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/soa_vpp/mail/Profilo acquisto energia VPP ENI*\s#{(d).strftime('%-d')}\s*#{NumeroToMese((d).strftime('%m'))}*"]

         if file.empty?
            file = Dir[ "F:/PROGRAMMAZIONE #{$year}/ITALIA/Report/SOA Italia/File Zip/soa_vpp/mail/Profilo acquisto energia VPP ENI*\s#{(d).strftime('%d')}\s*#{NumeroToMese((d).strftime('%m'))}*"]
         end
         # ap file
         # insrisco nella lista file da inserire nello zip l'e-mail per ogni giorno
         # es: @file_list["Profilo acquisto energia VPP ENI-GSEI per il giorno 14 Marzo 2014.msg"=>"F:\\PROGRAMMAZIONE #{@year}\\ITALIA\\Report\\SOA Italia\\File Zip\\soa_vpp\\mail\\"]
         # se non la trova inserisce l'errore
         # "F:\\PROGRAMMAZIONE #{@year}\\ITALIA\\Report\\SOA Italia\\File Zip\\soa_vpp\\mail\
         unless file.empty?
            @files << Pathname.new(file[0]) 
         else
            @errore << "Errore e-mail VPP per il giorno #{d.to_s} non è stata trovata"
         end
      }
   end

   def set_path_disp_trad
      @files << Pathname.new("G:/MEOR/PROGRAMMAZIONE #{$year}/ITALIA/Programmazione Giornaliera/#{(@start_day).strftime("%m")}_#{(@start_day).strftime("%y")}/disponibilità_TRAD_#{(@start_day).strftime("%m")}_v2.0.xls")
      if  (@start_day).month != (@end_day).month
         @files << Pathname.new("G:/MEOR/PROGRAMMAZIONE #{$year}/ITALIA/Programmazione Giornaliera/#{(@end_day).strftime("%m")}_#{(@end_day).strftime("%y")}/disponibilità_TRAD_#{(@end_day).strftime("%m")}_v2.0.xls")
      end
   end

   def check_file
      @files.each do |file|
         case 
         when file.fnmatch("*disponibilità_TRAD_*")               then check_vpp() if  @check_disptrad == 0
         else

         end
      end
   end

   def check_vpp()
      estrai_profilo_disp_trad
      estrai_profilo_email
      # byebug
      @profilo_distra.zip(@profilo_gdf).each do |x,y|
         unless x == y
            @errore << "VPP per il  #{x[0]} le quantità in disp_trad non coincidono con quelle delle e-mail"
         end
      end
      @check_disptrad = 1
   end

   def estrai_profilo_disp_trad
      file_disp_trad = @files.select{|f|  f.fnmatch("*disponibilità_TRAD_*")}

      giorni = *(@start_day..@end_day)
      giorni.collect! { |x| x.to_datetime} 

      index = 0
      file_disp_trad.each do |file|
         spreadsheet = Spreadsheet.open(file, 'r') 
         sheet = spreadsheet.worksheet("_VPP_ELECTRABEL") 
         4.upto(34) do |row|
            if (DateTime.new(1899, 12, 30) + sheet.row(row)[0].value).to_s == giorni[index].to_s 
               @profilo_distra << [giorni[index].strftime("%d-%m-%y")] + sheet.row(row)[2..25]
               index += 1
            end
            break if index == 7 
         end
      end

   end

   def estrai_profilo_email
      lista_allegati  = estrai_allegati

      index = 0
      giorni = *(@start_day..@end_day)
      giorni.collect! { |x| x.to_datetime}    

      lista_allegati.each do |file|
         Spreadsheet.open file do |spreadsheet|
            sheet = spreadsheet.worksheet 0 

            5.upto(sheet.last_row_index) do |row|
               if sheet.row(row)[0] == giorni[index]
                  @profilo_gdf << [giorni[index].strftime("%d-%m-%y")] + sheet.row(row)[1..sheet.column_count].compact!
                  index += 1
               end
               break if index == 7 
            end
            # book should be closed when the block exits
         end

      end
      elimina_allegati_email(lista_allegati)
   end

   # estraggo gli allegati dalle email
   def estrai_allegati()
      lista_email =  @files.select{|f|  f.fnmatch("*Profilo acquisto energia*")}
      lista_allegati = []
      lista_email.each do |email|  
         msg = Mapi::Msg.open(email.to_s) 
         allegato = msg.attachments.find { |h| (h.filename).match("xls")}
         (lista_allegati << TMP_FOLDER+"/"+ File.basename(allegato.filename)).uniq! 
         tmp_file = open(TMP_FOLDER+ "/"+ File.basename(allegato.filename), 'wb') 
         allegato.save tmp_file
         tmp_file.close
      end
      return lista_allegati 
   end

   def elimina_allegati_email(lista_allegati)
      lista_allegati.each{|f| File.delete f if File.exist?(f)}

   end

   def crea_autorizzazione
      creazione_print_screen_vpp()
      crea_word_autorizzazione
   end

   def creazione_print_screen_vpp()
      #avanzamento_progress_bar(progress,statusbar,"Creazione PrintScreen PCE")
      #sleep 1

      #avanzamento_progress_bar(progress,statusbar,"Login PCE")
      vpp = Vpp::Pce.new(data)
      vpp.login

      #avanzamento_progress_bar(progress,statusbar,"Lista Transazioni")
      vpp.lista_transazioni

      #avanzamento_progress_bar(progress,statusbar,"Dettaglio Transazioni")
      vpp.navigate_table
   end

   def crea_word_autorizzazione
      word   = start_word
      fso    = WIN32OLE.new('Scripting.FileSystemObject')
      folder = fso.GetFolder('.').path
      doc    = "#{folder}\\lib\\tmp\\Eni.doc"
      table  = "#{folder}\\lib\\tmp\\table.png" 

      file = word.documents.open(doc)
      word.Selection.EndKey(6)
      word.selection.typetext("Invio Offerta su PCE gg di flusso #{(@start_day).strftime('%d/%m/%Y')} – #{(@end_day).strftime('%d/%m/%Y')}\n")
      word.Selection.Range.InlineShapes.AddPicture(table)
      File.delete(table)

      word.Selection.EndKey(6)
      word.selection.typetext("\n")

      for i in 1..7
         word.Selection.EndKey(6)
         img = "#{folder}\\lib\\tmp\\#{i}.png"
         if File.exist? img
            word.Selection.Range.InlineShapes.AddPicture(img)
            File.delete(img)
         end
      end
      file.SaveAs((@autorizzazione.to_s).gsub("/","\\"))
      word.documents.close()
      word.Quit

   end

   def start_word
      word = WIN32OLE.new("word.application")
      word.visible = true
      return word
   end


end



class SoaNormali < Soa
   def initialize(nome)
      super(nome)
   end

   #
   # Inizializzo i path dove mettere il file zip, e dove sono
   # tutti i file da inserire dentro lo zip
   #
   def inizializza_file_path
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
              end
      trova_file(files)
   end

   #
   # Inserisco dentro la variabile d'istanza @files l'ultima versione dei file che mi servono
   # 1. Scorro la lista dei file da inserire 
   # 2. Cerco l'ultima versione del file disponibile
   # 3. Se lo trova lo inserisce nella variabile d'istanza [Array] @files,
   #    altrimente scrive l'errore nella variabile d'istanza [Array] @errore 
   # 4. Cerca l'e-mail delle autorizzazioni e le inserisce dentro @files
   #
   # @example
   #     @files   = ["[#<Pathname:C:/PROGRAMMAZIONE 2014/ITALIA/Report/SOA Italia/Validate/Validate_Eni_09112014.xls>,#<Pathname:C:/MEOR/PROGRAMMAZIONE 2014/Controllo Prezzi MGP/Prezzi_Offerte_MGP_1.1_09112014.xls>]
   #     @errore = ["01_AutorizzazioneEpexCH_ENI_20141109.xls" => "File non trovato nella directory ....."]
   #
   # @param [Array] files Lista file da inserire nello zip
   # 
   def trova_file(files)
      if files != nil
         files.each do |file|
            if result = controRev(file)
               @files << result
            else
               dir, base = File.split(Pathname.new(file))
               errore << "Non è stato trovato il file #{base.to_s} nella directory #{dir.to_s}"
            end
         end
      end
      email = trova_email_autorizzazione
      email.each{|f| @files << f} unless email.empty?      
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
      ext = pathname.extname
      if (pathname.sub("#{ext}","_rev2#{ext}")).exist?
         return (pathname.sub("#{ext}","_rev2#{ext}"))
      elsif (pathname.sub("#{ext}","_rev1#{ext}")).exist?
         return (pathname.sub("#{ext}","_rev1#{ext}"))
      elsif pathname.exist?
         return pathname
      else
         return false
      end
   end


   #
   # Esegue i controlli dei file da inserire negli zip
   # 1. Scorro i file da inserire nello zip
   # 2. Controllo il tipo di file, e lancio il relativo controllo
   #
   def check_file
      @files.each do |file|
         case 
         when file.fnmatch("*Verbale autorizzativo*")                then check_verbale(estrai_allegato(file))
         when file.fnmatch("*Prezzi_Offerte*")                       then check_controllo_offerte(file)
         when file.fnmatch("*Validate_Eni*")                         then check_offerte(file)
         when file.fnmatch("*Esitate_Eni*")                          then check_offerte(file)
         when file.fnmatch("*ProgrFisica*")                          then check_offerte_pce(file)
         when file.fnmatch("*Scheduling & Bilateral Program*")       then check_scheduling_bilateral(file)
         when file.fnmatch("*tool autorizzazione offerte belpex*")   then check_tool_belgio(file)
         when file.fnmatch("*Export E-prog46_ita.xls")               then check_tool_olanda(file) 
         when file.fnmatch("*Validate_*_*.docx")                     then check_validate_epex(file) 
         when file.fnmatch("*Esitate_Francia_*.csv")                 then check_esitate_epex(file)
         when file.fnmatch("*Esitate_Germania_*.csv")                then check_esitate_epex(file) 
         when file.fnmatch("*Esitate_Svizzera_*.csv")                then check_esitate_epex(file) 
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
         @errore << "Il giorno selezionato non rietra tra le date presenti nel verbale #{Pathname.new(allegato).basename}"
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
   # 1. Apro il mio file
   # 2. Selezioni il primo foglio
   # 3. Metto in un array bidimensionale la mia tabellina dei check
   # 4. Scorro la prima colonna della mia tabellina check
   # 5. Se presente flusso controllo la data
   # 6. Altrimenti controllo che il check sia OK
   #
   def check_controllo_offerte(file_controlo)
      sheet = apri_file(file_controlo)
      tabella_controlli = [sheet.column(2),sheet.column(3)]
      tabella_controlli[0].each_with_index do |x,y|
         if x == "FLUSSO"
            unless tabella_controlli[1][0] == $data
               @errore << "Nel file #{file_controlo.basename} c'è una data diversa da quella selezionata"
            end
         else
            unless tabella_controlli[1][y] == "OK"
               @errore << "Nel file #{file_controlo.basename} il \"#{tabella_controlli[0][y]}\" non è OK"
            end
         end
      end
   end

   #
   # Controllo se le offerte MGP|MI scaricate hanno all'interno del file la data selezionata e
   # le offerte presenti all'interno del file corrispondono al mercato presente nel nome del file
   #
   # 1. Apro il mio file
   # 2. Selezioni il primo foglio
   # 3. Controllo se la data di inizio e di fine corrisponde alla data selezionata 
   # 4. Controllo se il mercato presente all'interno del file corrisponde con quello del nome del file
   #
   def check_offerte(offerte)
      sheet = apri_file(offerte)
      if  (sheet.cell("k",5) != "#{$day}/#{$month}/#{$year}") || (sheet.cell("k",7) != "#{$day}/#{$month}/#{$year}")
         @errore << "Data presente nel file #{offerte.basename} non corrisponde con la data selezionata"
      end
      mercato = ((offerte.basename.to_s).split("_").last).sub(".xls","")

      if mercato.match("MI")
         unless (sheet.cell("G",9)) == mercato
            @errore << "Nel file #{offerte.basename} non ci sono le offerte #{mercato}"
         end
      else
         unless (sheet.cell("G",9)) == "MGP" 
            @errore << "Nel file #{offerte.basename} non ci sono le offerte MGP"
         end

      end
   end


   # Controllo le offerte PCE
   #
   # @param [Pathname] offerte pce da controllare
   #
   def check_offerte_pce(offerte)
      sheet = apri_file(offerte)
      if  sheet.cell("J",3) != "#{$day}/#{$month}/#{$year}"
         @errore << "Data presente nel file #{offerte.to_s} non corrisponde con la data selezionata"
      end
   end

   #
   # Controllo del file Scheduling & Bilateral Program
   # 1. Apro il mio file
   # 2. Selezioni il foglio "EPEX"
   # 3. Controllo se tutti i controlli siano OK
   # 4. Selezioni il foglio "Extern IT"
   # 5. Controlo se la data all'interno del file coincide con quella selezionata
   #
   # @param [Pathname] file_sch_bil file delle offerte germania, svizzera, francia
   #
   def check_scheduling_bilateral(file_sch_bil)
      s = Roo::Excel.new(file_sch_bil.to_s)
      sheet = s.sheet("EPEX")
      tabella_controlli = sheet.to_matrix(34, 2,  36, 4).to_a
      tabella_controlli.each do |row|
         if  row[2] != "OK"
            @errore << "Nel file #{file_sch_bil.to_s} il \"#{row[0]}\" non è OK"
         end
      end
      sheet = s.sheet("Extern IT")
      if sheet.cell("C",2) != "#{$day}/#{$month}/#{$year}"
         @errore << "Data presente nel file #{file_sch_bil.to_s} non corrisponde con la data selezionata"
      end
   end

   #
   # Controllo del file utilizzato per le offerte Belpex
   # 1. Apro il mio file
   # 2. Controllo se tutti i controlli siano OK
   # 3. Controlo se la data all'interno del file coincide con quella selezionata
   #
   # @param [Pathname] file_tool_belpex file delle offerte Belpex
   #
   def check_tool_belgio(file_tool_belpex)
      s = Roo::Excel.new(file_tool_belpex.to_s)

      if s.sheet("Buy summary").cell("G",2) != "OK"
         @errore << "Nel file #{file_tool_belpex.to_s} nel foglio \"Buy summary\" il check verbale non è OK"
      end
      if s.sheet("Sell summary").cell("G",2) != "OK"
         @errore << "Nel file #{file_tool_belpex.to_s} nel foglio \"Sell summary\" il check verbale non è OK"
      end
      if s.sheet("Buy summary").cell("B",1) != $data
         @errore << "Data presente nel file #{file_tool_belpex.to_s} non corrisponde con la data selezionata"
      end
   end

   #
   # Controllo del file utilizzato per le offerte Olanda
   # 1. Apro il mio file
   # 2. Controllo se tutti i controlli siano OK
   # 3. Controlo se la data all'interno del file corrisponde alla data selezionataionata
   # 4. Controlo se la tabella dei check_tool_olanda è tutto OK
   # 5. Controlo se la data selezionata rientra tra quelle del Verbale
   #
   # @param [Pathname] file_tool_belpex file delle offerte Belpex
   #
   def check_tool_olanda(file_tool_olanda)
      s = Roo::Excel.new(file_tool_olanda.to_s)
      # Controllo la data
      if s.sheet("Config").cell("L",10) != $data
         @errore << "Data presente nel file #{file_tool_olanda.to_s} non corrisponde con la data selezionata"
      end
      # Controllo tabella dei check Verbale
      tabella_controlli = s.sheet("Check APX").to_matrix(13, 8,  15, 10).to_a
      tabella_controlli.each do |row|
         if  row[2] != "OK"
            @errore << "Nel file #{file_tool_olanda.to_s} foglio \"Check APX\" il \"#{row[0]}\" non è OK"
         end
      end
      # Check se data selezionata è compresa tra quelle del verbale
      unless $data.between? (s.sheet("Verbale").cell("D",9)),(s.sheet("Verbale").cell("D",10))
         @errore << "Il giorno selezionato non rientra tra le date presenti nel verbale foglio \"Verbale \" del file #{file_tool_olanda.to_s}"
      end
   end

   #
   # Controllo se la data presente all'interno delle validate Epex corrisponde alla data selezionata
   #
   # @param [Pathname] file_epex file delle validate Epex
   #
   def check_validate_epex(file_epex)
      doc = Docx::Document.open(file_epex.to_s)
      if doc.paragraphs[8].text[-10..-1] != "#{$day}/#{$month}/#{$year}"
         @errore << "La data all'interno del file #{file_epex.to_s} non coincide con la data selezionata"
      end
   end

   #
   # Controllo se la data presente all'interno delle esitate Epex corrisponde alla data selezionata
   #
   # @param [Pathname] file_epex file delle validate Epex
   #
   def check_esitate_epex(file_epex)
      csv = Roo::CSV.new(file_epex.to_s, csv_options: {col_sep: ";"})   
      if csv.cell(1,2) != "#{$day}/#{$month}/#{$year}"
         @errore << "La data all'interno del file #{file_epex.to_s} non coincide con la data selezionata"
      end
   end

   #
   # Apre il file excel
   #
   # @param [Pathname] file da aprire
   # @return [Roo::Excel] sheet del foglio excel
   #
   def apri_file(file)
      s = Roo::Excel.new(file.to_s)
      return s.sheet(0)
   end



end




