require 'openssl'
require 'json'
require 'sinatra'

set :bind, '0.0.0.0'

certdir = "/home/heathseals/git/pkild-api/crts"
domain = "eftdomain.net"

get '/certs/:name' do
  content_type :json
  raw = File.read "#{certdir}/#{params[:name]}.#{domain}/#{params[:name]}.#{domain}.crt"
  cert = OpenSSL::X509::Certificate.new raw
  hash = {:id => "#{params[:name]}", :subject => "#{cert.subject}", :issuer => "#{cert.issuer}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}"}
  JSON.pretty_generate(hash) 
end

get '/certs/:name/:command' do
  content_type :json
  raw = File.read "#{certdir}/#{params[:name]}.#{domain}/#{params[:name]}.#{domain}.crt"
  cert = OpenSSL::X509::Certificate.new raw
  case "#{params[:command]}"
  when 'issuer'
    hash = {:id => "#{params[:name]}", :issuer => "#{cert.issuer}"}
    JSON.pretty_generate(hash) 
  when 'not_after'
    hash = {:id => "#{params[:name]}", :not_after => "#{cert.not_after}"}
    JSON.pretty_generate(hash) 
  when 'not_before'
    hash = {:id => "#{params[:name]}", :not_before => "#{cert.not_before}"}
    JSON.pretty_generate(hash) 
  when 'subject'
    hash = {:id => "#{params[:name]}", :subject => "#{cert.subject}"}
    JSON.pretty_generate(hash) 
  else
    "#{params[:command]} not implemented"
  end
end
