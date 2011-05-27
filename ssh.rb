#!/usr/bin/env ruby

require 'rubygems'
require 'net/ssh'

module Qnotifier
  class Ssh < Qnotifier::Plugin

    def initialize
      @defaults = {
      }
    end
    
    def main
      return if !defined?(@options["port"])
      
      ssh_version = `ssh -V 2>&1`
      stat("Version", ssh_version)

      stat("Port", @options["port"])     
 
      result = nil


        Timeout::timeout(2) do
          begin
            Net::SSH.start("<hostname>", '<user>', :port => @options["port"], :auth_methods => ["publickey"], :keys=>["~/.ssh/id_rsa"]) do  |ssh|
                result = ssh.exec!('echo $PWD')
	            
            end

          rescue Net::SSH::HostKeyMismatch => e
            e.remember_host!
            retry
          rescue StandardError => e
            puts  e.to_s 
            alert("SSH", "Connection failure")
	  rescue Exception => e
            puts e.to_s
            alert("SSH", "Connection failure")
          end
      end
    
      if !result.nil?

        stat("Status", "OK")
        reset_alert("SSH", "SSH is now running")
      else
        stat("Status", "Warning: SSH connected but could not complete command")
      end
  end
end
end
