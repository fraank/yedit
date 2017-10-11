# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "plugin2"
  spec.version       = "0.2.0"
  spec.authors       = ["Unknown"]
  spec.email         = ["hello@yedit.org"]

  spec.summary       = %q{ plugin2 }
  spec.homepage      = "http://themes.yedit.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(assets|_layouts|_includes|_sass|LICENSE|README)}i) }
end