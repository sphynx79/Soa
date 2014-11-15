def controlloRev(path,inputfile)
   #pp "#{path}#{inputfile}.xls"
   if File.exists? "#{path}#{inputfile}_rev2.xls"
      filerev = "#{inputfile}_rev2.xls"
   elsif File.exists? "#{path}#{inputfile}_rev1.xls"
      filerev = "#{inputfile}_rev1.xls"
   elsif File.exists? "#{path}#{inputfile}.xls"
      filerev = "#{inputfile}.xls"
   else
      filerev =  "errore #{inputfile}"
   end
   filerev
end

def NumeroToMese(mese)
   mese_text = case mese
               when "01"
                  "Gennaio"
               when "02"
                  "Febbraio"
               when "03"
                  "Marzo"
               when "04"
                  "Aprile"
               when "05"
                  "Maggio"
               when "06"
                  "Giugno"
               when "07"
                  "Luglio"
               when "08"
                  "Agosto"
               when "09"
                  "Settembre"
               when "10"
                  "Ottobre"
               when "11"
                  "Novembre"
               when "12"
                  "Dicembre"
               end
   mese_text
end


