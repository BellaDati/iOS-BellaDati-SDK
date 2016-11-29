Pod::Spec.new do |s|


  s.name         = "BellaDatiSDK"
  s.version      = "1.0.0"
  s.summary      = "BellaDatiSDK provide access to BellaDati IoT Framework features.It let you build your own customized IoT app for iOS devices.It includes, datasets,reports,forms,pictures,sensors etc."

  s.description  = <<-DESC

BellaDati IoT Analytics Platform SDK for iOS including charts,reports,datasets,
forms,geomaps,picture analytics, etc.
                   DESC

  s.homepage     = "http://EXAMPLE/BellaDatiSDK"
  s.screenshots  = "http://54.174.113.17/wp-content/uploads/2016/08/clickrest1-1.png"



  s.license      = "MIT"
   s.author             = { "BellaDati Inc." => "support@belladati.com" }
   s.social_media_url   = "http://twitter.com/belladati"
   s.platform     = :ios, "10.0"
  s.source       = { :path => "." }
  s.source_files  = "BellaDatiSDK", "iOSBellaDatiSDK/**/*.{h,m,swift}"
s.pod_target_xcconfig = {'SWIFT_VERSION' => '3'}




end
