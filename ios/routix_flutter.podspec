Pod::Spec.new do |s|
  s.name             = 'routix_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Routix SDK for Flutter — iOS native stub.'
  s.description      = <<-DESC
    iOS native plugin stub for the Routix Flutter SDK.
    Attribution is handled server-side via device fingerprinting and clipboard
    token fallback. No native iOS tracking logic is required.
  DESC
  s.homepage         = 'https://routix.link'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Routix' => 'support@routix.link' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency         'Flutter'
  s.platform         = :ios, '11.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.swift_version    = '5.0'
end
