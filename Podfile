# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'RxStockDemo' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

def my_pods
  pod 'RxSwift', '~> 4.0'
  pod 'RxCocoa', '~> 4.0'
  pod 'Realm'
  pod 'RxRealm'
  pod 'RxRealmDataSources'
  pod 'Alamofire'
  pod 'RxAlamofire'
end

  # Pods for RxStockDemo
  my_pods
  pod 'RAMAnimatedTabBarController'
  pod 'DZNEmptyDataSet'
  pod 'SwiftCharts', :git => 'https://github.com/i-schuetz/SwiftCharts.git'
  pod 'PKHUD'

  target 'RxStockDemoTests' do
    inherit! :search_paths
    my_pods
    pod 'RxNimble'
    pod 'RxBlocking'
    pod 'OHHTTPStubs'
    pod 'OHHTTPStubs/Swift'
  end
end
