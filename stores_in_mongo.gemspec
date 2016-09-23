Gem::Specification.new do |s|
  s.name        = 'stores_in_mongo'
  s.version     = '0.3.0'
  s.date        = '2016-05-04'
  s.summary     = "Seamlessly access and store mongo document fields from an ActiveRecord object"
  s.description = "Use stores_in_mongo <field> in an ActiveRecord object, use it as if it were local. Includes ActiveRecord-like caching behavior."
  s.authors     = ["Andrew Schwartz"]
  s.email       = 'ozydingo@gmail.com'
  s.files       = Dir["lib/**/*"]
  s.homepage    = 'https://github.com/ozydingo/stores_in_mongo'
  s.license     = 'MIT'
  s.add_runtime_dependency 'mongoid', '~> 4.0', '>= 4.0.0'
end