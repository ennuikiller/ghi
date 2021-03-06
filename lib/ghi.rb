require "net/http"
require "yaml"

module GHI
  VERSION = "0.0.6"

  def self.login
    return @login if defined? @login
    @login = `git config --get github.user`.chomp
    if @login.empty?
      begin
        print "Please enter your GitHub username: "
        @login = gets.chomp
        valid = user? @login
        warn "invalid username" unless valid
      end until valid
      `git config --global github.user #@login`
    end
    @login
  end

  def self.token
    return @token if defined? @token
    @token = `git config --get github.token`.chomp
    if @token.empty?
      begin
        print "GitHub token (https://github.com/account): "
        @token = gets.chomp
        valid = token? @token
        warn "invalid token for #{GHI.login}" unless valid
      end until valid
      `git config --global github.token #@token`
    end
    @token
  end

  private

  def self.user?(username)
    url = "http://github.com/api/v2/yaml/user/show/#{username}"
    !YAML.load(Net::HTTP.get(URI.parse(url)))["user"].nil?
  rescue ArgumentError # Failure to parse YAML.
    false
  end

  def self.token?(token)
    url  = "http://github.com/api/v2/yaml/user/show/#{GHI.login}"
    url += "?login=#{GHI.login}&token=#{token}"
    !YAML.load(Net::HTTP.get(URI.parse(url)))["user"].nil?
  rescue ArgumentError, NoMethodError # Failure to parse YAML.
    false
  end
end
