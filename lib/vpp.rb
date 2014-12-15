#!/usr/local/bin/ruby
# coding: utf-8
require 'capybara/dsl'
require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
   Capybara::Poltergeist::Driver.new(app, { debug: false, # change this to true to troubleshoot
                                            js_errors: false,
                                            #phantomjs_options: ['--load-images=no', '--disk-cache=false'],
                                            window_size: [1800, 1000], # this can affect dynamic layout
                                            timeout: 120
                                          })
end


Capybara.javascript_driver = :poltergeist
Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara::Poltergeist::JavascriptError
Capybara.app_host = "https://pce.ipex.it/ceuserinterface/login.aspx"
#Capybara.default_selector = :xpath

module Vpp
   class Pce
      include Capybara::DSL
      attr_accessor :start_date,:end_date
      def initialize(data)
         @start_date = ($data-4).strftime('%-e/%-m/%Y')
         @end_date  =  ($data+2).strftime('%-e/%-m/%Y')

      end

      def login
         #page.driver.headers = { "User-Agent" => "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)" }
         page.driver.headers = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1944.0 Safari/537.36" }
       
         #page.driver.browser.manage.window.maximize
         visit('/')
         fill_in "txtLogin", :with => "mboscolo863"
         fill_in "txtPassword", :with => "200899aa"
         click_button("btnAccedi")

         fill_in "txtLogin", :with => "mboscolo863"
         fill_in "txtPassword", :with => "200899aa"
         click_button("btnAccedi")
      end

      def lista_transazioni
         click_link("Lista transazioni commerciali")

         page.execute_script("document.getElementById('cphMain_dtDataFlusso_txtData').value = '#{@start_date}';")
         page.execute_script("document.getElementById('cphMain_dtDataFlussoA_txtData').value = '#{@end_date}';")
         select("GDF SUEZ ENERGIA ITALIA S.p.A.", :from => 'cphMain_cmbOpControparte')
       
         find(:xpath, '//*[@id="cphMain_lnk_RicercaFiltri"]').click
         # Eseguo il print screen di tutte le transazioni
         save_screen_all_day
      end

      def save_screen_all_day
          page.save_screenshot('lib/tmp/table.png', :selector => '#cphMain_gvTC')
      end

       def navigate_table
          numero_righe = page.all(:xpath, '//*[@id="cphMain_gvTC"]/tbody/tr').length
             file = 1
             2.upto numero_righe do |i|
                if (find(:css, "#cphMain_gvTC > tbody > tr:nth-child(#{i}) > td:nth-child(11)").text.upcase.match "VPP") && (find(:css, "#cphMain_gvTC > tbody > tr:nth-child(#{i}) > td:nth-child(9)").text.match "C")
                   find(:css, "#cphMain_gvTC > tbody > tr:nth-child(#{i})").base.double_click
                   click_on('cphMain_ucDetTC_btnViewCustomAggregateQty')
                   page.save_screenshot("lib\\tmp\\#{file}.png", :selector => '#cphMain_ucDetTC_NStdProf_gvProfilo')
                   click_on('cphMain_ucDetTC_btnChiudiNStdProf')
                   click_on('btnChiudi') 
                   file+=1
                end
              end
       end
   end
end
# 
# vpp = Vpp::Pce.new()
# vpp.login
# vpp.lista_transazioni
# vpp.navigate_table


#
