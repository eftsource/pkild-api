require 'openssl'
require 'json'

crtfiles = File.join("/home/heathseals/pkild-api/**", "*.crt")
crtpath =  Dir.glob(crtfiles) 
expired = []
valid = []
all = []
subjectcn = []
issuercn = []
crtpath.each do |x|
  x.each_line do |line|
    subjectcn = []
    raw = File.read line 
    cert = OpenSSL::X509::Certificate.new raw
    subjectcn = cert.subject.to_s.match(/CN=(.*)\//)[1]
    issuercn = cert.issuer.to_s.match(/CN=(.*)\//)[1]
    if cert.not_after < Time.now 
      expired << {:valid => "false", :subjectcn => "#{subjectcn}", :issuercn => "#{issuercn}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}"}
    else
      valid << {:valid => "true", :subjectcn => "#{subjectcn}", :issuercn => "#{issuercn}", :not_before => "#{cert.not_before}", :not_after => "#{cert.not_after}"}
    end
  end
end
#all = expired + valid
sorted = valid.sort_by {|h| h[:not_after]}
expiresnext = sorted[0] 
nextten = sorted[0..9]
puts JSON.pretty_generate(expiresnext)
