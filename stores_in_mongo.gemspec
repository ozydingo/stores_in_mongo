Gem::Specification.new do |s|
  s.name        = 'stores_in_mongo'
  s.version     = '1.1.0'
  s.date        = '2016-05-04'
  s.summary     = "Seamlessly interact with mongo storage as fields of an ActiveRecord model"
  s.description = "Define new or provide existing Mongoid::Document classes that access a mongo db, use the mongo connection for persistence of specified virtual fields in an ActiveRecord model. Document creation, persistence, and reloading is handled automatically and highly customizeable."
  s.authors     = ["Andrew Schwartz"]
  s.email       = 'ozydingo@gmail.com'
  s.files       = Dir["lib/**/*"]
  s.homepage    = 'https://github.com/ozydingo/stores_in_mongo'
  s.license     = 'MIT'
  s.add_runtime_dependency 'mongoid'
end
