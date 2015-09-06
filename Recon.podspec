Pod::Spec.new do |s|
  s.name         = "Recon"
  s.version      = "0.1.0"
  s.summary      = "Record Notation (RECON)"
  s.homepage     = "https://github.com/web-aware/recon-swift"
  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE.md" }
  s.author       = { "Chris Sachs" => "chris@webaware.com" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/web-aware/recon-swift.git", :tag => "#{s.version}" }
  s.source_files = "Recon/*.swift"
  s.requires_arc = true
end
