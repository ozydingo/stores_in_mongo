module StoresInMongo
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def stores_in_mongo(field_name = nil, data_type = nil, class_name: nil, foreign_key: nil, &blk)
        raise ArgumentError, "Provide either inline field_name or block syntax, you cannot provide both to stores_in_mongo" if field_name.present? && blk.present?
        class_attribute :mongo_class, :mongo_key
        builder = ::StoresInMongo::Builder.new(self, class_name, foreign_key)
        if field_name.present?
          builder.build do
            field(field_name, data_type)
          end
        else
          builder.build(&blk)
        end
      end
    end

  end
end