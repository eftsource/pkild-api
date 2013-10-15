require 'openssl'
require 'json'

crtfiles = File.join("/home/heathseals/pkild-api/**", "*.crt")
crtpath =  Dir.glob(crtfiles) 
expired = []
valid = []
all = []
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
all.group_by {|d| d[:subject]}
puts  JSON.pretty_generate(all)
