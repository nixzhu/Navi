Pod::Spec.new do |s|

  s.name        = "Navi"
  s.version     = "0.3.3"
  s.summary     = "Focus on avatar caching."

  s.description = <<-DESC
                   Navi is designed for avatar caching, with style.
                   DESC

  s.homepage    = "https://github.com/nixzhu/Navi"

  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.authors           = { "nixzhu" => "zhuhongxu@gmail.com" }
  s.social_media_url  = "https://twitter.com/nixzhu"

  s.ios.deployment_target   = "8.0"
  # s.osx.deployment_target = "10.7"

  s.source          = { :git => "https://github.com/nixzhu/Navi.git", :tag => s.version }
  s.source_files    = "Navi/*.swift"
  s.requires_arc    = true

end
