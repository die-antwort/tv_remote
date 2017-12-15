#!/usr/bin/env ruby

require "bundler/setup"
require "sinatra"
require "haml"
require_relative "./tv_remote"

before do
  @tv_remote = TvRemote.new
end

get '/' do
  @current_channel = @tv_remote.read_current_channel
  @power_status    = @current_channel ? :on : :off
  haml :index, format: :html5
end

get '/off' do
  @tv_remote.power_off
  redirect to("/")
end

get '/on' do
  @tv_remote.power_on
  sleep 7 # Powering on takes some time …
  redirect to("/")
end

get '/statusdroid' do
  @tv_remote.select_channel :statusdroid
  redirect to("/")
end

get '/appletv' do
  @tv_remote.select_channel :apple_tv
  redirect to("/")
end
