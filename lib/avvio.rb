#!/usr/local/bin/ruby
# coding: utf-8
require 'fileutils'
require 'win32ole'
require 'zip'
require 'pathname'
require 'ap'
require 'byebug'




module ExcelConst end


class Avvio
   attr_accessor :zip,:error, :soa, :data
   def initialize(data,soa)
      @data        = Date.new(data[0],data[1],data[2])
      # TODO: Vedere se mi serve la seguente variabile
      # @mesetext    = NumeroToMese @month                              # Luglio
      @soa         = soa                                              # {"Autorizzazioni"=>nil, "MGP_Validate"=>nil, "MGP_Esitate"=>nil...., "Vpp"=>nil}
      @error       = {}
      @zip         = []
   end

   def init(progress,statusbar, step)
    
   end

   def start_vpp(button, progress, statusbar, parent)
     
   end

   def start(button, progress,statusbar,parent)
      soa.each{ |nome_soa,obj_soa|
         soa[nome_soa] =  Soa.new(nome_soa, data)
         soa[nome_soa].inizializza_path
      }
      ap soa
   exit 1
   end

   def start_excel
    
   end

   def start_word
   
   end

   def avanzamento_progress_bar(progress,statusbar,k)
    
   end

   def crea_zip zip
     
   end

   def finalizze_application(button,statusbar,progress,parent)
   
   end

end


