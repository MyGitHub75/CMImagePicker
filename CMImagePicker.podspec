Pod::Spec.new do |s|
  s.name         = "CMImagePicker"
  s.version      = "0.0.1"
  s.summary      = "简单快捷的图像选择框架"
  s.homepage     = "https://github.com/MyGitHub75/CMImagePicker"
  s.license      = "MIT"
  s.author       = { "chen chuan mao" => "chenye.75@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/MyGitHub75/CMImagePicker.git", :tag => s.version }
  s.source_files = "CMImagePicker/CMImagePicker/*.{h,m}"
  s.resources    = "CMImagePicker/CMImagePicker/CMImagePicker.bundle"
  s.requires_arc = true
end
