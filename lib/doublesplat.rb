require "doublesplat/version"
require "rainbow"
require "rest-client"
require "base64"
require "awesome_print"
require "listen"

module Doublesplat
  class Challenge
    def start
      phrase = ARGV[0] && !ARGV[0].chars.empty? ? ARGV[0].downcase.strip : "NONE"
      response = RestClient.get "#{ENDPOINT}/start/#{phrase}"
      response =  JSON.parse(response)

      if response['success'] == true
        start_watch phrase
      else
        puts Rainbow("Challenge Code Not Found.").red
      end
    end

    def start_watch phrase
      directory = "#{`pwd`.strip}"

      response = RestClient.get "#{ENDPOINT}/get/#{phrase}"
      code = Base64.decode64(JSON.parse(response)['base64'])

      File.open("#{directory}/#{phrase}.rb", "w") do |f|
        f.puts code
      end

      puts Rainbow("Open #{directory}/#{phrase}.rb to complete the challenge.").green
      puts "\n"
      puts Rainbow("Comments within the file will explain your mission").green

      listener = Listen.to(directory, only: /#{phrase}\.rb$/) do |modified, added, removed|
        unless modified.empty?
          # Run Tests
          new_base_64 = Base64.encode64(File.read("#{directory}/#{phrase}.rb"))
          print "\n--> Running Tests || "
          response = RestClient.post "#{ENDPOINT}/test", :phrase => phrase, :code => new_base_64
          response_hash = JSON.parse(response)

          if response_hash['passed'] == false
            print Rainbow("Failed").red
            puts "\n\n"

            puts Rainbow(response_hash['msg']).red
          else
            print Rainbow("Passed").green

            puts "\n\n"
            puts Rainbow("You did it!!!").white
            exit
          end
        end
      end
      listener.start
      puts "\n"
      puts Rainbow("Watching for file changes.").cyan
      sleep
    end
  end
end
