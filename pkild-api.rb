require 'openssl'
require 'json'
require 'sinatra'

set :bind, '0.0.0.0'

eftroot = "/home/heathseals/pkild-api"
eftdomain = "/home/heathseals/pkild-api/eftdomain/crts"
eftsource = "/home/heathseals/pkild-api/eftsource/crts"
 
get '/api/all/:type' do
  content_type :json
  crtfiles = File.join("#{eftroot}/**", "*.crt")
  crtpath =  Dir.glob(crtfiles)
  all = []
  valid = []
  expired = []
  crtpath.each do |x|
    x.each_line do |line|
      raw = File.read line
      cert = OpenSSL::X509::Certificate.new raw
      if cert.not_after < Time.now
        expired << {:valid => "no", :subject => "#{cert.subject}", :issuer => "#{cert.issuer}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}"}
      else
        valid << {:valid => "yes", :subject => "#{cert.subject}", :issuer => "#{cert.issuer}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}"}
      end
    end
  end
  all = expired + valid
  case "#{params[:type]}"
  when 'valid'
   JSON.pretty_generate(valid)
  when 'expired'
   JSON.pretty_generate(expired)
  when 'both'
   JSON.pretty_generate(all)
  else
    "#{params[:type]} not implemented"
  end
end

get '/api/:type/:name' do
  content_type :json
  if "#{params[:type]}" == 'host' 
    domain = "eftdomain.net"
    raw = File.read "#{eftdomain}/#{params[:name]}.#{domain}/#{params[:name]}.#{domain}.crt"
  end
  if "#{params[:type]}" == 'person' 
    raw = File.read "#{eftsource}/#{params[:name]}/#{params[:name]}.crt"
  end
  cert = OpenSSL::X509::Certificate.new raw
  hash = {:id => "#{params[:name]}", :type => "#{params[:type]}", :subject => "#{cert.subject}", :issuer => "#{cert.issuer}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}"}
  JSON.pretty_generate(hash) 
end

get '/api/:type/:name/:command' do
  content_type :json
  if "#{params[:type]}" == 'host' 
    domain = "eftdomain.net"
    raw = File.read "#{eftdomain}/#{params[:name]}.#{domain}/#{params[:name]}.#{domain}.crt"
  end
  if "#{params[:type]}" == 'person' 
    raw = File.read "#{eftsource}/#{params[:name]}/#{params[:name]}.crt"
  end
  cert = OpenSSL::X509::Certificate.new raw
  case "#{params[:command]}"
  when 'issuer'
    hash = {:id => "#{params[:name]}", :type => "#{params[:type]}", :issuer => "#{cert.issuer}"}
    JSON.pretty_generate(hash) 
  when 'not_after'
    hash = {:id => "#{params[:name]}", :type => "#{params[:type]}", :not_after => "#{cert.not_after}"}
    JSON.pretty_generate(hash) 
  when 'not_before'
    hash = {:id => "#{params[:name]}", :type => "#{params[:type]}", :not_before => "#{cert.not_before}"}
    JSON.pretty_generate(hash) 
  when 'subject'
    hash = {:id => "#{params[:name]}", :type => "#{params[:type]}", :subject => "#{cert.subject}"}
    JSON.pretty_generate(hash) 
  else
    "#{params[:command]} not implemented"
  end
end
