use_frameworks!

platform :ios, '13.0'

target 'QLUISDK_Demo_iOS_Example' do
  pod 'TeneasyChatSDKUI_iOS', :git => 'https://github.com/QiSDK/QiChatDemo_iOS.git', :branch => '2026UISDK'
  pod 'TeneasyChatSDK_iOS', :git => 'https://github.com/QiSDK/QiChatSDK_iOS.git'
  #pod 'TeneasyChatSDKUI_iOS', :path => '../QiChatDemo_iOS'
  #pod 'TeneasyChatSDK_iOS', :path => '/Users/xuefeng/Desktop/teneasy/QiChatSDK_iOS'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        if target.name == 'HandyJSON'
          config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
          config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
        end
      end
    end
  end
end
