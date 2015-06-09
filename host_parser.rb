# HAProxy Scale, delivers a possibility to catch linked services from etc/hosts file,
# to get the HAProxy configured as simple as possible.
#
# Copyright (C) 2015  Falk Hoppe
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

require 'erb'

services = {}
proxy_app_prefix = ENV['PROXY_APP_PREFIX']
proxy_port = ENV['PROXY_APP_PORT']

host_file = File.read('/etc/hosts')
haproxy_cfg = File.read('./haproxy.cfg.erb')

host_file.each_line do |line|
  match = /([\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}).+?\s+?(#{proxy_app_prefix}\_[\d]+).*?/.match(line)

  if match
    services[match[2]] = match[1]
  end
end

puts services.inspect

throw :no_services unless services.length > 0

template = ERB.new(haproxy_cfg)
# puts template.result
File.write(ENV['proxy_config_file'], template.result)

puts "Configfile:"
puts File.read(ENV['proxy_config_file'])

`haproxy -f /usr/local/etc/haproxy/haproxy.cfg`
