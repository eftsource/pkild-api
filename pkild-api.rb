require 'openssl'
require 'json'
require 'sinatra'

set :bind, '0.0.0.0'

eftroot = "/home/heathseals/pkild-api"
eftdomain = "/home/heathseals/pkild-api/eftdomain/crts"
eftsource = "/home/heathseals/pkild-api/eftsource/crts"
 
get '/api/all/:type' do
  content_type :json
  crtpath =  Dir.glob(File.join("#{eftroot}/**", "*.crt"))
  valid = []
  expired = []
  crtpath.each do |x|
    x.each_line do |line|
      cert = OpenSSL::X509::Certificate.new(File.read line)
      subject_cn = cert.subject.to_s.match(/CN=(.*)\//)[1]
      issuer_cn = cert.issuer.to_s.match(/CN=(.*)\//)[1]
      days_left = DateTime.parse("#{cert.not_after}").mjd - DateTime.now.mjd
      if cert.not_after < Time.now
        expired << {:valid => "false", :subject_cn => "#{subject_cn}", :issuer_cn => "#{issuer_cn}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}", :days_left => ("#{days_left}")}
      else
        valid << {:valid => "true", :subject_cn => "#{subject_cn}", :issuer_cn => "#{issuer_cn}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}", :days_left => ("#{days_left}")}
      end
    end
  end
  all = expired + valid
  case "#{params[:type]}"
  when 'valid'
   sorted = valid.sort_by {|h| h[:not_after]}
   JSON.pretty_generate(sorted)
  when 'expired'
   sorted = expired.sort_by {|h| h[:not_after]}
   JSON.pretty_generate(sorted)
  when 'both'
   sorted = all.sort_by {|h| h[:not_after]}
   JSON.pretty_generate(sorted)
  when 'next'
   sorted = valid.sort_by {|h| h[:not_after]}
   expires_next = sorted[0]
   JSON.pretty_generate(expires_next)
  when 'nextten'
   sorted = valid.sort_by {|h| h[:not_after]}
   next_ten = sorted[0..9]
   JSON.pretty_generate(next_ten)
  else
    "#{params[:type]} not implemented"
  end
end

get '/api/:type/:name' do
  content_type :json
  if "#{params[:type]}" == 'host' 
    domain = "eftdomain.net"
    cert = OpenSSL::X509::Certificate.new(File.read "#{eftdomain}/#{params[:name]}.#{domain}/#{params[:name]}.#{domain}.crt")
    subject_cn = cert.subject.to_s.match(/CN=(.*)\//)[1]
    days_left = DateTime.parse("#{cert.not_after}").mjd - DateTime.now.mjd
  end
  if "#{params[:type]}" == 'person' 
    cert = OpenSSL::X509::Certificate.new(File.read "#{eftsource}/#{params[:name]}/#{params[:name]}.crt")
    subject_cn = cert.subject.to_s.match(/CN=(.*)\//)[1]
    days_left = DateTime.parse("#{cert.not_after}").mjd - DateTime.now.mjd
  end
  hash = {:subject_cn => "#{subject_cn}", :type => "#{params[:type]}", :subject => "#{cert.subject}", :issuer => "#{cert.issuer}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}", :days_left => "#{days_left}"}
  JSON.pretty_generate(hash) 
end

get '/api/:type/:name/:command' do
  content_type :json
  if "#{params[:type]}" == 'host' 
    domain = "eftdomain.net"
    cert = OpenSSL::X509::Certificate.new(File.read "#{eftdomain}/#{params[:name]}.#{domain}/#{params[:name]}.#{domain}.crt")
    subject_cn = cert.subject.to_s.match(/CN=(.*)\//)[1]
  end
  if "#{params[:type]}" == 'person' 
    cert = OpenSSL::X509::Certificate.new(File.read "#{eftsource}/#{params[:name]}/#{params[:name]}.crt")
    subject_cn = cert.subject.to_s.match(/CN=(.*)\//)[1]
  end
  case "#{params[:command]}"
  when 'issuer'
    hash = {:subject_cn => "#{subject_cn}", :type => "#{params[:type]}", :issuer => "#{cert.issuer}"}
    JSON.pretty_generate(hash) 
  when 'not_after'
    hash = {:subject_cn => "#{subject_cn}", :type => "#{params[:type]}", :not_after => "#{cert.not_after}"}
    JSON.pretty_generate(hash) 
  when 'not_before'
    hash = {:subject_cn => "#{subject_cn}", :type => "#{params[:type]}", :not_before => "#{cert.not_before}"}
    JSON.pretty_generate(hash) 
  when 'subject'
    hash = {:subject_cn => "#{subject_cn}", :type => "#{params[:type]}", :subject => "#{cert.subject}"}
    JSON.pretty_generate(hash) 
  else
    "#{params[:command]} not implemented"
  end
end
