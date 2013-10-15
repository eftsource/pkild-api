require 'openssl'
require 'json'
require 'sinatra'

set :bind, '0.0.0.0'
 
get '/api/all' do
  content_type :json
  crtfiles = File.join("/home/heathseals/pkild-crts/**", "*.crt")
  all =  Dir.glob(crtfiles)
  array = []
  all.each do |x|
    x.each_line do |line|
      raw = File.read line
      cert = OpenSSL::X509::Certificate.new raw
      array << {:subject => "#{cert.subject}", :issuer => "#{cert.issuer}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}"}
    end
  end
  array.group_by {|d| d[:subject]}
  JSON.pretty_generate(array)
end

get '/api/:type/:name' do
  content_type :json
  if "#{params[:type]}" == 'host' 
    certdir = "/home/heathseals/pkild-api/eftdomain/crts"
    domain = "eftdomain.net"
    raw = File.read "#{certdir}/#{params[:name]}.#{domain}/#{params[:name]}.#{domain}.crt"
  end
  if "#{params[:type]}" == 'person' 
    certdir = "/home/heathseals/pkild-api/eftsource/crts"
    raw = File.read "#{certdir}/#{params[:name]}/#{params[:name]}.crt"
  end
  cert = OpenSSL::X509::Certificate.new raw
  hash = {:id => "#{params[:name]}", :type => "#{params[:type]}", :subject => "#{cert.subject}", :issuer => "#{cert.issuer}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}"}
  JSON.pretty_generate(hash) 
end

get '/api/:type/:name/:command' do
  content_type :json
  if "#{params[:type]}" == 'host' 
    certdir = "/home/heathseals/pkild-api/eftdomain/crts"
    domain = "eftdomain.net"
    raw = File.read "#{certdir}/#{params[:name]}.#{domain}/#{params[:name]}.#{domain}.crt"
  end
  if "#{params[:type]}" == 'person' 
    certdir = "/home/heathseals//pkild-api/eftsource/crts"
    raw = File.read "#{certdir}/#{params[:name]}/#{params[:name]}.crt"
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
