module StoresInMongo
  class Interpreter < BasicObject
    def initialize(builder)
      @builder = builder
    end

    def field(name, data_type = nil)
      @builder.add_field(name, data_type)
    end
  end
end
