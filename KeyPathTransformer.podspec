# Be sure to run `pod lib lint KeyPathTransformer.podspec' to ensure this is a

Pod::Spec.new do |s|
  s.name             = "KeyPathTransformer"
  s.version          = "0.2.5"
  s.summary          = "Adds keypath power to Swift Dictionary"
  s.description      = <<-DESC
                       A collection of functions and extensions allowing more advance key-path magic in Swift
                       DESC
  s.homepage         = "https://github.com/devgabrielcoman/keypathtransformer"
  s.license          = { :type => "GPL v3", :file => "LICENSE" }
  s.author           = { "Gabriel Coman" => "dev.gabriel.coman@gmail.com" }
  s.source           = { :git => "https://github.com/devgabrielcoman/keypathtransformer.git", :tag => "0.2.5" }
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'KeyPathTransformer' => ['Pod/Assets/*.png']
  }
  s.dependency 'Dollar'
end
