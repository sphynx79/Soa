#!/usr/local/bin/ruby
# coding: utf-8
require 'fileutils'
require 'win32ole'
require 'zip'
require 'pathname'
require 'ap'
require 'byebug'
require 'zip'
require 'yaml'

module ExcelConst end

class Avvio
   attr_accessor :zip,:errori, :soa, :data, :button, :progress, :statusbar, :parent, :partial_progress
   def initialize(data,soa)
      @data        = Date.new(data[0],data[1],data[2])
      # TODO: Vedere se mi serve la seguente variabile
      # @mesetext    = NumeroToMese @month                              # Luglio
      @soa         = soa                                              # {"Autorizzazioni"=>nil, "MGP_Validate"=>nil, "MGP_Esitate"=>nil...., "Vpp"=>nil}
      @errori      = {}
      @zip         = []
   end

   #
   # Metodo invocato quando faccio click su start nella mia GUI 
   # 1. Inizializzo le variabili globali                    => {#initialize_global_variable}
   # 2. Inizializzo la GUI per far scorrere la progress-bar => {#init_gui}
   # 3. Creo i miei SOA                                     => {#crea_soa}
   # 4. Finalizzo l'applicazione                            => {#finalizze_application}
   # @param [Gtk::Button]      button
   # @param [Gtk::ProgressBar] progress
   # @param [Gtk::Statusbar]   statusbar
   # @param [GuiSoa]           parent
   #
   def start(button, progress,statusbar,parent)
      @button, @progress, @statusbar, @parent = button, progress, statusbar, parent
      initialize_global_variable
      init_gui
      crea_soa
      finalizze_application
   end

   #
   # Inizializzo le variabili globali
   #
   def initialize_global_variable
      iniziallizza_global_data
      iniziallizza_global_setting
   end

   #
   # Inizializzo le variabili globali per le date 
   #
   def iniziallizza_global_data
      $data          = @data  
      $year          = data.strftime("%Y")
      $year_short    = data.strftime("%y")
      $month         = data.strftime("%m")
      $monthtext     = NumeroToMese(data.strftime("%m"))
      $day           = data.strftime("%d")
      $week          = data.cweek
   end

   #
   # Inizializzo le variabili globali per settaggi letti dal file settings.yml
   #
   def iniziallizza_global_setting()
      $settings = YAML::load_file(File.join(File.dirname(__FILE__), "settings.yml"))
      $settings.each{|k,v|
         v.collect!{|x|
            x.gsub!("|YEAR|", $year)
            x.gsub!("|YEAR_SHORT|", $year_short)
            x.gsub!("|MONTH|", $month)
            x.gsub!("|DAY|", $day)
            x.gsub!("|MESETEXT|",$monthtext)
            x.gsub!("|F|", $F)
            x.gsub!("|G|", $G)
            x.gsub!("|V_CONTROOLLO_MGP|", $controllomgp)
            x
         }
      }
   end

   #
   # Inizializzo la mia gui per far vedere la progress-bar con i vari step compiuti
   #
   def init_gui
      statusbar.push(1, "Avvio")
      progress.text = "%.0f%%" % "0"
      progress.fraction = 0 / 100.0
      while (Gtk.events_pending?)
         Gtk.main_iteration
      end
      @partial_progress =  100/(@soa.length+1)
      @percent = @partial_progress
   end

   #
   # Creo gli zip dei miei controlli:
   #  1. Scorro la lista dei soa che sono stati scelti nella gui
   #  2. Indico nella progress-bar lo step in cui mi trovo
   #  3. Per ogni soa creo un oggetto ClassSoa 
   #  4. Invoco il mio metodo inizializza_path per settare i path relativi al soa corrente
   #  5. Creo il file zip relativo al soa corrente 
   #  6. Controllo se ci sono errori e li aggiungo alla variabile d'istanza [Hash] errori
   #  
   def crea_soa
      soa.each do |nome_soa,obj_soa|
         avanzamento_progress_bar(nome_soa)
         soa[nome_soa] =  Soa.new(nome_soa)
         soa[nome_soa].inizializza_path
         soa[nome_soa].crea_zip
         unless (soa[nome_soa].errore).empty?
            @errori[nome_soa] = soa[nome_soa].errore
         end
      end
   end

   #
   # Faccio andare avanti la progress-bar di uno step e scrivo nella status-bar lo step un cui mi trovo
   #
   def avanzamento_progress_bar(nome_step)
      statusbar.push(1, "#{nome_step}")
      progress.text = "%.0f%%" % @percent
      progress.fraction = @percent / 100.0
      while (Gtk.events_pending?)
         Gtk.main_iteration
      end
      @percent += @partial_progress
   end

   #
   # Finalizzo la mia applicazione:
   #  1. Faccio andare la progress=bar al 100%
   #  2. Scrivo nella statusbar-bar Complete
   #  3. Se ci sono errori apro una finestra che segnala gli errori
   #  4  Riattivo il bottone start della mia GUI
   #
   def finalizze_application
      GC.start
      sleep 1
      progress.text = "%.0f%%" % 100
      progress.fraction = 100 / 100.0
      statusbar.push(1, "Complete")
      while (Gtk.events_pending?)
         Gtk.main_iteration
      end
      unless  errori.empty?
         start_win_error
      end
      button.sensitive = true
   end

   #
   #  Avvvia la finestra per visualizzare errori
   #
   def start_win_error
      dialog = Gtk::Dialog.new(
         "Information",
         parent,
         Gtk::Dialog::MODAL,
         [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK ]
      )

      dialog.set_default_size 380, 20
      dialog.set_window_position Gtk::Window::POS_CENTER
      #dialog.has_separator = true
      hbox = Gtk::HBox.new(false, 5)
      hbox.border_width = 10
      vbox  =  Gtk::VBox.new(false,5)
      vbox.border_width = 10
      @errori.each{|k,v|
         p k
         p v
         align = Gtk::Alignment.new(0, 0, 0.0, 0.0)
         label  = Gtk::Label.new("#{k.to_s}:\n")
         initial_font = Pango::FontDescription.new("Sans Bold 10")
         label.modify_font(initial_font)
         align.add(label)
         vbox.pack_start(align)
         v.each{|e|
            #label1 =  Gtk::Label.new("#{n.to_s}: #{m.to_s}\n")
            label1 =  Gtk::Label.new("#{e.to_s}\n")
            align1 = Gtk::Alignment.new(0, 0, 0.0, 0.0)
            align1.left_padding=40
            align1.add(label1)
            vbox.pack_start(align1)
         }
      }
      image  = Gtk::Image.new(Gtk::Stock::DIALOG_ERROR, Gtk::IconSize::DIALOG)

      hbox.pack_start_defaults(image);
      hbox.pack_start_defaults(vbox);

      # Add the message in a label, and show everything we've added to the dialog.
      # dialog.vbox.pack_start_defaults(hbox) # Also works, however dialog.vbox
      # limits a single item (element).
      dialog.vbox.add(hbox)

      dialog.show_all
      dialog.run
      dialog.destroy
   end

end




