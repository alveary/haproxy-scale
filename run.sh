#!/bin/sh

ruby host_parser.rb
haproxy -f /usr/local/etc/haproxy/haproxy.cfg
