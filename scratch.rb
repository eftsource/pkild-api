require 'openssl'
require 'json'

crtfiles = File.join("/Users/heath/pkild-crts/**", "*.crt")
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
puts  JSON.pretty_generate(array)
