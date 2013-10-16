require 'openssl'
require 'json'
require 'time'

expired = []
valid = []

#crtfiles = File.join("/home/heathseals/pkild-api/**", "*.crt")
crtpath =  Dir.glob(File.join("/home/heathseals/pkild-api/**", "*.crt")) 
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
sorted = valid.sort_by {|h| h[:not_after]}
expires_next = sorted[0] 
next_ten = sorted[0..9]
puts JSON.pretty_generate(next_ten)
