# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "theme1-jekyll"
  spec.version       = "0.1.0"
  spec.authors       = ["Unknown"]
  spec.email         = ["hello@yedit.org"]

  spec.summary       = %q{ theme 1 for jekyll }
  spec.homepage      = "http://themes.yedit.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(assets|_layouts|_includes|_sass|LICENSE|README)}i) }
end