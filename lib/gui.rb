require 'gtk2'
require File.join(File.dirname(__FILE__), 'avvio.rb')


class GuiSoa < Gtk::Window
    Colonne = Struct.new('Colonne', :check, :description)
    COLUMN_CHECK, COLUMN_DESCRIPTION = *(0..1).to_a
     if Time.now.hour >= 15
      set_ckeck = false
     else
      set_ckeck = true
     end

    SOA_D_MENO_UNO_MATTINA = [
        [ false, 'Autorizzazioni'],
        [ set_ckeck, 'MGP_Validate'],
        [ set_ckeck, 'MGP_Esitate'],
        [ set_ckeck, 'Estero_Validate'],
        [ set_ckeck, 'Estero_Esitate'],
    ].collect do |ary|
            Colonne.new(*ary)
        end
    SOA_D_MENO_UNO_POMERIGGIO = [
        [ false, 'MI_Form'],
        [ !set_ckeck, 'MI_Validate'],
        [ !set_ckeck, 'MI_Esitate']
    ].collect do |ary|
            Colonne.new(*ary)
        end
      SOA_D = [
        [ false,'MI_Form_D'],
        [ false,'MI_Validate_D'],
        [ false,'MI_Esitate_D']
    ].collect do |ary|
        Colonne.new(*ary)
    end
     VPP = [
        [ false,'Vpp']
    ].collect do |ary|
        Colonne.new(*ary)
    end

        def initialize
            super
            set_title "Gestione SOA"
            signal_connect "destroy" do
                Gtk.main_quit
            end
            init_ui
            set_default_size 412, 200
            set_border_width 10
            #set_keep_above(true)
            set_window_position Gtk::Window::POS_CENTER
            show_all

        end

        def fixed_toggled(model, path_str)

            path = Gtk::TreePath.new(path_str)

            # get toggled iter
            iter = model.get_iter(path)
            fixed =iter[COLUMN_CHECK]
            # do something with the value
            fixed ^= 1
            # set new value
            iter[COLUMN_CHECK] = fixed
        end

        def fixed_toggled_vpp(model, path_str,model_other)
            path = Gtk::TreePath.new(path_str)
            # get toggled iter
            iter = model.get_iter(path)
            fixed = iter[COLUMN_CHECK]
            model_other.each{|m,p,i|  i[COLUMN_CHECK] = false}

           # iter2 =  model_other.get_iter("0")

            #iter2[COLUMN_CHECK] = false
            # do something with the value
            fixed ^= 1
            # set new value
            iter[COLUMN_CHECK] = fixed
        end

        def create_model data
            # create list store
            store = Gtk::ListStore.new(TrueClass, String)
            # add data to the list store
            data.each do |bug|
                iter = store.append
                bug.each_with_index do |value, index|
                    iter[index] = value
                end
            end
            return store
        end

        def add_columns(treeview,header,list_soa)
            # column for fixed toggles
            renderer = Gtk::CellRendererToggle.new
            if header == "Vpp"
              renderer.signal_connect('toggled') do |cell, path|
              fixed_toggled_vpp(treeview.model, path, list_soa[0].child.model)
              fixed_toggled_vpp(treeview.model, path, list_soa[1].child.model)
              fixed_toggled_vpp(treeview.model, path, list_soa[2].child.model)
              end
            else
              renderer.signal_connect('toggled') do |cell, path|
              fixed_toggled(treeview.model, path)
              end

            end

            column = Gtk::TreeViewColumn.new('',
                                             renderer,
                                             'active' => COLUMN_CHECK)

            # set this column to a fixed sizing (of 50 pixels)
            column.sizing = Gtk::TreeViewColumn::FIXED
            column.fixed_width = 32
            treeview.append_column(column)

            # column for bug numbers
            renderer = Gtk::CellRendererText.new
            column = Gtk::TreeViewColumn.new(header,
                                             renderer,
                                             'text' => COLUMN_DESCRIPTION)
            column.sizing = Gtk::TreeViewColumn::FIXED
            column.fixed_width = 98
            column.set_sort_column_id(COLUMN_DESCRIPTION)
            treeview.append_column(column)
        end

        def make_list data,header,list_soa
            # create tree model
            model = create_model data
            # create tree view
            treeview = Gtk::TreeView.new(model)
            # colore righe alternato
            treeview.rules_hint = true
            # add columns to the tree view
            add_columns(treeview,header,list_soa)
            frame = Gtk::Frame.new
            frame.shadow_type = Gtk::SHADOW_OUT
            frame.add(treeview)
            frame
        end

        def init_ui
            table     = Gtk::Table.new 6, 3, false
            calendar  = Gtk::Calendar.new
            button    = Gtk::Button.new("Start")
            statusbar = Gtk::Statusbar.new
            pbar      = Gtk::ProgressBar.new

            list_soa_d_meno_uno_mattina       = make_list SOA_D_MENO_UNO_MATTINA,"D-1 Mattina",nil
            list_soa_d_meno_uno_pomeriggio    = make_list SOA_D_MENO_UNO_POMERIGGIO,"D-1 Pomeriggio",nil
            list_soa_d                        = make_list SOA_D,"D",nil
            list_vpp                          = make_list VPP,"Vpp", [list_soa_d_meno_uno_mattina,list_soa_d_meno_uno_pomeriggio,list_soa_d]

            table.set_column_spacings 4
            table.set_border_width 4

            table.attach(calendar, 0, 1, 0, 1, Gtk::FILL, Gtk::FILL, 5, 4)
            table.attach(Gtk::VSeparator.new, 1, 2, 0, 1, Gtk::FILL, Gtk::FILL, 0, 4)
            table.attach(list_soa_d_meno_uno_mattina, 2, 3, 0, 1, Gtk::FILL, Gtk::FILL, 5, 4)
            table.attach(list_soa_d_meno_uno_pomeriggio, 3, 4, 0, 1, Gtk::FILL, Gtk::FILL, 5, 4)
            table.attach(list_soa_d, 5, 6, 0, 1, Gtk::FILL, Gtk::FILL, 5, 4)
            table.attach(list_vpp, 6, 7, 0, 1, Gtk::FILL, Gtk::FILL, 5, 4)
            table.attach(Gtk::HSeparator.new, 0, 7, 1, 2, Gtk::EXPAND|Gtk::FILL, Gtk::EXPAND|Gtk::FILL, 5, 4)
            table.attach(button, 0, 7, 2, 3, Gtk::EXPAND|Gtk::FILL, Gtk::EXPAND|Gtk::FILL, 5, 5)
            table.attach(Gtk::HSeparator.new, 0, 7, 3, 4, Gtk::EXPAND|Gtk::FILL, Gtk::EXPAND|Gtk::FILL, 5, 4)
            table.attach(pbar, 0, 7, 4, 5, Gtk::EXPAND|Gtk::FILL, Gtk::EXPAND|Gtk::FILL, 5, 4)
            table.attach(statusbar, 0, 7, 5, 6, Gtk::FILL, Gtk::FILL, 0, 4)

            add table


            button.signal_connect("clicked"){
                data        = calendar.date
                lista_soa         = {}
                list_soa_d_meno_uno_mattina.child.model.each         do |m, p, i|  lista_soa[i.get_value(1)] = nil        if i.get_value(0) end
                list_soa_d_meno_uno_pomeriggio.child.model.each      do |m, p, i|  lista_soa[i.get_value(1)] = nil        if i.get_value(0) end
                list_soa_d.child.model.each                          do |m, p, i|  lista_soa[i.get_value(1)] = nil        if i.get_value(0) end
                list_vpp.child.model.each                            do |m, p, i|  lista_soa[i.get_value(1)] = nil        if i.get_value(0) end
                # Disabilito il bottone start
                button.sensitive = false;


                # Istanzio Download e avvio il mio programma
                # lista_soa = "{\"Autorizzazioni\"=>nil, \"MGP_Validate\"=>nil, \"MGP_Esitate\"=>nil, \"Estero_Validate\"=>nil, \"Estero_Esitate\"=>nil}"
                soa = Avvio.new(data,lista_soa)
                soa.start(button,pbar,statusbar,self)
            }

        end


end


