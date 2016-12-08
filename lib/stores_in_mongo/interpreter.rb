module StoresInMongo
  class Interpreter < BasicObject
    def initialize(builder)
      @builder = builder
    end

    def field(name, data_type = nil)
      @builder.add_field(name, data_type)
    end

    def session(&blk)
      @builder.define_session(&blk)
    end
  end
end
