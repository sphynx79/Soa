#!/usr/local/bin/ruby
# coding: utf-8
require 'fileutils'
require 'win32ole'
require 'zip'
require 'pathname'
require 'ap'
require 'byebug'
require 'zip'

module ExcelConst end

class Avvio
   attr_accessor :zip,:errori, :soa, :data, :button, :progress, :statusbar, :parent
   def initialize(data,soa)
      @data        = Date.new(data[0],data[1],data[2])
      # TODO: Vedere se mi serve la seguente variabile
      # @mesetext    = NumeroToMese @month                              # Luglio
      @soa         = soa                                              # {"Autorizzazioni"=>nil, "MGP_Validate"=>nil, "MGP_Esitate"=>nil...., "Vpp"=>nil}
      @errori      = {}
      @zip         = []
   end

   def init(progress,statusbar, step)

   end

   def start_vpp(button, progress, statusbar, parent)

   end

   def start(button, progress,statusbar,parent)
      @button, @progress, @statusbar, @parent = button, progress, statusbar, parent
      soa.each do |nome_soa,obj_soa|
         soa[nome_soa] =  Soa.new(nome_soa, data)
         soa[nome_soa].inizializza_path
         soa[nome_soa].crea_zip
         unless (soa[nome_soa].errore).empty?
            @errori[nome_soa] = soa[nome_soa].errore
         end
      end
      unless errori.empty?
         start_win_error
      end
      button.sensitive = true
   end



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
         align = Gtk::Alignment.new(0, 0, 0.0, 0.0)
         label  = Gtk::Label.new("#{k.to_s}:\n")
         initial_font = Pango::FontDescription.new("Sans Bold 10")
         label.modify_font(initial_font)
         align.add(label)
         vbox.pack_start(align)
         v.each{|n,m|
            #label1 =  Gtk::Label.new("#{n.to_s}: #{m.to_s}\n")
            label1 =  Gtk::Label.new("#{m.to_s}\n")
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


