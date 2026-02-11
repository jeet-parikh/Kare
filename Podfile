# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ProKare' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Kare

pod 'Firebase/Analytics'
pod 'Firebase/Auth'
pod 'Firebase/Core'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Firebase/Messaging'
pod 'SCLAlertView'
pod 'AnimatedField'
pod 'BadgeHub'
pod 'IQKeyboardManagerSwift'
pod 'ChameleonFramework'
pod 'NotificationBannerSwift', '~> 3.0.0'
pod 'SkeletonView'
pod 'iOSDropDown'
pod 'EmptyDataSet-Swift', '~> 5.0.0'

  target 'ProKareTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ProKareUITests' do
    # Pods for testing
  end

end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        next unless config.name == 'Debug'
        config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = [
          '$(FRAMEWORK_SEARCH_PATHS)'
        ]
    end
end
