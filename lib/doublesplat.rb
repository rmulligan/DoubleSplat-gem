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
          new_text = String.new
          File.open("#{directory}/#{phrase}.rb").each do |line|
            unless line.strip.chars.empty?
              new_text << "#{line.strip};"
            end
          end

          new_base_64 = Base64.encode64(new_text)
          print "\n--> Running Tests || "
          response = RestClient.post "#{ENDPOINT}/test", :phrase => phrase, :code => new_base_64
          response_hash = JSON.parse(response)
          print Rainbow("#{response_hash['passed_count']} Passed").green
          print Rainbow(" | ").yellow
          print Rainbow("#{response_hash['failed_count']} Failed").red

          if response_hash['failed_count'] > 0 || response_hash['passed_count'] < 1
            puts "\n\n"
            response_hash['failed_string'].split(",").each do |error|
              puts Rainbow(error).red
            end

            puts Rainbow("Check your code for syntax errors or missing closing indicators.").red if response_hash["passed_count"] < 1
          else
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
