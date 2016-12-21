module StoresInMongo
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def stores_in_mongo(field_name = nil, data_type = nil,
          as: nil,
          class_name: nil,
          foreign_key: nil,
          &blk)
        raise ArgumentError, "Provide either inline field_name or block syntax, you cannot provide both to stores_in_mongo" if field_name.present? && blk.present?
        raise ArgumentError, "Cannot use :class_name or :foreign_key with polymorphic :as option" if as.present? && (class_name.present? || foreign_key.present?)
        if as.present?
          foreign_key = as.to_s.foreign_key
          class_name = foreign_key.sub(/id$/, "type")
        end
        class_attribute :stores_in_mongo_options
        self.stores_in_mongo_options = {
          polymorphic: as.present?,
          foreign_key: foreign_key,
          class_name: class_name,
          use_sessions: false
        }
        builder = ::StoresInMongo::Builder.new(self)
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