Pod::Spec.new do |s|
    s.name             = 'TDSwipeSheet'
    s.version          = '1.1'
    s.summary          = 'TDSwipeSheet is a simple and easy to integrate solution for presenting UIViewController or any view in bottom or top sheet'

    s.description      = <<-DESC
    TDSwipeSheet is a simple and easy to integrate solution for presenting UIViewController or any view in bottom or top sheet. We handle all the hard work for you - transitions, gestures, taps and more are all automatically provided by the library. Styling, however, is intentionally left out, allowing you to integrate your own design with ease.
    DESC

    s.homepage         = 'http://topdevs.org'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Andrew' => 'andrew@topdevs.org' }
    s.source           = { :git => 'https://github.com/TheTopDevs/TDSwipeSheet.git', :branch => "master", :tag => s.version.to_s }

    s.ios.deployment_target = '10.0'
    s.platform              = :ios
    s.source_files          = 'TDSwipeSheet/*.{h,m}'
    s.resource              = "TDSwipeSheet/*.{png,bundle,xib,nib}"


end
