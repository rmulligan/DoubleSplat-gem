require "doublesplat/version"
require "rainbow"
require "rest-client"
require "digest"
require "bcrypt"

module Doublesplat
  class Auth
    def login(options)
      status = false
      while status == false
        username = ask(Rainbow("Enter your username or email > ").blue)
        password = ask(Rainbow("Enter your password > ").blue) do |p|
          p.echo = "*"
        end

        password = password.strip
        response = RestClient.post "#{ENDPOINT}/login", :username => username, :password => password
        response =  JSON.parse(response)
        if response['success'] == false
          puts Rainbow(response['msg']).red
        else
          @token = response['msg']
          status = true
        end
      end

      puts @token
    end
  end
end
