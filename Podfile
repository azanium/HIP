# Uncomment the next line to define a global platform for your project
# platform :ios, '9.1'

pre_install do |installer|
    def installer.verify_no_static_framework_transitive_dependencies; end
end

inhibit_all_warnings!

target 'Hip' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Hip
  pod 'M3U8Kit', :git => 'https://github.com/azanium/M3U8Paser.git', :branch => 'master'
  pod 'Alamofire'
  pod 'GCDWebServer'

  target 'HipTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'HipUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
